pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../rsa/rsa.circom";
include "../merkleTree/merkleTree.circom";

template PassportHashVerifier(w, nb, e_bits, hashLen, dg1DigestLen, depth) {
    signal input encapsulatedContent[2688];
    signal input dg1Digest[dg1DigestLen];
    signal input signedAttributes[592];
    signal input exp[nb];
    signal input sign[nb];
    signal input modulus[nb];
    signal input icaoMerkleRoot;
    signal input icaoMerkleInclusionBranches[depth];
    signal input icaoMerkleInclusionOrder[depth];

    // Check DG1 hash inclusion
    var DG1_SHIFT = 248;
    for (var i = 0; i < dg1DigestLen; i++) {
        encapsulatedContent[DG1_SHIFT + i] === dg1Digest[i];
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

    component pubKeyHasher = Poseidon(16);

    for (var i = 0; i < 16; i++) {
        pubKeyHasher.inputs[i] <== modulus[i];
    }

    component merkleTreeVerifier = MerkleTreeVerifier(depth);
    
    merkleTreeVerifier.leaf <== pubKeyHasher.out;
    merkleTreeVerifier.merkleRoot <== icaoMerkleRoot;
    merkleTreeVerifier.merkleBranches <== icaoMerkleInclusionBranches;
    merkleTreeVerifier.merkleOrder <== icaoMerkleInclusionOrder;

    // TODO: improve key packing to include more bits. Current hashed bits = 16 * 64 = 1024.
    // var numberBlocks = (nb + 2) \ 3;
    // var BLOCK_SIZE = 3;
    // component rsaPubKeyHasher[nb];
    // signal totalHash;
    // signal lastValue;


    // for (var i = 0; i < nb; i++) {
    //     // var currentIndex = i * 3;

    //     if (i == 0) {
    //         rsaPubKeyHasher[i] = Poseidon(1);
    //         rsaPubKeyHasher.inputs[0] <== modulus[i];
    //     } else {
    //         rsaPubKeyHasher[i] = Poseidon(2);
    //         rsaPubKeyHasher[i].inputs[0] <== rsaPubKeyHasher[i-1].out;
    //         rsaPubKeyHasher[i].inputs[1] <== modulus[i];
    //         // rsaPubKeyHasher[i].in[1] <== modulus[currentIndex] + modulus[currentIndex] * 2**64 + modulus[currentIndex] * 2**128;
    //         // currentHash[i] <== rsaPubKeyHasher[i].out;
    //     } 
    //     // else {
        //     var residualBlocks = nb - (numberBlocks - 1) * BLOCK_SIZE;

        //     if (residualBlocks == 1) {
        //         lastValue <== modulus[currentIndex];
        //     } else if (residualBlocks == 2) {
        //         lastValue <== modulus[currentIndex] + modulus[currentIndex] * 2**64;
        //     } else {
        //         lastValue <== modulus[currentIndex] + modulus[currentIndex] * 2**64 + modulus[currentIndex] * 2**128;
        //     }
        //     rsaPubKeyHasher[i].in[0] <== currentHash[i - 1];
        //     rsaPubKeyHasher[i].in[1] <== lastValue;
            
        //     currentHash[i] <== rsaPubKeyHasher[i].out;
        // }
        // rsaPubKeyHasher.input[i] <== modulus[currentIndex] + modulus[currentIndex] * 2**64 + modulus[currentIndex] * 2**128;
    // }

    // signal rsaPubKeyHash <== rsaPubKeyHasher.out;
}

component main = PassportHashVerifier(64, 64, 17, 4, 256, 3);
