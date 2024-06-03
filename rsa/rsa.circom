pragma circom 2.1.6;

include "./powMod.circom";
include "../node_modules/circomlib/circuits/bitify.circom";

// Pkcs1v15 + Sha256, e = 65537
template RsaVerifyPkcs1v15(w, nb, e_bits, hashLen) {
    signal input sign[nb];
    signal input modulus[nb];

    signal input hashed[hashLen];

    // sign ** exp mod modulus
    component pm = PowerMod(w, nb, e_bits);
    for (var i  = 0; i < nb; i++) {
        pm.base[i] <== sign[i];
        pm.modulus[i] <== modulus[i];
    }

    // 1. Check hashed data
    for (var i = 0; i < hashLen; i++) {
        hashed[i] === pm.out[i];
    }
    
    // 2. Check hash prefix and 1 byte 0x00
    pm.out[4] === 217300885422736416;
    pm.out[5] === 938447882527703397;

    // remain 24 bit
    component num2bits_6 = Num2Bits(w);
    num2bits_6.in <== pm.out[6];
    var remainsBits[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0];
    for (var i = 0; i < 32; i++) {
        num2bits_6.out[i] === remainsBits[31 - i];
    }

    // 3. Check PS and em[1] = 1
    for (var i = 32; i < w; i++) {
        num2bits_6.out[i] === 1;
    }

    for (var i = 7; i < nb-1; i++) {
        pm.out[i] === 18446744073709551615; // 0b1111111111111111111111111111111111111111111111111111111111111111
    }
}
