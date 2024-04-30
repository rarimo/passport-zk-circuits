pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../rsa/rsa.circom";
include "../merkleTree/merkleTree.circom";
include "../X509Verification/X509Verifier.circom";

// Default (64, 64, 17, 4, 20)
template PassportVerificationHash(w, nb, e_bits, hashLen, depth, encapsulatedContentLen, dg1Shift, dg15Shift, dg15Len, signedAttributesLen, slaveSignedAttributesLen, signedAttributesKeyShift) {
    // *magic numbers* list
    var DG1_SIZE = 744;                          // bits
    var DG15_SIZE = dg15Len;                     // 1320
    var SIGNED_ATTRIBUTES_SIZE = signedAttributesLen; // 592  or 
    var ENCAPSULATED_CONTENT_SIZE = encapsulatedContentLen;  // 2688
    var DG1_DIGEST_POSITION_SHIFT = dg1Shift;    // 248
    var DG15_DIGEST_POSITION_SHIFT = dg15Shift;  // 2432
    var HASH_BITS = nb * hashLen; // 64 * 4 = 256 (SHA256)
    // ------------------

    // input signals
    signal input encapsulatedContent[ENCAPSULATED_CONTENT_SIZE];
    signal input dg1[DG1_SIZE];
    signal input dg15[DG15_SIZE];
    signal input signedAttributes[SIGNED_ATTRIBUTES_SIZE];
    signal input sign[nb];
    signal input modulus[nb];
    signal input icaoMerkleRoot;
    signal input icaoMerkleInclusionBranches[depth];
    signal input icaoMerkleInclusionOrder[depth];
    signal input slaveSignedAttributes[slaveSignedAttributesLen];
    signal input slaveSignature[nb];
    signal input masterModulus[nb];

    // -------

    // Hash DG1 -> SHA256
    component dg1Hasher = Sha256(DG1_SIZE);
    
    for (var i = 0; i < DG1_SIZE; i++) {
        dg1Hasher.in[i] <== dg1[i];
    }

    // Hash DG15 -> SHA256
    component dg15Hasher = Sha256(DG15_SIZE);

    for (var i = 0; i < DG15_SIZE; i++) {
        dg15Hasher.in[i] <== dg15[i];
    }

    // Check DG1 hash inclusion into encapsulatedContent
    
    for (var i = 0; i < hashLen * nb; i++) {
        encapsulatedContent[DG1_DIGEST_POSITION_SHIFT + i] === dg1Hasher.out[i];
    }

    // Check DG15 hash inclusion into encapsulatedContent
    
    for (var i = 0; i < hashLen * nb; i++) {
        encapsulatedContent[DG15_DIGEST_POSITION_SHIFT + i] === dg15Hasher.out[i];
    }
    
    // Hash encupsulated content
    component encapsulatedContentHasher = Sha256(ENCAPSULATED_CONTENT_SIZE);
    encapsulatedContentHasher.in <== encapsulatedContent;

    // signedAttributes passport hash == encapsulatedContent hash

    for (var i = 0; i < HASH_BITS; i++) {
        encapsulatedContentHasher.out[i] === signedAttributes[SIGNED_ATTRIBUTES_SIZE-HASH_BITS+i];
    }

    // Hashing signedAttributes
    component signedAttributesHasher = Sha256(SIGNED_ATTRIBUTES_SIZE);
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

    // Verify X509 certificate for a public key used to sign a passport
    component x509Verifier = X509Verifier(64, 64, 17, 4, 9864, 3552);
    x509Verifier.slaveSignedAttributes <== slaveSignedAttributes;
    x509Verifier.slaveSignature <== slaveSignature;
    x509Verifier.masterModulus <== masterModulus;

    // -------

    component pubKeyHasher[4];

    for (var j = 0; j < 4; j++) {
        pubKeyHasher[j] = Poseidon(16);
        for (var i = 0; i < 16; i++) {
            pubKeyHasher[j].inputs[i] <== masterModulus[j * 16 + i];
        }
    }

    component pubKeyHasherTotal = Poseidon(4);

    for (var j = 0; j < 4; j++) {
        pubKeyHasherTotal.inputs[j] <== pubKeyHasher[j].out;
    }

    component merkleTreeVerifier = MerkleTreeVerifier(depth);
    
    merkleTreeVerifier.leaf <== pubKeyHasherTotal.out;
    merkleTreeVerifier.merkleRoot <== icaoMerkleRoot;
    merkleTreeVerifier.merkleBranches <== icaoMerkleInclusionBranches;
    merkleTreeVerifier.merkleOrder <== icaoMerkleInclusionOrder;
}
