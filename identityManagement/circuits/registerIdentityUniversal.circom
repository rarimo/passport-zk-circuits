pragma circom  2.1.6;

include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../passportVerification/passportVerificationHashPadded.circom";
include "../../node_modules/circomlib/circuits/babyjub.circom";

template RegisterIdentityUniversal(w, nb, e_bits, hashLen, depth, encapsulatedContentLen, dg1Shift, dg15Shift, dg15Len, signedAttributesLen, slaveSignedAttributesLen, signedAttributesKeyShift) {
    signal output dg15PubKeyHash;
    signal output dg1Commitment;
    signal output pkIdentityHash;

    signal input encapsulatedContent[encapsulatedContentLen]; // 2688 bits
    signal input dg1[1024];                  // 744 bits
    signal input dg15[dg15Len];             // 1320 bits
    signal input signedAttributes[signedAttributesLen];     // 592 bits
    signal input exp[nb];
    signal input sign[nb];
    signal input modulus[nb];
    signal input slaveMerkleRoot;
    signal input slaveMerkleInclusionBranches[depth];
    signal input skIdentity;
    signal input ecdsaShiftEnabled;
    signal input saTimestampEnabled;

    // ----
    signal ecdsaShiftDisabled <== (1 - ecdsaShiftEnabled);
    ecdsaShiftDisabled * ecdsaShiftEnabled === 0;
    // ----

    component passportVerifier = 
        PassportVerificationHashPadded(w, nb, e_bits, hashLen, depth, encapsulatedContentLen, dg1Shift, dg15Shift, dg15Len, signedAttributesLen, slaveSignedAttributesLen, signedAttributesKeyShift);

    passportVerifier.encapsulatedContent <== encapsulatedContent;
    passportVerifier.dg1 <== dg1;
    passportVerifier.dg15 <== dg15;
    passportVerifier.signedAttributes <== signedAttributes;
    passportVerifier.sign <== sign;
    passportVerifier.modulus <== modulus;
    passportVerifier.slaveMerkleRoot <== slaveMerkleRoot;
    passportVerifier.slaveMerkleInclusionBranches <== slaveMerkleInclusionBranches;
    passportVerifier.ecdsaShiftEnabled <== ecdsaShiftEnabled;
    passportVerifier.saTimestampEnabled <== saTimestampEnabled;

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
    
    signal dg15HasherECDSATemp <== dg15HasherECDSA.out * ecdsaShiftEnabled;
    signal dg15HasherRSATemp <== dg15HasherRSA.out * ecdsaShiftDisabled;
    
    dg15PubKeyHash <== dg15HasherECDSATemp + dg15HasherRSATemp;
    
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