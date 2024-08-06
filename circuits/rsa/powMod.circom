pragma circom 2.1.6;
 
include "./bigInt.circom";

// w = 32
// e_bits = 17
// nb is the length of the base and modulus
// calculates (base^exp) % modulus, exp = 2^(e_bits - 1) + 1 = 2^16 + 1
template PowerMod(w, nb, e_bits) {
    assert(e_bits >= 2);

    signal input base[nb];
    signal input modulus[nb];

    signal output out[nb];

    component muls[e_bits];

    for (var i = 0; i < e_bits; i++) {
        muls[i] = BigMultModP(w, nb);

        for (var j = 0; j < nb; j++) {
            muls[i].p[j] <== modulus[j];
        }
    }

    for (var i = 0; i < nb; i++) {
        muls[0].a[i] <== base[i];
        muls[0].b[i] <== base[i];
    }

    for (var i = 1; i < e_bits - 1; i++) {
        for (var j = 0; j < nb; j++) {
            muls[i].a[j] <== muls[i - 1].out[j];
            muls[i].b[j] <== muls[i - 1].out[j];
        }
    }

    for (var i = 0; i < nb; i++) {
        muls[e_bits - 1].a[i] <== base[i];
        muls[e_bits - 1].b[i] <== muls[e_bits - 2].out[i];
    }

    for (var i = 0; i < nb; i++) {
        out[i] <== muls[e_bits - 1].out[i];
    }
}
