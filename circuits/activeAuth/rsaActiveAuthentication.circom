pragma circom  2.1.6;

include "../rsa/rsa.circom";
include "../passportVerification/utils/sha1.circom";
include "circomlib/circuits/bitify.circom";

template RsaSha1ActiveAuthentication(CHUNK_SIZE, CHUNK_NUMBER, E_BITS) {
    // signal output pubKeyHash;
    // signal output signatureHash;

    signal input modulus[CHUNK_NUMBER];
    signal input signature[CHUNK_NUMBER];
    signal input challenge;

    // RSA signature verification
    component rsaDecryptor = PowerMod(CHUNK_SIZE, CHUNK_NUMBER, E_BITS);
    for (var i = 0; i < CHUNK_NUMBER; i++) {
        rsaDecryptor.base[i] <== signature[i];
        rsaDecryptor.modulus[i] <== modulus[i];
    }

}

component main = RsaSha1ActiveAuthentication(64, 16, 17);