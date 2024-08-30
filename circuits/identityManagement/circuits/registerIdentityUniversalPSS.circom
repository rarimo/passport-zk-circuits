pragma circom  2.1.6;

include "circomlib/circuits/bitify.circom";
include "../../passportVerification/passportVerificationHashPaddedPSS.circom";
include "circomlib/circuits/babyjub.circom";

template RegisterIdentityUniversal(BLOCK_SIZE, NUMBER_OF_BLOCKS, E_BITS, HASH_BLOCKS_NUMBER, TREE_DEPTH, DG1_COMMITMENT_SIZE) {
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

    // OUTPUT SIGNALS:
    // RSA: Poseidon5(200, 200, 200, 200, 224bits) | ECDSA: Poseidon2 (X[:31bytes], Y[:31bytes])
    signal output dg15PubKeyHash;

    signal output passportHash;

    // Poseidon5(186, 186, 186, 186bits, Poseidon(skIdentity))
    signal output dg1Commitment;

    // Poseidon2(PubKey.X, PubKey.Y)
    signal output pkIdentityHash;

    // INPUT SIGNALS
    signal input encapsulatedContent[ENCAPSULATED_CONTENT_SIZE];   // 2688 / 2704 bits
    signal input dg1[DG1_SIZE];                            // 744 bits
    signal input dg15[DG15_SIZE];                          // 1320 / 2520 bits
    signal input signedAttributes[SIGNED_ATTRIBUTES_SIZE]; // 592 / 832 bits
    signal input sign[NUMBER_OF_BLOCKS];
    signal input modulus[NUMBER_OF_BLOCKS];
    signal input slaveMerkleRoot;   // public
    signal input slaveMerkleInclusionBranches[TREE_DEPTH];
    signal input skIdentity;

    // ---------
    component passportVerifier = 
        PassportVerificationHashPadded(BLOCK_SIZE, NUMBER_OF_BLOCKS, E_BITS, HASH_BLOCKS_NUMBER, TREE_DEPTH);

    passportVerifier.encapsulatedContent <== encapsulatedContent;
    passportVerifier.dg1 <== dg1;
    passportVerifier.dg15 <== dg15;
    passportVerifier.signedAttributes <== signedAttributes;
    passportVerifier.sign <== sign;
    passportVerifier.modulus <== modulus;
    passportVerifier.slaveMerkleRoot <== slaveMerkleRoot;
    passportVerifier.slaveMerkleInclusionBranches <== slaveMerkleInclusionBranches;

    // ---------
    component passedVerificationFlowsRSAIsZero = IsZero();
    component passedVerificationFlowsECDSAIsZero = IsZero();
    component passedVerificationFlowsNoAAIsZero = IsZero();
    
    passedVerificationFlowsRSAIsZero.in <== passportVerifier.passedVerificationFlowsRSA;
    passedVerificationFlowsECDSAIsZero.in <== passportVerifier.passedVerificationFlowsECDSA;
    passedVerificationFlowsNoAAIsZero.in <== passportVerifier.passedVerificationFlowsNoAA;
    log("passedVerificationFlowsRSA: ", passportVerifier.passedVerificationFlowsRSA);
    log("passedVerificationFlowsECDSA: ", passportVerifier.passedVerificationFlowsECDSA);
    log("passedVerificationFlowsNoAA: ", passportVerifier.passedVerificationFlowsNoAA);

    signal failedFlowsRSAandECDSA <== passedVerificationFlowsRSAIsZero.out + passedVerificationFlowsECDSAIsZero.out;
    // 2-of-3 should fail, 1 should pass
    component verificationFlowsIsZero = IsZero();
    verificationFlowsIsZero.in <== passedVerificationFlowsNoAAIsZero.out + failedFlowsRSAandECDSA;
    verificationFlowsIsZero.out === 0; // valid flows != 0

    // ---------

    // RSA HASHING
    component dg15Chunking[5];
    var DG15_PK_SHIFT = 256; // shift in ASN1 encoded content to pk value

    // 1024 bit RSA key is splitted into | 200 bit | 200 bit | 200 bit | 200 bit | 224 bit |
    var CHUNK_SIZE = 200;
    var LAST_CHUNK_SIZE = 224;
    for (var j = 0; j < 4; j++) {
        dg15Chunking[j] = Bits2Num(CHUNK_SIZE);
        for (var i = 0; i < CHUNK_SIZE; i++) {
            dg15Chunking[j].in[CHUNK_SIZE - 1 - i] <== dg15[DG15_PK_SHIFT + j * CHUNK_SIZE + i];
        }
    }

    dg15Chunking[4] = Bits2Num(LAST_CHUNK_SIZE);
    for (var i = 0; i < LAST_CHUNK_SIZE; i++) {
        dg15Chunking[4].in[LAST_CHUNK_SIZE - 1 - i] <== dg15[DG15_PK_SHIFT + 4 * CHUNK_SIZE + i];
    }

    // Poseidon5 is applied on chunks
    component dg15HasherRSA = Poseidon(5);
    for (var i = 0; i < 5; i++) {
        dg15HasherRSA.inputs[i] <== dg15Chunking[i].out;
    }

    // ---------
    
    // ECDSA HASHING
    component xToNum = Bits2Num(248);
    component yToNum = Bits2Num(248);
    
    var EC_FIELD_SIZE = 256;
    var PK_POINT_POSITION = 2008;

    for (var i = 0; i < 248; i++) {
        xToNum.in[247-i] <== dg15[PK_POINT_POSITION + i + 8];
        yToNum.in[247-i] <== dg15[PK_POINT_POSITION + EC_FIELD_SIZE + i + 8];
    }

    component dg15HasherECDSA = Poseidon(2);
    
    dg15HasherECDSA.inputs[0] <== xToNum.out;
    dg15HasherECDSA.inputs[1] <== yToNum.out;
    
    signal dg15HasherECDSATemp <== dg15HasherECDSA.out * (1 - passedVerificationFlowsECDSAIsZero.out);
    signal dg15HasherRSATemp <== dg15HasherRSA.out * (1 - passedVerificationFlowsRSAIsZero.out);
    
    dg15PubKeyHash <== dg15HasherECDSATemp + dg15HasherRSATemp;
    passportHash   <== passportVerifier.passportHash;

    // ---------
    
    // dg1Commitment: DG1 hash 744 bits => 4 * 186
    var DG1_COMMITMENT_CHUNK_SIZE = 186;
    if (DG1_COMMITMENT_SIZE == 760) {
        DG1_COMMITMENT_CHUNK_SIZE = 190;
    }
    component dg1Chunking[4];
    component dg1Hasher = Poseidon(5);
    for (var i = 0; i < 4; i++) {
        dg1Chunking[i] = Bits2Num(DG1_COMMITMENT_CHUNK_SIZE);
        for (var j = 0; j < DG1_COMMITMENT_CHUNK_SIZE; j++) {
            dg1Chunking[i].in[j] <== dg1[i * DG1_COMMITMENT_CHUNK_SIZE + j]; 
        }
        dg1Hasher.inputs[i] <== dg1Chunking[i].out;
    }

    component skIndentityHasher = Poseidon(1);   //skData = Poseidon(skIdentity)
    skIndentityHasher.inputs[0] <== skIdentity;
    dg1Hasher.inputs[4] <== skIndentityHasher.out;

    dg1Commitment <== dg1Hasher.out;


    // Forming EdDSA BybyJubJub public key point from private key (identity)
    component pkIdentityCalc = BabyPbk();
    pkIdentityCalc.in <== skIdentity;
    
    component pkIdentityHasher = Poseidon(2);
    pkIdentityHasher.inputs[0] <== pkIdentityCalc.Ax;
    pkIdentityHasher.inputs[1] <== pkIdentityCalc.Ay;
    
    pkIdentityHash <== pkIdentityHasher.out;
}