pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../rsaPss/rsaPss.circom";
// include "../sha256/sha256NoPadding.circom";
include "../hasher/passportHash.circom";
include "../merkleTree/SMTVerifier.circom";
include "./passportVerificationFlow.circom";
include "./passportVerificationRSAPSSsignature.circom";

template PassportVerificationHashPadded(BLOCK_SIZE, NUMBER_OF_BLOCKS, E_BITS, SALT_LEN, HASH_BLOCKS_NUMBER, TREE_DEPTH) {
    // *magic numbers* list
    var DG1_SIZE = 1024;                        // bits
    var DG15_SIZE = 3072;                       // 1320 rsa | 
    var SIGNED_ATTRIBUTES_SIZE = 1024;          // 592
    var ENCAPSULATED_CONTENT_SIZE = 3072;       // 5 blocks
    var DG1_DIGEST_POSITION_SHIFT = 248;
    var DG15_DIGEST_POSITION_SHIFT = 2432; 
    var DG1_DIGEST_POSITION_SHIFT_PARAMS_ANY = DG1_DIGEST_POSITION_SHIFT + 16;
    var DG1_DIGEST_POSITION_SHIFT_LEFT = DG1_DIGEST_POSITION_SHIFT - 16;
    var DG15_DIGEST_POSITION_SHIFT_PARAMS_ANY = DG15_DIGEST_POSITION_SHIFT + 16;
    var DG15_DIGEST_POSITION_SHIFT_1496 = 1496;
    var DG15_DIGEST_POSITION_SHIFT_1184 = 1184;
    var DG15_DIGEST_POSITION_SHIFT_1176 = 1176;
    var DG15_DIGEST_POSITION_SHIFT_1168 = 1168;
    var SIGNED_ATTRIBUTES_SHIFT = 336;
    var SIGNED_ATTRIBUTES_SHIFT_TS = 576;
    var SIGNED_ATTRIBUTES_SHIFT_600 = 600;
    // ---------
    var NUMBER_RSA_FLOWS = 6;
    var NUMBER_ECDSA_FLOWS = 2;
    var NUMBER_NoAA_FLOWS = 5;
    var HASH_SIZE = BLOCK_SIZE * HASH_BLOCKS_NUMBER; // 64 * 4 = 256 (SHA256)
    var HASH_BLOCK_SIZE = 512;   // SHA 256 hashing block size
    
    // ------------------

    // output signals
    signal output passedVerificationFlowsRSA;
    signal output passedVerificationFlowsECDSA;
    signal output passedVerificationFlowsNoAA;
    signal output passportHash;

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
    component dg1Hasher = PassportHash(512, 2, 256);
    for (var i = 0; i < DG1_SIZE; i++) {
        dg1Hasher.in[i] <== dg1[i];
    }

    // Hash DG15 -> DG15Hash (SHA256). Hashing all 6 blocks (ECDSA case)
    component dg15Hasher6Blocks = PassportHash(512, 6, 256);
    dg15Hasher6Blocks.in <== dg15;


    component dg15Hasher5Blocks = PassportHash(512, 5, 256);
    for (var i = 0; i < HASH_BLOCK_SIZE * 5; i++) {
        dg15Hasher5Blocks.in[i] <== dg15[i];
    }

    component dg15Hasher4Blocks = PassportHash(512, 4, 256);
    for (var i = 0; i < HASH_BLOCK_SIZE * 4; i++) {
        dg15Hasher4Blocks.in[i] <== dg15[i];
    }
    

    // Hash DG15 -> DG15Hash (SHA256). Hashing first 3 blocks (RSA case)
    component dg15Hasher3Blocks = PassportHash(512, 3, 256);
    for (var i = 0; i < HASH_BLOCK_SIZE * 3; i++) {
        dg15Hasher3Blocks.in[i] <== dg15[i];
    }

    // Hash encupsulated content
    component encapsulatedContentHasher6Blocks = PassportHash(512, 6, 256);
    encapsulatedContentHasher6Blocks.in <== encapsulatedContent;

    // Hash encupsulated content (first 3 blocks)
    component encapsulatedContentHasher3Blocks = PassportHash(512, 3, 256);
    for (var i = 0; i < HASH_BLOCK_SIZE * 3; i++) {
        encapsulatedContentHasher3Blocks.in[i] <== encapsulatedContent[i];
    }

    // Hash encapsulated content (first 4 blocks)
    component encapsulatedContentHasher4Blocks = PassportHash(512, 4, 256);
    for (var i = 0; i < HASH_BLOCK_SIZE * 4; i++) {
        encapsulatedContentHasher4Blocks.in[i] <== encapsulatedContent[i];
    }

    // Hash encapsulated content (first 5 blocks)
    component encapsulatedContentHasher5Blocks = PassportHash(512, 5, 256);
    for (var i = 0; i < HASH_BLOCK_SIZE * 5; i++) {
        encapsulatedContentHasher5Blocks.in[i] <== encapsulatedContent[i];
    }

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
    passportVerificationFlowRsa1.encapsulatedContentHash <== encapsulatedContentHasher6Blocks.out;
    passportVerificationFlowRsa1.signedAttributes <== signedAttributes;
    passportVerificationFlowRsa1.dg15Verification <== 1;
    
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
    passportVerificationFlowRsa2.encapsulatedContentHash <== encapsulatedContentHasher6Blocks.out;
    passportVerificationFlowRsa2.signedAttributes <== signedAttributes;
    passportVerificationFlowRsa2.dg15Verification <== 1;
    
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
    passportVerificationFlowRsa3.encapsulatedContentHash <== encapsulatedContentHasher6Blocks.out;
    passportVerificationFlowRsa3.signedAttributes <== signedAttributes;
    passportVerificationFlowRsa3.dg15Verification <== 1;
    
    log("Flow 3: ", passportVerificationFlowRsa3.flowResult);
    accumulatorRSAFlows[2] <== accumulatorRSAFlows[1] + passportVerificationFlowRsa3.flowResult;

    // FLOW 4
    // with Parameters any NULL | with signed attributes timestamp 600 | DG15 3 blocks
    component passportVerificationFlowRsa4 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT_PARAMS_ANY,
        DG15_DIGEST_POSITION_SHIFT_1496,
        SIGNED_ATTRIBUTES_SHIFT_600
    );
    passportVerificationFlowRsa4.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowRsa4.dg15Hash <== dg15Hasher3Blocks.out;
    passportVerificationFlowRsa4.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowRsa4.encapsulatedContentHash <== encapsulatedContentHasher4Blocks.out;
    passportVerificationFlowRsa4.signedAttributes <== signedAttributes;
    passportVerificationFlowRsa4.dg15Verification <== 1;
    
    log("Flow 4: ", passportVerificationFlowRsa4.flowResult);
    accumulatorRSAFlows[3] <== accumulatorRSAFlows[2] + passportVerificationFlowRsa4.flowResult;


    // FLOW 5
    // with Parameters any NULL | with signed attributes timestamp | DG15 5 blocks
    component passportVerificationFlowRsa5 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT,
        DG15_DIGEST_POSITION_SHIFT_1184,
        SIGNED_ATTRIBUTES_SHIFT_TS
    );
    passportVerificationFlowRsa5.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowRsa5.dg15Hash <== dg15Hasher5Blocks.out;
    passportVerificationFlowRsa5.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowRsa5.encapsulatedContentHash <== encapsulatedContentHasher3Blocks.out;
    passportVerificationFlowRsa5.signedAttributes <== signedAttributes;
    passportVerificationFlowRsa5.dg15Verification <== 1;
    
    log("Flow 5: ", passportVerificationFlowRsa5.flowResult);
    accumulatorRSAFlows[4] <== accumulatorRSAFlows[3] + passportVerificationFlowRsa5.flowResult;

    // ------------------
    // FLOW 6
    // with Parameters any NULL | with signed attributes timestamp | DG15 4 blocks
    component passportVerificationFlowRsa6 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        248,
        1808,
        576
    );
    passportVerificationFlowRsa6.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowRsa6.dg15Hash <== dg15Hasher4Blocks.out;
    passportVerificationFlowRsa6.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowRsa6.encapsulatedContentHash <== encapsulatedContentHasher5Blocks.out;
    passportVerificationFlowRsa6.signedAttributes <== signedAttributes;
    passportVerificationFlowRsa6.dg15Verification <== 1;
    
    log("Flow 6: ", passportVerificationFlowRsa6.flowResult);
    accumulatorRSAFlows[5] <== accumulatorRSAFlows[4] + passportVerificationFlowRsa6.flowResult;

    // ------------------
   
    // ECDSA FLOWS
    signal accumulatorECDSAFlows[NUMBER_ECDSA_FLOWS];
    
    // FLOW 1
    // with Parameters any NULL | no signed attributes timestamp | DG15 6 blocks
    component passportVerificationFlowEcdsa1 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT,
        DG15_DIGEST_POSITION_SHIFT_PARAMS_ANY,
        SIGNED_ATTRIBUTES_SHIFT
    );
    passportVerificationFlowEcdsa1.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowEcdsa1.dg15Hash <== dg15Hasher6Blocks.out;
    passportVerificationFlowEcdsa1.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowEcdsa1.encapsulatedContentHash <== encapsulatedContentHasher6Blocks.out;
    passportVerificationFlowEcdsa1.signedAttributes <== signedAttributes;
    passportVerificationFlowEcdsa1.dg15Verification <== 1;
    
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
    passportVerificationFlowEcdsa2.encapsulatedContentHash <== encapsulatedContentHasher6Blocks.out;
    passportVerificationFlowEcdsa2.signedAttributes <== signedAttributes;
    passportVerificationFlowEcdsa2.dg15Verification <== 1;
    
    log("Flow 2 (ECDSA): ", passportVerificationFlowEcdsa2.flowResult);
    accumulatorECDSAFlows[1] <== accumulatorECDSAFlows[0] + passportVerificationFlowEcdsa2.flowResult;

    // -----------------

    // NO AA FLOWS
    signal accumulatorNoAAFlows[NUMBER_NoAA_FLOWS];
    
    // FLOW 1
    // with Parameters any NULL | no signed attributes timestamp | DG15 6 blocks
    component passportVerificationFlowNoAA1 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT_PARAMS_ANY,
        DG15_DIGEST_POSITION_SHIFT_PARAMS_ANY,
        SIGNED_ATTRIBUTES_SHIFT
    );
    passportVerificationFlowNoAA1.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowNoAA1.dg15Hash <== dg15Hasher6Blocks.out;
    passportVerificationFlowNoAA1.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowNoAA1.encapsulatedContentHash <== encapsulatedContentHasher3Blocks.out;
    passportVerificationFlowNoAA1.signedAttributes <== signedAttributes;
    passportVerificationFlowNoAA1.dg15Verification <== 0;
    
    log("Flow 1 (NoAA): ", passportVerificationFlowNoAA1.flowResult);
    accumulatorNoAAFlows[0] <== passportVerificationFlowNoAA1.flowResult;

    // FLOW 2
    // no Parameters any NULL | with signed attributes timestamp | DG15 6 blocks
    component passportVerificationFlowNoAA2 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT,
        DG15_DIGEST_POSITION_SHIFT,
        SIGNED_ATTRIBUTES_SHIFT_TS
    );
    passportVerificationFlowNoAA2.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowNoAA2.dg15Hash <== dg15Hasher6Blocks.out;
    passportVerificationFlowNoAA2.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowNoAA2.encapsulatedContentHash <== encapsulatedContentHasher3Blocks.out;
    passportVerificationFlowNoAA2.signedAttributes <== signedAttributes;
    passportVerificationFlowNoAA2.dg15Verification <== 0;
    
    log("Flow 2 (NoAA): ", passportVerificationFlowNoAA2.flowResult);
    accumulatorNoAAFlows[1] <== accumulatorNoAAFlows[0] + passportVerificationFlowNoAA2.flowResult;

    // -----------------

    // FLOW 3
    // no Parameters any NULL | with signed attributes timestamp | DG15 5 blocks
    component passportVerificationFlowNoAA3 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT,
        DG15_DIGEST_POSITION_SHIFT,
        SIGNED_ATTRIBUTES_SHIFT_TS
    );
    passportVerificationFlowNoAA3.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowNoAA3.dg15Hash <== dg15Hasher6Blocks.out;
    passportVerificationFlowNoAA3.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowNoAA3.encapsulatedContentHash <== encapsulatedContentHasher5Blocks.out;
    passportVerificationFlowNoAA3.signedAttributes <== signedAttributes;
    passportVerificationFlowNoAA3.dg15Verification <== 0;
    
    log("Flow 3 (NoAA): ", passportVerificationFlowNoAA3.flowResult);
    accumulatorNoAAFlows[2] <== accumulatorNoAAFlows[1] + passportVerificationFlowNoAA3.flowResult;

    // -----------------

    // FLOW 4
    // with left shift  | without signed attributes timestamp | DG15 3 blocks | EC 4 blocks
    component passportVerificationFlowNoAA4 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT_LEFT,
        DG15_DIGEST_POSITION_SHIFT_PARAMS_ANY,
        SIGNED_ATTRIBUTES_SHIFT
    );
    passportVerificationFlowNoAA4.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowNoAA4.dg15Hash <== dg15Hasher6Blocks.out;
    passportVerificationFlowNoAA4.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowNoAA4.encapsulatedContentHash <== encapsulatedContentHasher4Blocks.out;
    passportVerificationFlowNoAA4.signedAttributes <== signedAttributes;
    passportVerificationFlowNoAA4.dg15Verification <== 0;
    
    log("Flow 4 (NoAA): ", passportVerificationFlowNoAA4.flowResult);
    accumulatorNoAAFlows[3] <== accumulatorRSAFlows[2] + passportVerificationFlowNoAA4.flowResult;
    // FLOW 5
    // with Parameters any NULL | with signed attributes timestamp | DG15 6 blocks
    component passportVerificationFlowNoAA5 = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT_LEFT,
        256,
        SIGNED_ATTRIBUTES_SHIFT
    );
    
    passportVerificationFlowNoAA5.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowNoAA5.dg15Hash <== dg15Hasher6Blocks.out;
    passportVerificationFlowNoAA5.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowNoAA5.encapsulatedContentHash <== encapsulatedContentHasher3Blocks.out;
    passportVerificationFlowNoAA5.signedAttributes <== signedAttributes;
    passportVerificationFlowNoAA5.dg15Verification <== 0;
    
    log("Flow 5 (NoAA): ", passportVerificationFlowNoAA5.flowResult);
    accumulatorNoAAFlows[4] <== accumulatorNoAAFlows[3] + passportVerificationFlowNoAA5.flowResult;

    // ------------------

    // Hashing signedAttributes
    component signedAttributesHasher = PassportHash(512, 2, 256);
    signedAttributesHasher.in <== signedAttributes;

    // Calculating passportHash = Poseidon(SHA256(signedAttributes)[252bit])
    component signedAttributesNum = Bits2Num(252);
    for (var i = 0; i < 252; i++) {
        signedAttributesNum.in[i] <== signedAttributesHasher.out[i];
    }
    component signedAttributesHashHasher = Poseidon(1);
    signedAttributesHashHasher.inputs[0] <== signedAttributesNum.out;
    passportHash <== signedAttributesHashHasher.out;

    // Verifying passport signature
    // component passportVerificationRSASignature = 
    //     PassportVerificationRSASignature(BLOCK_SIZE, NUMBER_OF_BLOCKS, E_BITS, HASH_BLOCKS_NUMBER, SIGNED_ATTRIBUTES_SIZE);
    // passportVerificationRSASignature.signedAttributesHash <== signedAttributesHasher.out;
    // passportVerificationRSASignature.sign <== sign;
    // passportVerificationRSASignature.modulus <== modulus;

    component passportVericationRSAPssSignature = VerifyRsaSig(BLOCK_SIZE, NUMBER_OF_BLOCKS, SALT_LEN, E_BITS, 256);
        passportVericationRSAPssSignature.pubkey <== modulus;
        passportVericationRSAPssSignature.signature <== sign;
        passportVericationRSAPssSignature.hashed <== signedAttributesHasher.out;

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
    passedVerificationFlowsNoAA  <== accumulatorNoAAFlows[NUMBER_NoAA_FLOWS - 1];
}