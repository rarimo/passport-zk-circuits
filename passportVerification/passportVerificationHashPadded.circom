pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../rsa/rsa.circom";
include "../sha256/sha256NoPadding.circom";
include "../merkleTree/SMTVerifier.circom";
include "../x509Verification/X509Verifier.circom";
include "./passportVerificationFlow.circom";


template PassportVerificationHashPadded(w, nb, e_bits, hashLen, depth, encapsulatedContentLen, dg1Shift, dg15Shift, dg15Len, signedAttributesLen, slaveSignedAttributesLen, signedAttributesKeyShift) {
    // *magic numbers* list
    var DG1_SIZE = 1024;                        // bits
    var DG15_SIZE = 3072;                       // 1320 rsa | 
    var SIGNED_ATTRIBUTES_SIZE = 1024;          // 592
    var ENCAPSULATED_CONTENT_SIZE = 3072;       // 2688
    var DG1_DIGEST_POSITION_SHIFT = dg1Shift;   // 248
    var DG15_DIGEST_POSITION_SHIFT = dg15Shift; // 2432
    var HASH_SIZE = w * hashLen;               // 64 * 4 = 256 (SHA256)
    // ------------------

    // input signals
    signal input encapsulatedContent[ENCAPSULATED_CONTENT_SIZE];
    signal input dg1[DG1_SIZE];
    signal input dg15[DG15_SIZE];
    signal input signedAttributes[SIGNED_ATTRIBUTES_SIZE];
    signal input sign[nb];
    signal input modulus[nb];
    signal input slaveMerkleRoot;
    signal input slaveMerkleInclusionBranches[depth];
    // signal input slaveMerkleInclusionOrder[depth];
    // signal input ecdsaShiftEnabled;  // 0 - RSA AA | 1 - ECDSA AA
    // signal input saTimestampEnabled; // 0 - no timestamp, 1 - with
    // -------


    // signal ecdsaShiftDisabled <== (1 - ecdsaShiftEnabled);
    // signal saTimestampDisabled <== (1 - saTimestampEnabled);

    // ecdsaShiftDisabled * ecdsaShiftEnabled === 0;
    // saTimestampDisabled * saTimestampEnabled === 0;
    

    // Hash DG1 -> SHA256
    component dg1Hasher = Sha256NoPadding(2);
    
    for (var i = 0; i < DG1_SIZE; i++) {
        dg1Hasher.in[i] <== dg1[i];
    }

    // Hash DG15 -> SHA256
    component dg15Hasher6Blocks = Sha256NoPadding(6);

    for (var i = 0; i < DG15_SIZE; i++) {
        dg15Hasher6Blocks.in[i] <== dg15[i];
    }

    component dg15Hasher3Blocks = Sha256NoPadding(3);

    for (var i = 0; i < DG15_SIZE / 2; i++) {
        dg15Hasher3Blocks.in[i] <== dg15[i];
    }

    // Check DG1 hash inclusion into encapsulatedContent
    // -- ECDSA check
    // signal encapsulatedContentTempECDSA[hashLen * nb];
    // for (var i = 0; i < hashLen * nb; i++) {
    //     encapsulatedContentTempECDSA[i] <== encapsulatedContent[DG1_DIGEST_POSITION_SHIFT + i] * ecdsaShiftEnabled;
    //     encapsulatedContentTempECDSA[i] === dg1Hasher.out[i] * ecdsaShiftEnabled;
    // }

    // -- RSA check
    // signal encapsulatedContentTempRSA[hashLen * nb];
    // for (var i = 0; i < hashLen * nb; i++) {
    //     encapsulatedContentTempRSA[i] <== encapsulatedContent[DG1_DIGEST_POSITION_SHIFT - 16 + i] * ecdsaShiftDisabled;
    //     encapsulatedContentTempRSA[i] === dg1Hasher.out[i] * ecdsaShiftDisabled;
    // }

    // Check DG15 hash inclusion into encapsulatedContent
    // signal encapsulatedContentTempDG15ECDSA[hashLen * nb];
    // for (var i = 0; i < hashLen * nb; i++) {
    //     encapsulatedContentTempDG15ECDSA[i] <== encapsulatedContent[DG15_DIGEST_POSITION_SHIFT + i] * ecdsaShiftEnabled;
    //     encapsulatedContentTempDG15ECDSA[i] === dg15Hasher6Blocks.out[i] * ecdsaShiftEnabled;
    // }
    
    // signal encapsulatedContentTempDG15RSA[hashLen * nb];
    // for (var i = 0; i < hashLen * nb; i++) {
    //     encapsulatedContentTempDG15RSA[i] <== encapsulatedContent[DG15_DIGEST_POSITION_SHIFT - 16 + i] * ecdsaShiftDisabled;
    //     encapsulatedContentTempDG15RSA[i] === dg15Hasher3Blocks.out[i] * ecdsaShiftDisabled;
    // }
    
    // Hash encupsulated content
    component encapsulatedContentHasher = Sha256NoPadding(6);
    encapsulatedContentHasher.in <== encapsulatedContent;

    // signedAttributes passport hash == encapsulatedContent hash
    var SIGNED_ATTRIBUTES_SHIFT = 336;
    // signal encapsulatedContentHasherTemp[hashLen * nb];
    // for (var i = 0; i < HASH_SIZE; i++) {
    //     encapsulatedContentHasherTemp[i] <== encapsulatedContentHasher.out[i] * saTimestampDisabled;
    //     encapsulatedContentHasherTemp[i] === signedAttributes[SIGNED_ATTRIBUTES_SHIFT + i] * saTimestampDisabled;
    // }

    // signedAttributes (WITH timestamp) passport hash == encapsulatedContent hash 

    var SIGNED_ATTRIBUTES_SHIFT_TS = 576;
    // signal encapsulatedContentHasherTempTS[hashLen * nb];
    // for (var i = 0; i < HASH_SIZE; i++) {
    //     encapsulatedContentHasherTempTS[i] <== encapsulatedContentHasher.out[i] * saTimestampEnabled;
    //     encapsulatedContentHasherTempTS[i] === signedAttributes[SIGNED_ATTRIBUTES_SHIFT_TS + i] * saTimestampEnabled;
    // }

    // Hashing signedAttributes
    component signedAttributesHasher = Sha256NoPadding(2);
    signedAttributesHasher.in <== signedAttributes;

    component rsaVerifier = RsaVerifyPkcs1v15(w, nb, e_bits, hashLen);

    rsaVerifier.sign <== sign;
    rsaVerifier.modulus <== modulus;

    signal signedAttributesHashChunks[hashLen];
    component signedAttributesHashPacking[hashLen];
    for (var i = 0; i < hashLen; i++) {
        signedAttributesHashPacking[i] = Bits2Num(w);
        for (var j = 0; j < w; j++) {
            signedAttributesHashPacking[i].in[w - 1 - j] <== signedAttributesHasher.out[i * w + j];
        }
        signedAttributesHashChunks[(hashLen - 1) - i] <== signedAttributesHashPacking[i].out;
    }

    rsaVerifier.hashed <== signedAttributesHashChunks;

    // Hashing 5 * (3*64) blocks
    component modulusHasher = Poseidon(5);
    signal tempModulus[5];
    for (var i = 0; i < 5; i++) {
        var currIndex = i * 3;
        tempModulus[i] <== modulus[currIndex] * 2**128 + modulus[currIndex + 1] * 2**64;
        modulusHasher.inputs[i] <== tempModulus[i] + modulus[currIndex + 2];
    }

     // verification flow parameters: 
    // 0) ENCAPSULATED_CONTENT_SIZE
    // 1) HASH_SIZE
    // 2) SIGNED_ATTRIBUTES_SIZE
    // 3) DG1_DIGEST_POSITION_SHIFT
    // 4) DG15_DIGEST_POSITION_SHIFT
    // 5) SIGNED_ATTRIBUTES_SHIFT

    signal RSAPubKeyFlows[3];

    // RSA FLOWS
    // FLOW 1
    // no Parameters any NULL | no signed attributes timestamp | DG15 3 blocks
    component passportVerificationFlowRsa1 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT - 16,
        DG15_DIGEST_POSITION_SHIFT - 16,
        SIGNED_ATTRIBUTES_SHIFT
    );
    passportVerificationFlowRsa1.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowRsa1.dg15Hash <== dg15Hasher3Blocks.out;
    passportVerificationFlowRsa1.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowRsa1.encapsulatedContentHash <== encapsulatedContentHasher.out;
    passportVerificationFlowRsa1.signedAttributes <== signedAttributes;
    
    log("Flow 1: ", passportVerificationFlowRsa1.flowResult);

    // FLOW 2
    // with Parameters any NULL | with signed attributes timestamp | DG15 3 blocks
    component passportVerificationFlowRsa2 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT,
        DG15_DIGEST_POSITION_SHIFT,
        SIGNED_ATTRIBUTES_SHIFT_TS
    );
    passportVerificationFlowRsa2.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowRsa2.dg15Hash <== dg15Hasher3Blocks.out;
    passportVerificationFlowRsa2.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowRsa2.encapsulatedContentHash <== encapsulatedContentHasher.out;
    passportVerificationFlowRsa2.signedAttributes <== signedAttributes;
    
    log("Flow 2: ", passportVerificationFlowRsa2.flowResult);

    // component smtVerifier = SMTVerifier(depth);
    // smtVerifier.root <== slaveMerkleRoot;
    // smtVerifier.leaf <== modulusHasher.out;
    // smtVerifier.key <== modulusHasher.out;
    // smtVerifier.siblings <== slaveMerkleInclusionBranches;

    // smtVerifier.isVerified === 1;
}