pragma circom  2.1.6;

include "../node_modules/circomlib/circuits/comparators.circom";


template PassportVerificationFlow(ENCAPSULATED_CONTENT_SIZE, HASH_SIZE, SIGNED_ATTRIBUTES_SIZE, 
                                  DG1_DIGEST_POSITION_SHIFT, DG15_DIGEST_POSITION_SHIFT, SIGNED_ATTRIBUTES_SHIFT) 
{
    signal output flowResult;

    signal input dg1Hash[HASH_SIZE];
    signal input dg15Hash[HASH_SIZE];
    signal input encapsulatedContent[ENCAPSULATED_CONTENT_SIZE];
    signal input encapsulatedContentHash[HASH_SIZE];
    signal input signedAttributes[SIGNED_ATTRIBUTES_SIZE];

    // 1) Checking DG1 hash inclusion into encapsulatedContent
    component dg1HashEqualsEncapsulated[HASH_SIZE];
    for (var i = 0; i < HASH_SIZE; i++) {
        dg1HashEqualsEncapsulated[i] = IsEqual();
        dg1HashEqualsEncapsulated[i].in[0] <== dg1Hash[i];
        dg1HashEqualsEncapsulated[i].in[1] <== encapsulatedContent[DG1_DIGEST_POSITION_SHIFT + i];
    }

    // 2) Checking DG15 hash inclusion into encapsulatedContent
    component dg15HashEqualsEncapsulated[HASH_SIZE];
    for (var i = 0; i < HASH_SIZE; i++) {
        dg15HashEqualsEncapsulated[i] = IsEqual();
        dg15HashEqualsEncapsulated[i].in[0] <== dg15Hash[i];
        dg15HashEqualsEncapsulated[i].in[1] <== encapsulatedContent[DG15_DIGEST_POSITION_SHIFT + i];
    }
    
    // 3) Checking encapsulatedContent hash inclusion into signedAttributed
    component encapsulateHashEqualsSigned[HASH_SIZE];
    for (var i = 0; i < HASH_SIZE; i++) {
        encapsulateHashEqualsSigned[i] = IsEqual();
        encapsulateHashEqualsSigned[i].in[0] <== encapsulatedContentHash[i];
        encapsulateHashEqualsSigned[i].in[1] <== signedAttributes[SIGNED_ATTRIBUTES_SHIFT + i];
    }

    signal verifyAllChecksPassed[HASH_SIZE * 3];
    verifyAllChecksPassed[0] <== dg1HashEqualsEncapsulated[0].out;
    for (var i = 1; i < HASH_SIZE; i++) {
        verifyAllChecksPassed[i] <== verifyAllChecksPassed[i - 1] * dg1HashEqualsEncapsulated[i].out;
    }
    for (var i = 0; i < HASH_SIZE; i++) {
        verifyAllChecksPassed[HASH_SIZE + i] <== verifyAllChecksPassed[HASH_SIZE + i - 1] * dg15HashEqualsEncapsulated[i].out;
    }
    for (var i = 0; i < HASH_SIZE; i++) {
        verifyAllChecksPassed[2 * HASH_SIZE + i] <== verifyAllChecksPassed[2 * HASH_SIZE + i - 1] * encapsulateHashEqualsSigned[i].out;
    }

    flowResult <== verifyAllChecksPassed[3 * HASH_SIZE - 1];
}