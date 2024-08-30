pragma circom 2.1.6;

include "../rsaPss/rsaPss.circom";

template PassportVerificationRSAPSSSignature(w, nb, e_bits, hashLen) {
    signal input signedAttributesHash[hashLen * w];
    signal input sign[nb];
    signal input modulus[nb];

    component rsaVerifier = VerifyRSASig(w, nb, e_bits, hashLen * w);

    rsaVerifier.signature <== sign;
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

    rsaVerifier.hashed <== signedAttributesHash;
}