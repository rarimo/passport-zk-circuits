pragma circom 2.1.6;

include "../rsa/rsa.circom";
include "../sha256/sha256NoPadding.circom";

template PassportVerificationRSASignature(w, nb, e_bits, hashLen, SIGNED_ATTRIBUTES_SIZE) {
    signal input signedAttributesHash[hashLen * w];
    signal input sign[nb];
    signal input modulus[nb];

    component rsaVerifier = RsaVerifyPkcs1v15(w, nb, e_bits, hashLen);

    rsaVerifier.sign <== sign;
    rsaVerifier.modulus <== modulus;

    signal signedAttributesHashChunks[hashLen];
    component signedAttributesHashPacking[hashLen];
    for (var i = 0; i < hashLen; i++) {
        signedAttributesHashPacking[i] = Bits2Num(w);
        for (var j = 0; j < w; j++) {
            signedAttributesHashPacking[i].in[w - 1 - j] <== signedAttributesHash[i * w + j];
        }
        signedAttributesHashChunks[(hashLen - 1) - i] <== signedAttributesHashPacking[i].out;
    }

    rsaVerifier.hashed <== signedAttributesHashChunks;
}