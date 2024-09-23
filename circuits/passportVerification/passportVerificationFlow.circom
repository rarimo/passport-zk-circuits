pragma circom  2.1.6;

include "circomlib/circuits/comparators.circom";


template PassportVerificationFlow( 
    ENCAPSULATED_CONTENT_SIZE,
    HASH_SIZE,
    ENCAPSULATED_CONTENT_HASH_TYPE,
    // SIGNED_ATTRIBUTES_SIZE,
    DG1_DIGEST_POSITION_SHIFT,
    DG15_DIGEST_POSITION_SHIFT,
    SIGNED_ATTRIBUTES_SHIFT,    
    DG15_VERIFICATION) 
{
    signal output flowResult;

    var SIGNED_ATTRIBUTES_LEN = 1024;

    signal input dg1Hash[HASH_SIZE];
    signal input dg15Hash[HASH_SIZE];
    signal input encapsulatedContent[ENCAPSULATED_CONTENT_SIZE];
    signal input encapsulatedContentHash[ENCAPSULATED_CONTENT_HASH_TYPE];
    signal input signedAttributes[SIGNED_ATTRIBUTES_LEN];

    // 1) Checking DG1 hash inclusion into encapsulatedContent
    component dg1HashEqualsEncapsulated[HASH_SIZE];
    for (var i = 0; i < HASH_SIZE; i++) {
        dg1HashEqualsEncapsulated[i] = IsEqual();
        dg1HashEqualsEncapsulated[i].in[0] <== dg1Hash[i];
        dg1HashEqualsEncapsulated[i].in[1] <== encapsulatedContent[DG1_DIGEST_POSITION_SHIFT + i];
        // log("DG1 equals: ", dg1HashEqualsEncapsulated[i].out);


    }

    // for (var i = 0; i < 10; i++){
    //    log("DG1 equals: ", dg1HashEqualsEncapsulated[i].out); 
    // }
    
    // 2) Checking DG15 hash inclusion into encapsulatedContent
    component dg15HashEqualsEncapsulated[HASH_SIZE];
    for (var i = 0; i < HASH_SIZE; i++) {
        dg15HashEqualsEncapsulated[i] = IsEqual();
        dg15HashEqualsEncapsulated[i].in[0] <== dg15Hash[i] * DG15_VERIFICATION;
        dg15HashEqualsEncapsulated[i].in[1] <== encapsulatedContent[DG15_DIGEST_POSITION_SHIFT + i] * DG15_VERIFICATION;
        // log("DG15 hash: ", dg15HashEqualsEncapsulated[i].out);
    }

    //  for (var i = 0; i < 10; i++){
    //    log("DG15 equals: ", dg15HashEqualsEncapsulated[i].out); 
    // }
    
    // 3) Checking encapsulatedContent hash inclusion into signedAttributed
    component encapsulateHashEqualsSigned[HASH_SIZE];
    for (var i = 0; i < HASH_SIZE; i++) {
        encapsulateHashEqualsSigned[i] = IsEqual();
        encapsulateHashEqualsSigned[i].in[0] <== encapsulatedContentHash[i];
        encapsulateHashEqualsSigned[i].in[1] <== signedAttributes[SIGNED_ATTRIBUTES_SHIFT + i];
        // log("Encapsulated hash: ", encapsulateHashEqualsSigned[i].out);
    }

    //  for (var i = 0; i < 10; i++){
    //    log("EC equals: ", encapsulateHashEqualsSigned[i].out); 
    // }

    // 4) Checking DG15 prefix equals 0x0F = 15
    var dg15Prefix[8] = [0,0,0,0,1,1,1,1]; // 0x0F = 0b00001111
    component dg15PrefixCorrect[HASH_SIZE];
    var PREFIX_SHIFT = 24; // 3 bytes
    for (var i = 0; i < 8; i++) {
        dg15PrefixCorrect[i] = IsEqual();
        dg15PrefixCorrect[i].in[0] <== dg15Prefix[i] * DG15_VERIFICATION;
        dg15PrefixCorrect[i].in[1] <== encapsulatedContent[DG15_DIGEST_POSITION_SHIFT - PREFIX_SHIFT + i] * DG15_VERIFICATION;
        // log("EncCont: ", encapsulatedContent[DG15_DIGEST_POSITION_SHIFT - PREFIX_SHIFT + i]);
        // log("ExpectedPrefix: ", dg15Prefix[i]);
        // log("dg15PrefixCorrect", dg15PrefixCorrect[i].out);
        // log("-------------------");
    }

    // 5) Verifying that all checks in the flow are successful
    signal verifyAllChecksPassed[HASH_SIZE * 3 + 8];
    verifyAllChecksPassed[0] <== dg1HashEqualsEncapsulated[0].out;
    
    for (var i = 1; i < HASH_SIZE; i++) {
        verifyAllChecksPassed[i] <== verifyAllChecksPassed[i - 1] * dg1HashEqualsEncapsulated[i].out;
    }

    var start = HASH_SIZE;

    for (var i = 0; i < HASH_SIZE; i++) {
        verifyAllChecksPassed[start + i] <== verifyAllChecksPassed[start + i - 1] * dg15HashEqualsEncapsulated[i].out;
    }

    start += HASH_SIZE;

    for (var i = 0; i < HASH_SIZE; i++) {
        verifyAllChecksPassed[start + i] <== verifyAllChecksPassed[start + i - 1] * encapsulateHashEqualsSigned[i].out;
    }

    start += HASH_SIZE;

    for (var i = 0; i < 8; i++) {
        verifyAllChecksPassed[start + i] <== verifyAllChecksPassed[start + i - 1] * dg15PrefixCorrect[i].out;
    }

    start += 8;
    flowResult <== verifyAllChecksPassed[start - 1];
}