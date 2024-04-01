pragma circom  2.1.6;

include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../passportVerification/passportVerificationHash.circom";
include "../../node_modules/circomlib/circuits/babyjub.circom";

// pub signals:
// [0]  -  dg15PubKeyHash
// [1]  -  dg1Commitment
// [2]  -  pkIdentityHash
// [3]  -  icaoMerkleRoot
template RegisterIdentity(w, nb, e_bits, hashLen, depth) {
    signal output dg15PubKeyHash;
    signal output dg1Commitment;
    signal output pkIdentityHash;

    signal input encapsulatedContent[2688]; // 2688 bits
    signal input dg1[744];                  // 744 bits
    signal input dg15[1320];                // 1320 bits
    signal input signedAttributes[592];     // 592 bits
    signal input exp[nb];
    signal input sign[nb];
    signal input modulus[nb];
    signal input icaoMerkleRoot;
    signal input icaoMerkleInclusionBranches[depth];
    signal input icaoMerkleInclusionOrder[depth];
    signal input skIdentity;

    component passportVerifier = PassportVerificationHash(w, nb, e_bits, hashLen, depth);

    passportVerifier.encapsulatedContent <== encapsulatedContent;
    passportVerifier.dg1 <== dg1;
    passportVerifier.dg15 <== dg15;
    passportVerifier.signedAttributes <== signedAttributes;
    passportVerifier.exp <== exp;
    passportVerifier.sign <== sign;
    passportVerifier.modulus <== modulus;
    passportVerifier.icaoMerkleRoot <== icaoMerkleRoot;
    passportVerifier.icaoMerkleInclusionBranches <== icaoMerkleInclusionBranches;
    passportVerifier.icaoMerkleInclusionOrder <== icaoMerkleInclusionOrder;

    component dg15Chunking[5];
    var DG15_PK_SHIFT = 248; // shift in ASN1 encoded content to pk value

    // 1024 bit RSA key is splitted into | 200 bit | 200 bit | 200 bit | 200 bit | 224 bit |
    var CHUNK_SIZE = 200;
    var LAST_CHUNK_SIZE = 224;
    for (var j = 0; j < 4; j++) {
        dg15Chunking[j] = Bits2Num(CHUNK_SIZE);
        for (var i = 0; i < CHUNK_SIZE; i++) {
            dg15Chunking[j].in[i] <== dg15[DG15_PK_SHIFT + j * CHUNK_SIZE + i];
        }
    }

    dg15Chunking[4] = Bits2Num(LAST_CHUNK_SIZE);
    for (var i = 0; i < LAST_CHUNK_SIZE; i++) {
        dg15Chunking[4].in[i] <== dg15[DG15_PK_SHIFT + 4 * CHUNK_SIZE + i];
    }

    // Poseidon5 is applied on chunks
    component dg15Hasher = Poseidon(5);
    for (var i = 0; i < 5; i++) {
        dg15Hasher.inputs[i] <== dg15Chunking[i].out;
    }

    dg15PubKeyHash <== dg15Hasher.out;

    // DG1 hash 744 bits => 4 * 186
    component dg1Chunking[4];
    component dg1Hasher = Poseidon(5);
    for (var i = 0; i < 4; i++) {
        dg1Chunking[i] = Bits2Num(186);
        for (var j = 0; j < 186; j++) {
            dg1Chunking[i].in[j] <== dg1[i * 186 + j]; 
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