pragma circom  2.1.6;

include "../utils/switcher.circom";
include "../bitify/comparators.circom";
include "../bitify/bitify.circom";
include "../bitify/bitGates.circom";
include "../int/arithmetic.circom";

// result = 0
// while b:
//     if b & 1:
//         result ^= a  
//     b >>= 1
//     a <<= 1
//     if a & (1 << m):  
//         a ^= reduction_poly
// return result

// template BinFieldMult(FIELD_SIZE, REDUCTION_POLY){
//     signal input in1[FIELD_SIZE];
//     signal input in2[FIELD_SIZE];
    
//     signal output out[FIELD_SIZE];
    
//     signal tempRes[FIELD_SIZE][FIELD_SIZE * 2];
//     signal tempA[FIELD_SIZE][FIELD_SIZE * 2];
//     signal tempA2[FIELD_SIZE][FIELD_SIZE * 2];
    
    
//     component isZero[FIELD_SIZE];
//     component isOne[FIELD_SIZE];
//     component isOneA[FIELD_SIZE];
//     component bits2Num[FIELD_SIZE];
    
//     component xor[FIELD_SIZE][FIELD_SIZE * 2];
//     component xor2[FIELD_SIZE][FIELD_SIZE * 2];
    
//     component bSwitcher[FIELD_SIZE][FIELD_SIZE * 2];
//     component aSwitcher[FIELD_SIZE][FIELD_SIZE * 2];
    
//     for (var i = 0; i < FIELD_SIZE; i++){
//         bits2Num[i] = Bits2Num(FIELD_SIZE - i);
//         for (var j = 0; j < FIELD_SIZE - i; j++){
//             bits2Num[i].in[j] <== in2[j + i];
//         }
//         isZero[i] = IsZero();
//         isZero[i].in <== bits2Num[i].out;
        
//         isOne[i] = IsEqual();
//         isOne[i].in[0] <== 1;
//         isOne[i].in[1] <== bits2Num[i].in[0];
        
        
//         for (var j = 0; j < FIELD_SIZE + i; j++){
//             xor[i][j] = XOR();
//             if (i == 0){
//                 xor[i][j].in[0] <== 0;
//                 xor[i][j].in[1] <== in1[j];
//             } else {
//                 xor[i][j].in[0] <== tempRes[i - 1][j];
//                 xor[i][j].in[1] <== aSwitcher[i - 1][j].out[0];
//             }
//             bSwitcher[i][j] = Switcher();
//             bSwitcher[i][j].in[0] <== xor[i][j].in[0];
//             bSwitcher[i][j].in[1] <== xor[i][j].out;
//             bSwitcher[i][j].bool <== isOne[i].out;
//             tempRes[i][j] <== bSwitcher[i][j].out[0];
//         }
        
//         tempRes[i][FIELD_SIZE + i] <== 0;
        
//         tempA[i][0] <== 0;
//         for (var j = 1; j < FIELD_SIZE + i + 1; j++){
//             if (i == 0){
//                 tempA[i][j] <== in1[j - 1];
//             } else {
//                 tempA[i][j] <== tempA[i - 1][j - 1];
//             }
//         }
        
//         isOneA[i] = IsEqual();
//         isOneA[i].in[0] <== 1;
//         isOneA[i].in[1] <== tempA[i][162];
        
//         for (var j = 0; j < FIELD_SIZE + i + 1; j++){
//             xor2[i][j] = XOR();
           
//             xor2[i][j].in[0] <== REDUCTION_POLY[j];
//             xor2[i][j].in[1] <== tempA[i][j];
            
//             aSwitcher[i][j] = Switcher();
//             aSwitcher[i][j].in[0] <== tempA[i][j];
//             aSwitcher[i][j].in[1] <== xor2[i][j].out;
//             aSwitcher[i][j].bool <== isOneA[i].out;
//         }
//     }
// }

template Hui(FIELD_SIZE, REDUCTION_POLY){
    assert(FIELD_SIZE == 163);
    signal input in1[FIELD_SIZE];
    signal input in2[FIELD_SIZE];

    signal tempA[FIELD_SIZE];
    signal tempB[FIELD_SIZE * 2];

    signal output out;
    
    component sum[FIELD_SIZE];

    for (var i = 0; i < FIELD_SIZE; i++){
        sum[i] = GetSumOfNElements(FIELD_SIZE);
        for (var j = i; j < FIELD_SIZE; j++){
            sum[i].in[j] <== in1[j] * 2 ** (j - i);
        }
        for (var j = 0; j< i; j++){
            sum[i].in[j] <== 0;
        }
        tempA[i] <== sum[i].out;
    }

    component getB = GetSumOfNElements(FIELD_SIZE);
    for (var i = 0; i < FIELD_SIZE; i++){
        getB.in[i] <== in2[i] * 2 ** i;
    }
    tempB[0] <== getB.out;
    for (var i = 1; i < FIELD_SIZE \ 2; i++){
        tempB[i] <== tempB[i - 1] * 2;
    }

    // CHANGE THIS IN FUTURE!!!!!!!!
    signal temp_mod <-- tempB[FIELD_SIZE \ 2 - 1] % REDUCTION_POLY;
    signal temp_div <-- tempB[FIELD_SIZE \ 2 - 1] \ REDUCTION_POLY;
    tempB[FIELD_SIZE \ 2] <== temp_mod * 2;
    temp_div * REDUCTION_POLY + temp_mod === tempB[FIELD_SIZE \ 2 - 1];

    for (var i = FIELD_SIZE \ 2 + 1; i < FIELD_SIZE; i++){
        tempB[i] <== tempB[i - 1] * 2;
    }

    signal tempRes[FIELD_SIZE + 1];
    tempRes[0] <== 0;
    component isZero[FIELD_SIZE]; // for check a > 0
    component isOne[FIELD_SIZE]; // for checking a % 2 == 1;

    component switcherZero[FIELD_SIZE];
    component switcherOne[FIELD_SIZE];

    // CHANGE THIS IN FUTURE!!!!!!!!
    signal temp_mod2; 
    signal temp_div2; 

    for (var i = 0; i < FIELD_SIZE; i++){
        isZero[i] = IsZero();
        isOne[i] = IsEqual();
        isOne[i].in[1] <== 1;
        switcherOne[i] = Switcher();
        switcherZero[i] = Switcher();

        isZero[i].in <== tempA[i];
        isOne[i].in[0] <== in1[i];

        switcherOne[i].in[0] <== tempRes[i];
        switcherOne[i].in[1] <== tempRes[i] + tempB[i];
        switcherOne[i].bool <== isOne[i].out;

        switcherZero[i].in[0] <== switcherOne[i].out[0];
        switcherZero[i].in[1] <== tempRes[i];
        switcherZero[i].bool <== isZero[i].out;

        if (i == (FIELD_SIZE \ 2 - 1)){
            temp_mod2 <-- switcherZero[i].out[0] % REDUCTION_POLY;
            temp_div2 <-- switcherZero[i].out[0] \ REDUCTION_POLY;
            tempRes[i + 1] <== temp_mod2;
            temp_div2 * REDUCTION_POLY + temp_mod2 === switcherZero[i].out[0];

        } else {
            tempRes[i + 1] <== switcherZero[i].out[0];
        }

    }

    signal temp_mod3 <-- tempRes[FIELD_SIZE] % REDUCTION_POLY;
    signal temp_div3 <-- tempRes[FIELD_SIZE] \ REDUCTION_POLY;
    out <== temp_mod3;
    // log(out);
    temp_div3 * REDUCTION_POLY + temp_mod3 === tempRes[FIELD_SIZE];
}