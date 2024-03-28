pragma circom  2.1.6;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../passportVerification/passportVerificationHash.circom";

template RegisterIdentity(w, nb, e_bits, hashLen, depth) {
    signal output dg15PubKeyHash;

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
    for (var j = 0; j < 4; j++) {
        dg15Chunking[j] = Bits2Num(200);
        for (var i = 0; i < 200; i++) {
            dg15Chunking[j].in[i] <== dg15[DG15_PK_SHIFT + j * 200 + i];
        }
    }

    dg15Chunking[4] = Bits2Num(224);
    for (var i = 0; i < 224; i++) {
        dg15Chunking[4].in[i] <== dg15[DG15_PK_SHIFT + 4 * 200 + i];
    }

    // Poseidon5 is applied on chunks
    component dg15Hasher = Poseidon(5);
    for (var i = 0; i < 5; i++) {
        dg15Hasher.inputs[i] <== dg15Chunking[i].out;
    }

    dg15PubKeyHash <== dg15Hasher.out;
}

component main = RegisterIdentity(64, 64, 17, 4, 20);