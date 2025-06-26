pragma circom 2.1.6;

include "./utils.circom";
include "./permutations.circom";

template Pad(LEN) {
    signal input in[LEN];
    
    var WORD_SIZE = 64;
    var STATE_SIZE = WORD_SIZE * 25;
    var BLOCK_SIZE = STATE_SIZE - 2 * 256;
    signal output out[BLOCK_SIZE];
    signal out2[BLOCK_SIZE];
    
    for (var i = 0; i < LEN; i++) {
        out2[i] <== in[i];
    }
    var domain = 0x01;
    for (var i = 0; i < 8; i++) {
        out2[LEN + i] <== (domain >> i) & 1;
    }
    for (var i = LEN + 8; i < BLOCK_SIZE; i++) {
        out2[i] <== 0;
    }
    component aux = OrArray(8);
    for (var i = 0; i < 8; i++) {
        aux.a[i] <== out2[BLOCK_SIZE - 8 + i];
        aux.b[i] <== (0x80 >> i) & 1;
    }
    for (var i = 0; i < 8; i++) {
        out[BLOCK_SIZE - 8 + i] <== aux.out[i];
    }
    for (var i = 0; i < BLOCK_SIZE - 8; i++) {
        out[i] <== out2[i];
    }
}

template KeccakfRound(r) {
    var WORD_SIZE = 64;
    var STATE_SIZE = WORD_SIZE * 25;
    signal input in[STATE_SIZE];
    signal output out[STATE_SIZE];
    
    
    component theta = Theta();
    component rhopi = RhoPi();
    component chi = Chi();
    component iota = Iota(r);
    
    for (var i = 0; i < STATE_SIZE; i++) {
        theta.in[i] <== in[i];
    }
    for (var i = 0; i < STATE_SIZE; i++) {
        rhopi.in[i] <== theta.out[i];
    }
    for (var i = 0; i < STATE_SIZE; i++) {
        chi.in[i] <== rhopi.out[i];
    }
    for (var i = 0; i < STATE_SIZE; i++) {
        iota.in[i] <== chi.out[i];
    }
    for (var i = 0; i < STATE_SIZE; i++) {
        out[i] <== iota.out[i];
    }
}

template Absorb() {
    var WORD_SIZE = 64;
    var STATE_SIZE = WORD_SIZE * 25;
    var BLOCK_SIZE = STATE_SIZE - 2 * 256;
    var BLOCK_SIZE_BYTES = BLOCK_SIZE \ 8;
    
    signal input s[STATE_SIZE];
    signal input block[BLOCK_SIZE_BYTES * 8];
    signal output out[STATE_SIZE];
    
    component aux[BLOCK_SIZE_BYTES / 8];
    component newS = Keccakf();
    
    for (var i = 0; i < BLOCK_SIZE_BYTES / 8; i++) {
        aux[i] = XorArray(WORD_SIZE);
        for (var j = 0; j < WORD_SIZE; j++) {
            aux[i].a[j] <== s[i * WORD_SIZE + j];
            aux[i].b[j] <== block[i * WORD_SIZE + j];
        }
        for (var j = 0; j < WORD_SIZE; j++) {
            newS.in[i * WORD_SIZE + j] <== aux[i].out[j];
        }
    }

    for (var i = (BLOCK_SIZE_BYTES / 8) * WORD_SIZE; i < STATE_SIZE; i++) {
        newS.in[i] <== s[i];
    }
    for (var i = 0; i < STATE_SIZE; i++) {
        out[i] <== newS.out[i];
    }
}

template Final(LEN) {
    var WORD_SIZE = 64;
    var STATE_SIZE = WORD_SIZE * 25;
    var BLOCK_SIZE = STATE_SIZE - 2 * 256;
    var BLOCK_SIZE_BYTES = BLOCK_SIZE \ 8;

    signal input in[LEN];
    signal output out[STATE_SIZE];
    
    
    // pad
    component pad = Pad(LEN);
    for (var i = 0; i < LEN; i++) {
        pad.in[i] <== in[i];
    }
    // absorb
    component abs = Absorb();
    for (var i = 0; i < BLOCK_SIZE; i++) {
        abs.block[i] <== pad.out[i];
    }
    for (var i = 0; i < STATE_SIZE; i++) {
        abs.s[i] <== 0;
    }
    for (var i = 0; i < STATE_SIZE; i++) {
        out[i] <== abs.out[i];
    }
}

template Squeeze(LEN) {
    var WORD_SIZE = 64;
    var STATE_SIZE = WORD_SIZE * 25;
    var BLOCK_SIZE = STATE_SIZE - 2 * 256;

    signal input s[STATE_SIZE];
    signal output out[LEN];
    

    
    for (var i = 0; i < 25; i++) {
        for (var j = 0; j < WORD_SIZE; j++) {
            if (i * WORD_SIZE + j < LEN) {
                out[i * WORD_SIZE + j] <== s[i * WORD_SIZE + j];
            }
        }
    }
}

template Keccakf() {
    var WORD_SIZE = 64;
    var STATE_SIZE = WORD_SIZE * 25;
    var BLOCK_SIZE = STATE_SIZE - 2 * 256;
    var ROUND_COUNT = 24;

    signal input in[STATE_SIZE];
    signal output out[STATE_SIZE];
    

    
    component round[ROUND_COUNT];
    signal midRound[ROUND_COUNT * STATE_SIZE];
    for (var i = 0; i < ROUND_COUNT; i++) {
        round[i] = KeccakfRound(i);
        if (i == 0) {
            for (var j = 0; j < STATE_SIZE; j++) {
                midRound[j] <== in[j];
            }
        }
        for (var j = 0; j < STATE_SIZE; j++) {
            round[i].in[j] <== midRound[i * STATE_SIZE + j];
        }
        if (i < 23) {
            for (var j = 0; j < STATE_SIZE; j++) {
                midRound[(i + 1) * STATE_SIZE + j] <== round[i].out[j];
            }
        }
    }
    
    for (var i = 0; i < STATE_SIZE; i++) {
        out[i] <== round[23].out[i];
    }
}

template Keccak(LEN, ALGO) {
    var WORD_SIZE = 64;
    var STATE_SIZE = WORD_SIZE * 25;
    var BLOCK_SIZE = STATE_SIZE - 2 * 256;

    signal input in[LEN];
    signal output out[ALGO];
    
    
    component f = Final(LEN);
    for (var i = 0; i < LEN; i++) {
        f.in[i] <== in[i];
    }
    component squeeze = Squeeze(ALGO);
    for (var i = 0; i < STATE_SIZE; i++) {
        squeeze.s[i] <== f.out[i];
    }
    for (var i = 0; i < ALGO; i++) {
        out[i] <== squeeze.out[i];
    }
}

template HashKeccakBits(LEN, ALGO){
    signal input in[LEN];
    signal output out[ALGO];
    
    assert(ALGO == 256 || ALGO == 384);
    assert(LEN % 8 == 0);
    
    component hasher = Keccak(LEN, ALGO);
    for (var i = 0; i < LEN \ 8; i++) {
        for (var j = 0; j < 8; j++) {
            hasher.in[8 * i + j] <== in[8 * i + (7 - j)];
        }
    }
    
    for (var i = 0; i < ALGO \ 8; i++) {
        for (var j = 0; j < 8; j++) {
            out[8 * i + j] <== hasher.out[8 * (i + 1) - j - 1];
        }
    }
}
