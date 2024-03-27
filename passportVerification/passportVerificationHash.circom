pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../rsa/rsa.circom";
include "../merkleTree/merkleTree.circom";

template PassportVerificationHash(w, nb, e_bits, hashLen, depth) {
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

    // Hash DG1 -> SHA256
    component dg1Hasher = Sha256(744);
    
    for (var i = 0; i < 744; i++) {
        dg1Hasher.in[i] <== dg1[i];
    }

    // Hash DG15 -> SHA256
    component dg15Hasher = Sha256(1320);

    for (var i = 0; i < 1320; i++) {
        dg15Hasher.in[i] <== dg15[i];
    }

    // Check DG1 hash inclusion into encapsulatedContent
    var DG1_SHIFT = 248;
    for (var i = 0; i < hashLen * nb; i++) {
        encapsulatedContent[DG1_SHIFT + i] === dg1Hasher.out[i];
    }

    // Check DG15 hash inclusion into encapsulatedContent
    var DG15_SHIFT = 2432;
    for (var i = 0; i < hashLen * nb; i++) {
        encapsulatedContent[DG15_SHIFT + i] === dg15Hasher.out[i];
    }
    
    // Hash encupsulated content
    component encapsulatedContentHasher = Sha256(2688);
    encapsulatedContentHasher.in <== encapsulatedContent;

    // signedAttributes passport hash == encapsulatedContent hash

    for (var i = 0; i < 256; i++) {
        encapsulatedContentHasher.out[i] === signedAttributes[592-256+i];
    }

    // Hashing signedAttributes
    component signedAttributesHasher = Sha256(592);
    signedAttributesHasher.in <== signedAttributes;

    component rsaVerifier = RsaVerifyPkcs1v15(w, nb, e_bits, hashLen);

    rsaVerifier.exp <== exp;
    rsaVerifier.sign <== sign;
    rsaVerifier.modulus <== modulus;

    signal signedAttributesHashChunks[hashLen];
    component signedAttributesHashPacking[hashLen];
    for (var i = 0; i < hashLen; i++) {
        signedAttributesHashPacking[i] = Bits2Num(w);
        for (var j = 0; j < w; j++) {
            signedAttributesHashPacking[i].in[j] <== signedAttributesHasher.out[i * w + j];
        }
        signedAttributesHashChunks[i] <== signedAttributesHashPacking[i].out;
    }

    rsaVerifier.hashed <== signedAttributesHashChunks;

    component pubKeyHasher[4];

    for (var j = 0; j < 4; j++) {
        pubKeyHasher[j] = Poseidon(16);
        for (var i = 0; i < 16; i++) {
            pubKeyHasher[j].inputs[i] <== modulus[j * 16 + i];
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

component main = PassportVerificationHash(64, 64, 17, 4, 3);
