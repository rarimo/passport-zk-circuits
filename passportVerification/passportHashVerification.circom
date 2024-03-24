pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "../rsa/rsa.circom";

template PassportHashVerifier(w, nb, e_bits, hashLen) {
    signal input encapsulatedContent[2688];
    signal input signedAttributes[592];
    signal input exp[nb];
    signal input sign[nb];
    signal input modulus[nb];

    signal input hashed[hashLen];
    
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

    signal signedAttributesHashChunks[4];
    component signedAttributesHashPacking[4];
    for (var i = 0; i < 4; i++) {
        signedAttributesHashPacking[i] = Bits2Num(64);
        for (var j = 0; j < 64; j++) {
            signedAttributesHashPacking[i].in[j] <== signedAttributesHasher.out[i*64+j];
        }
        signedAttributesHashChunks[i] <== signedAttributesHashPacking[i].out;
    }

    rsaVerifier.hashed <== signedAttributesHashChunks;
}

component main = PassportHashVerifier(64, 32, 17, 4);
