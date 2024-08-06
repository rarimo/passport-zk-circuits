pragma circom  2.1.6;

include "../rsa/rsa.circom";
include "../passportVerification/utils/sha1.circom";
include "circomlib/circuits/bitify.circom";

template RsaSha1ActiveAuthentication(w, nb, e_bits) {
    // signal output pubKeyHash;
    // signal output signatureHash;

    signal input modulus[nb];
    signal input signature[nb];
    signal input challenge;

    // RSA signature verification
    component rsaDecryptor = PowerMod(w, nb, e_bits);
    for (var i = 0; i < nb; i++) {
        rsaDecryptor.base[i] <== signature[i];
        rsaDecryptor.modulus[i] <== modulus[i];
    }

    for (var i = 0; i < nb; i++) {
        log(rsaDecryptor.out[i]);
    }

}

component main = RsaSha1ActiveAuthentication(64, 16, 17);