pragma circom  2.1.6;

include "../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";
include "../rsa/rsa.circom";

// slaveSignedAttributesLen - 9864
// nb - 64
// signedAttributesKeyShift - 3552
template X509Verifier(w, nb, e_bits, hashLen, slaveSignedAttributesLen, signedAttributesKeyShift) {
    signal input slaveSignedAttributes[slaveSignedAttributesLen];
    signal input slaveSignature[nb];
    signal input masterModulus[nb];

    component slaveHasher = Sha256(slaveSignedAttributesLen);
    slaveHasher.in <== slaveSignedAttributes;
    
    component rsaVerifier = RsaVerifyPkcs1v15(w, nb, e_bits, hashLen);
    rsaVerifier.sign <== slaveSignature;
    rsaVerifier.modulus <== masterModulus;

    signal slaveSignedAttributesHashChunks[hashLen];
    component signedAttributesHashPacking[hashLen];
    for (var i = 0; i < hashLen; i++) {
        signedAttributesHashPacking[i] = Bits2Num(w);
        for (var j = 0; j < w; j++) {
            signedAttributesHashPacking[i].in[w - 1 - j] <== slaveHasher.out[i * w + j];
        }
        slaveSignedAttributesHashChunks[(hashLen - 1) - i] <== signedAttributesHashPacking[i].out;
    }

    rsaVerifier.hashed <== slaveSignedAttributesHashChunks;

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
    
    // log(pubKeyHasherTotal.out);

}

// component main = X509Verifier(64, 64, 17, 4, 9864, 3552);