pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../rsa/rsa.circom";
include "../sha256/sha256NoPadding.circom";
include "../merkleTree/SMTVerifier.circom";
include "../x509Verification/X509Verifier.circom";
include "./passportVerificationFlow.circom";
include "./passportVerificationRSAsignature.circom";

template PassportVerificationHashPadded(BLOCK_SIZE, NUMBER_OF_BLOCKS, E_BITS, HASH_BLOCKS_NUMBER, TREE_DEPTH) {
    // *magic numbers* list
    var DG1_SIZE = 1024;                        // bits
    var DG15_SIZE = 3072;                       // 1320 rsa | 
    var SIGNED_ATTRIBUTES_SIZE = 1024;          // 592
    var ENCAPSULATED_CONTENT_SIZE = 3072;       // 2688
    var DG1_DIGEST_POSITION_SHIFT = 248;
    var DG15_DIGEST_POSITION_SHIFT = 2432; 
    var DG1_DIGEST_POSITION_SHIFT_PARAMS_ANY = DG1_DIGEST_POSITION_SHIFT + 16;
    var DG15_DIGEST_POSITION_SHIFT_PARAMS_ANY = DG15_DIGEST_POSITION_SHIFT + 16;
    var SIGNED_ATTRIBUTES_SHIFT = 336;
    var SIGNED_ATTRIBUTES_SHIFT_TS = 576;
    // ---------

    var NUMBER_RSA_FLOWS = 3;
    var NUMBER_ECDSA_FLOWS = 2;
    var HASH_SIZE = BLOCK_SIZE * HASH_BLOCKS_NUMBER; // 64 * 4 = 256 (SHA256)
    
    // ------------------

    // output signals
    signal output passedVerificationFlowsRSA;
    signal output passedVerificationFlowsECDSA;

    // input signals
    signal input encapsulatedContent[ENCAPSULATED_CONTENT_SIZE];
    signal input dg1[DG1_SIZE];
    signal input dg15[DG15_SIZE];
    signal input signedAttributes[SIGNED_ATTRIBUTES_SIZE];
    signal input sign[NUMBER_OF_BLOCKS];
    signal input modulus[NUMBER_OF_BLOCKS];
    signal input slaveMerkleRoot;
    signal input slaveMerkleInclusionBranches[TREE_DEPTH];
    // -------

    // Hash DG1 -> DG1Hash (SHA256)
    component dg1Hasher = Sha256NoPadding(2);
    for (var i = 0; i < DG1_SIZE; i++) {
        dg1Hasher.in[i] <== dg1[i];
    }

    // Hash DG15 -> DG15Hash (SHA256). Hashing all 6 blocks (ECDSA case)
    component dg15Hasher6Blocks = Sha256NoPadding(6);
    for (var i = 0; i < DG15_SIZE; i++) {
        dg15Hasher6Blocks.in[i] <== dg15[i];
    }

    // Hash DG15 -> DG15Hash (SHA256). Hashing first 3 blocks (RSA case)
    component dg15Hasher3Blocks = Sha256NoPadding(3);
    for (var i = 0; i < DG15_SIZE / 2; i++) {
        dg15Hasher3Blocks.in[i] <== dg15[i];
    }

    // Hash encupsulated content
    component encapsulatedContentHasher = Sha256NoPadding(6);
    encapsulatedContentHasher.in <== encapsulatedContent;

    // verification flow parameters: 
    // 0) ENCAPSULATED_CONTENT_SIZE
    // 1) HASH_SIZE
    // 2) SIGNED_ATTRIBUTES_SIZE
    // 3) DG1_DIGEST_POSITION_SHIFT
    // 4) DG15_DIGEST_POSITION_SHIFT
    // 5) SIGNED_ATTRIBUTES_SHIFT


    // RSA FLOWS
    signal accumulatorRSAFlows[NUMBER_RSA_FLOWS];

    // FLOW 1
    // no Parameters any NULL | no signed attributes timestamp | DG15 3 blocks
    component passportVerificationFlowRsa1 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT,
        DG15_DIGEST_POSITION_SHIFT,
        SIGNED_ATTRIBUTES_SHIFT
    );
    passportVerificationFlowRsa1.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowRsa1.dg15Hash <== dg15Hasher3Blocks.out;
    passportVerificationFlowRsa1.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowRsa1.encapsulatedContentHash <== encapsulatedContentHasher.out;
    passportVerificationFlowRsa1.signedAttributes <== signedAttributes;
    
    log("Flow 1: ", passportVerificationFlowRsa1.flowResult);
    accumulatorRSAFlows[0] <== passportVerificationFlowRsa1.flowResult;

    // FLOW 2
    // no Parameters any NULL | with signed attributes timestamp | DG15 3 blocks
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
    accumulatorRSAFlows[1] <== accumulatorRSAFlows[0] + passportVerificationFlowRsa2.flowResult;

    // FLOW 3
    // with Parameters any NULL | with signed attributes timestamp | DG15 3 blocks
    component passportVerificationFlowRsa3 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT_PARAMS_ANY,
        DG15_DIGEST_POSITION_SHIFT_PARAMS_ANY,
        SIGNED_ATTRIBUTES_SHIFT_TS
    );
    passportVerificationFlowRsa3.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowRsa3.dg15Hash <== dg15Hasher3Blocks.out;
    passportVerificationFlowRsa3.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowRsa3.encapsulatedContentHash <== encapsulatedContentHasher.out;
    passportVerificationFlowRsa3.signedAttributes <== signedAttributes;
    
    log("Flow 3: ", passportVerificationFlowRsa3.flowResult);
    accumulatorRSAFlows[2] <== accumulatorRSAFlows[1] + passportVerificationFlowRsa3.flowResult;

    // ------------------

    // ECDSA FLOWS
    signal accumulatorECDSAFlows[NUMBER_ECDSA_FLOWS];
    
    // FLOW 1
    // with Parameters any NULL | no signed attributes timestamp | DG15 6 blocks
    component passportVerificationFlowEcdsa1 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT_PARAMS_ANY,
        DG15_DIGEST_POSITION_SHIFT_PARAMS_ANY,
        SIGNED_ATTRIBUTES_SHIFT
    );
    passportVerificationFlowEcdsa1.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowEcdsa1.dg15Hash <== dg15Hasher6Blocks.out;
    passportVerificationFlowEcdsa1.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowEcdsa1.encapsulatedContentHash <== encapsulatedContentHasher.out;
    passportVerificationFlowEcdsa1.signedAttributes <== signedAttributes;
    
    log("Flow 1 (ECDSA): ", passportVerificationFlowEcdsa1.flowResult);
    accumulatorECDSAFlows[0] <== passportVerificationFlowEcdsa1.flowResult;

    // FLOW 2
    // with Parameters any NULL | with signed attributes timestamp | DG15 6 blocks
    component passportVerificationFlowEcdsa2 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT,
        DG15_DIGEST_POSITION_SHIFT,
        SIGNED_ATTRIBUTES_SHIFT_TS
    );
    passportVerificationFlowEcdsa2.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowEcdsa2.dg15Hash <== dg15Hasher6Blocks.out;
    passportVerificationFlowEcdsa2.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowEcdsa2.encapsulatedContentHash <== encapsulatedContentHasher.out;
    passportVerificationFlowEcdsa2.signedAttributes <== signedAttributes;
    
    log("Flow 2 (ECDSA): ", passportVerificationFlowEcdsa2.flowResult);
    accumulatorECDSAFlows[1] <== accumulatorECDSAFlows[0] + passportVerificationFlowEcdsa2.flowResult;

    // ------------------

    // Hashing signedAttributes
    component signedAttributesHasher = Sha256NoPadding(2);
    signedAttributesHasher.in <== signedAttributes;

    // Verifying passport signature
    component passportVerificationRSASignature = 
        PassportVerificationRSASignature(BLOCK_SIZE, NUMBER_OF_BLOCKS, E_BITS, HASH_BLOCKS_NUMBER, SIGNED_ATTRIBUTES_SIZE);
    passportVerificationRSASignature.signedAttributesHash <== signedAttributesHasher.out;
    passportVerificationRSASignature.sign <== sign;
    passportVerificationRSASignature.modulus <== modulus;

    // Hashing 5 * (3*64) blocks
    component modulusHasher = Poseidon(5);
    signal tempModulus[5];
    for (var i = 0; i < 5; i++) {
        var currIndex = i * 3;
        tempModulus[i] <== modulus[currIndex] * 2**128 + modulus[currIndex + 1] * 2**64;
        modulusHasher.inputs[i] <== tempModulus[i] + modulus[currIndex + 2];
    }

    // Verifying that public key inclusion into the Slave Certificates Merkle Tree
    component smtVerifier = SMTVerifier(TREE_DEPTH);
    smtVerifier.root <== slaveMerkleRoot;
    smtVerifier.leaf <== modulusHasher.out;
    smtVerifier.key <== modulusHasher.out;
    smtVerifier.siblings <== slaveMerkleInclusionBranches;

    smtVerifier.isVerified === 1;

    passedVerificationFlowsRSA   <== accumulatorRSAFlows[NUMBER_RSA_FLOWS - 1];
    passedVerificationFlowsECDSA <== accumulatorECDSAFlows[NUMBER_ECDSA_FLOWS - 1];
}