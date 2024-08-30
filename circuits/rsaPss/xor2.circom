pragma circom 2.1.6;

template Xor2(CHUNK_NUMBER) {
    signal input a[CHUNK_NUMBER];
    signal input b[CHUNK_NUMBER];
    signal output out[CHUNK_NUMBER];

    for (var k = 0; k < CHUNK_NUMBER; k++) {
        out[k] <== a[k] + b[k] - 2 * a[k] * b[k];
    }
}