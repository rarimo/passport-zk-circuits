pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../rsa/rsa.circom";
include "../sha256/sha256NoPadding.circom";
include "../merkleTree/SMTVerifier.circom";
include "../x509Verification/X509Verifier.circom";
include "./passportVerificationFlow.circom";
include "./passportVerificationRSAsignature.circom";
include "../sha2/sha384/sha384_hash_bits.circom";
include "../rsaPss/rsaPss.circom";

template PassportVerificationHashPadded(BLOCK_SIZE, NUMBER_OF_BLOCKS, E_BITS, HASH_BLOCKS_NUMBER, TREE_DEPTH) {
    // *magic numbers* list
    var DG1_SIZE = 760;                        // bits
    var DG15_SIZE = 1832;                       // 1320 rsa | 
    var SIGNED_ATTRIBUTES_SIZE = 720;          // 592
    var ENCAPSULATED_CONTENT_SIZE = 4152;       // 2688
    var DG1_DIGEST_POSITION_SHIFT = 248;
    var DG15_DIGEST_POSITION_SHIFT = 3768; 
    var SIGNED_ATTRIBUTES_SHIFT = 336;
    // ---------

    var NUMBER_RSA_FLOWS = 1;
    var HASH_SIZE = BLOCK_SIZE * HASH_BLOCKS_NUMBER; // 64 * 6 = 384 (SHA384)
    var HASH_BLOCK_SIZE = 1024;   // SHA 384 hashing block size
    
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
    component dg1Hasher = Sha384_hash_bits(DG1_SIZE);
    dg1Hasher.inp_bits <== dg1;
    
    // Hash DG15 -> DG15Hash (SHA256). Hashing first 3 blocks (RSA case)
    component dg15Hasher = Sha384_hash_bits(DG15_SIZE);
    dg15Hasher.inp_bits <== dg15;

    // Hash encupsulated content
    component encapsulatedContentHasher = Sha384_hash_bits(ENCAPSULATED_CONTENT_SIZE);
    encapsulatedContentHasher.inp_bits <== encapsulatedContent;

    // Hashing signedAttributes
    component signedAttributesHasher = Sha384_hash_bits(SIGNED_ATTRIBUTES_SIZE);
    signedAttributesHasher.inp_bits <== signedAttributes;

    component passportVerificationFlowRsa = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_SIZE,
        HASH_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        DG1_DIGEST_POSITION_SHIFT,
        DG15_DIGEST_POSITION_SHIFT,
        SIGNED_ATTRIBUTES_SHIFT
    );
    passportVerificationFlowRsa.dg1Hash  <== dg1Hasher.out;
    passportVerificationFlowRsa.dg15Hash <== dg15Hasher.out;
    passportVerificationFlowRsa.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlowRsa.encapsulatedContentHash <== encapsulatedContentHasher.out;
    passportVerificationFlowRsa.signedAttributes <== signedAttributes;
    passportVerificationFlowRsa.dg15Verification <== 1;
    
    log("Flow 1: ", passportVerificationFlowRsa.flowResult);

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

    component passportVericationRSAPssSignature = VerifyRSASig(BLOCK_SIZE, NUMBER_OF_BLOCKS, SIGNED_ATTRIBUTES_SIZE);
    passportVericationRSAPssSignature.pubkey <== modulus;
    passportVericationRSAPssSignature.signature <== sign;
    passportVericationRSAPssSignature.message <== signedAttributes;
    
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

    passedVerificationFlowsRSA   <== passportVerificationFlowRsa.flowResult;
    passedVerificationFlowsECDSA <== 0;
    passedVerificationFlowsNoAA  <== 0;
}