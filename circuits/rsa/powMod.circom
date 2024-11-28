pragma circom 2.1.6;
 
include "../bigInt/bigInt.circom";

// CHUNK_NUMBER is the length of the base and modulus
// calculates (base^exp) % modulus, exp = 2^(E_BITS - 1) + 1 = 2^16 + 1
template PowerMod(CHUNK_SIZE, CHUNK_NUMBER, E_BITS) {
    assert(E_BITS >= 2);

    signal input base[CHUNK_NUMBER];
    signal input modulus[CHUNK_NUMBER];

    signal output out[CHUNK_NUMBER];

    component muls[E_BITS];

    for (var i = 0; i < E_BITS; i++) {
        muls[i] = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER);

        for (var j = 0; j < CHUNK_NUMBER; j++) {
            muls[i].p[j] <== modulus[j];
        }
    }

    for (var i = 0; i < CHUNK_NUMBER; i++) {
        muls[0].a[i] <== base[i];
        muls[0].b[i] <== base[i];
    }

    for (var i = 1; i < E_BITS - 1; i++) {
        for (var j = 0; j < CHUNK_NUMBER; j++) {
            muls[i].a[j] <== muls[i - 1].out[j];
            muls[i].b[j] <== muls[i - 1].out[j];
        }
    }

    for (var i = 0; i < CHUNK_NUMBER; i++) {
        muls[E_BITS - 1].a[i] <== base[i];
        muls[E_BITS - 1].b[i] <== muls[E_BITS - 2].out[i];
    }

    for (var i = 0; i < CHUNK_NUMBER; i++) {
        out[i] <== muls[E_BITS - 1].out[i];
    }
}

// CHUNK_NUMBER is the length of the base and modulus
// calculates (base^exp) % modulus, exp = 2^(E_BITS - 1) + 1 = 2^16 + 1
template PowerMod37187(CHUNK_SIZE, CHUNK_NUMBER) {

    signal input base[CHUNK_NUMBER];
    signal input modulus[CHUNK_NUMBER];

    signal output out[CHUNK_NUMBER];

    component muls[15];
    component resultMuls[5];

    for (var i = 0; i < 15; i++) {
        muls[i] = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER);

        for (var j = 0; j < CHUNK_NUMBER; j++) {
            muls[i].p[j] <== modulus[j];
        }
    }

    for (var i = 0; i < 5; i++) {
        resultMuls[i] = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER);

        for (var j = 0; j < CHUNK_NUMBER; j++) {
            resultMuls[i].p[j] <== modulus[j];
        }
    }


    for (var i = 0; i < CHUNK_NUMBER; i++) {
        muls[0].a[i] <== base[i];
        muls[0].b[i] <== base[i];
    }

    for (var i = 1; i < 15; i++) {
        for (var j = 0; j < CHUNK_NUMBER; j++) {
            muls[i].a[j] <== muls[i - 1].out[j];
            muls[i].b[j] <== muls[i - 1].out[j];
        }
    }

    resultMuls[0].a <== muls[14].out; // 32768
    resultMuls[0].b <== muls[11].out; // 4096
    resultMuls[1].a <== resultMuls[0].out; // 32768 + 4096
    resultMuls[1].b <== muls[7].out; // 256
    resultMuls[2].a <== resultMuls[1].out; // 32768 + 4096 + 256
    resultMuls[2].b <== muls[5].out; // 64
    resultMuls[3].a <== resultMuls[2].out; // 32768 + 4096 + 256 + 64 
    resultMuls[3].b <== muls[0].out; // 2
    resultMuls[4].a <== resultMuls[3].out; // 32768 + 4096 + 256 + 64 + 2
    resultMuls[4].b <== base; // 1


    for (var i = 0; i < CHUNK_NUMBER; i++) {
        out[i] <== resultMuls[4].out[i];
    }
}


template GetLastBit(){
    signal input in;
    signal output bit;
    signal output div;
    
    bit <-- in % 2;
    div <-- in \ 2;
    
    (1 - bit) * bit === 0;
    div * 2 + bit * bit === in;
}

template GetLastNBits(N){
    signal input in;
    signal output div;
    signal output out[N];
    
    component getLastBit[N];
    for (var i = 0; i < N; i++){
        getLastBit[i] = GetLastBit();
        if (i == 0){
            getLastBit[i].in <== in;
        } else {
            getLastBit[i].in <== getLastBit[i - 1].div;
        }
        out[i] <== getLastBit[i].bit;
    }
    
    div <== getLastBit[N - 1].div;
}
