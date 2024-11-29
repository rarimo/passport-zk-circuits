pragma circom 2.1.6;
 
include "../bigInt/bigInt.circom";

// CHUNK_NUMBER is the length of the base and modulus
// calculates (base^exp) % modulus, exp = 2^(E_BITS - 1) + 1 = 2^16 + 1
// Deprecated
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

// Deprecated
// template PowerMod37187(CHUNK_SIZE, CHUNK_NUMBER) {

//     signal input base[CHUNK_NUMBER];
//     signal input modulus[CHUNK_NUMBER];

//     signal output out[CHUNK_NUMBER];

//     component muls[15];
//     component resultMuls[5];

//     for (var i = 0; i < 15; i++) {
//         muls[i] = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER);

//         for (var j = 0; j < CHUNK_NUMBER; j++) {
//             muls[i].p[j] <== modulus[j];
//         }
//     }

//     for (var i = 0; i < 5; i++) {
//         resultMuls[i] = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER);

//         for (var j = 0; j < CHUNK_NUMBER; j++) {
//             resultMuls[i].p[j] <== modulus[j];
//         }
//     }


//     for (var i = 0; i < CHUNK_NUMBER; i++) {
//         muls[0].a[i] <== base[i];
//         muls[0].b[i] <== base[i];
//     }

//     for (var i = 1; i < 15; i++) {
//         for (var j = 0; j < CHUNK_NUMBER; j++) {
//             muls[i].a[j] <== muls[i - 1].out[j];
//             muls[i].b[j] <== muls[i - 1].out[j];
//         }
//     }

//     resultMuls[0].a <== muls[14].out; // 32768
//     resultMuls[0].b <== muls[11].out; // 4096
//     resultMuls[1].a <== resultMuls[0].out; // 32768 + 4096
//     resultMuls[1].b <== muls[7].out; // 256
//     resultMuls[2].a <== resultMuls[1].out; // 32768 + 4096 + 256
//     resultMuls[2].b <== muls[5].out; // 64
//     resultMuls[3].a <== resultMuls[2].out; // 32768 + 4096 + 256 + 64 
//     resultMuls[3].b <== muls[0].out; // 2
//     resultMuls[4].a <== resultMuls[3].out; // 32768 + 4096 + 256 + 64 + 2
//     resultMuls[4].b <== base; // 1


//     for (var i = 0; i < CHUNK_NUMBER; i++) {
//         out[i] <== resultMuls[4].out[i];
//         log(out[i]);
//     }

    
// }

template PowerModAnyExp(CHUNK_SIZE, CHUNK_NUMBER, EXP) {
    assert(EXP >= 3);
    
    signal input base[CHUNK_NUMBER];
    signal input modulus[CHUNK_NUMBER];
    
    signal output out[CHUNK_NUMBER];
    
    var exp_process[256] = exp_to_bits(EXP);
    
    component muls[exp_process[0]];
    component resultMuls[exp_process[1] - 1];
    
    for (var i = 0; i < exp_process[0]; i++){
        muls[i] = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER);
        muls[i].p <== modulus;
    }
    
    for (var i = 0; i < exp_process[1] - 1; i++){
        resultMuls[i] = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER);
        resultMuls[i].p <== modulus;
    }
    
    muls[0].a <== base;
    muls[0].b <== base;
    
    for (var i = 1; i < exp_process[0]; i++){
        muls[i].a <== muls[i - 1].out;
        muls[i].b <== muls[i - 1].out;
    }
    
    for (var i = 0; i < exp_process[1] - 1; i++){
        if (i == 0){
            if (exp_process[i + 2] == 0){
                resultMuls[i].a <== base;
            } else {
                resultMuls[i].a <== muls[exp_process[i + 2] - 1].out;
            }
            resultMuls[i].b <== muls[exp_process[i + 3] - 1].out;
        }
        else {
            resultMuls[i].a <== resultMuls[i - 1].out;
            resultMuls[i].b <== muls[exp_process[i + 3] - 1].out;
        }
    }
    if (exp_process[1] == 1){
        out <== muls[exp_process[0] - 1].out;
    } else {
        out <== resultMuls[exp_process[1] - 2].out;
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


function exp_to_bits(exp){
    var mul_num = 0;
    var result_mul_num = 0;
    var indexes[256];
    var bits[254];

    var exp_clone = exp;
    var counter = 0;
    var result_counter;
    while (exp > 0){
        bits[counter] = exp % 2;
        exp = exp \ 2;
        if (bits[counter] == 1) {
            result_mul_num += 1;
            indexes[result_counter+2] = counter;
            result_counter += 1;
        } 
        mul_num += 1;
        counter++;
    }
    indexes[0] = mul_num - 1;
    indexes[1] = result_mul_num;

    return indexes;

}