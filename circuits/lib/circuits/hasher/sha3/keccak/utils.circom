pragma circom 2.1.6;

include "../../../bitify/bitGates.circom";
include "../../sha2/sha2Common.circom";

template ShiftRight(n, r) {
    signal input in[n];
    signal output out[n];
    
    for (var i = 0; i < n; i++) {
        if (i + r >= n) {
            out[i] <== 0;
        } else {
            out[i] <== in[i + r];
        }
    }
}

template Xor5(n) {
    signal input a[n];
    signal input b[n];
    signal input c[n];
    signal input d[n];
    signal input e[n];
    signal output out[n];
    
    component xor3 = XOR3_v3(n);
    for (var i = 0; i < n; i++) {
        xor3.a[i] <== a[i];
        xor3.b[i] <== b[i];
        xor3.c[i] <== c[i];
    }
    component xor4 = XorArray(n);
    for (var i = 0; i < n; i++) {
        xor4.a[i] <== xor3.out[i];
        xor4.b[i] <== d[i];
    }
    component xor5 = XorArray(n);
    for (var i = 0; i < n; i++) {
        xor5.a[i] <== xor4.out[i];
        xor5.b[i] <== e[i];
    }
    for (var i = 0; i < n; i++) {
        out[i] <== xor5.out[i];
    }
}

template XorArray(n) {
    signal input a[n];
    signal input b[n];
    signal output out[n];
    
    component aux[n];
    for (var i = 0; i < n; i++) {
        aux[i] = XOR();
        aux[i].in[0] <== a[i];
        aux[i].in[1] <== b[i];
    }
    for (var i = 0; i < n; i++) {
        out[i] <== aux[i].out;
    }
}

template XorArraySingle(n) {
    signal input a[n];
    signal output out[n];
    
    component aux[n];
    for (var i = 0; i < n; i++) {
        aux[i] = XOR();
        aux[i].in[0] <== a[i];
        aux[i].in[1] <== 1;
    }
    for (var i = 0; i < n; i++) {
        out[i] <== aux[i].out;
    }
}

template OrArray(n) {
    signal input a[n];
    signal input b[n];
    signal output out[n];
    
    component aux[n];
    for (var i = 0; i < n; i++) {
        aux[i] = OR();
        aux[i].in[0] <== a[i];
        aux[i].in[1] <== b[i];
    }
    for (var i = 0; i < n; i++) {
        out[i] <== aux[i].out;
    }
}

template AndArray(n) {
    signal input a[n];
    signal input b[n];
    signal output out[n];
    
    component aux[n];
    for (var i = 0; i < n; i++) {
        aux[i] = AND();
        aux[i].in[0] <== a[i];
        aux[i].in[1] <== b[i];
    }
    for (var i = 0; i < n; i++) {
        out[i] <== aux[i].out;
    }
}

template ShiftLeft(n, r) {
    signal input in[n];
    signal output out[n];
    
    for (var i = 0; i < n; i++) {
        if (i < r) {
            out[i] <== 0;
        } else {
            out[i] <== in[i - r];
        }
    }
}
