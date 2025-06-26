pragma circom  2.1.6;

include "../bitify/bitify.circom";
include "../bitify/comparators.circom";
include "./bigIntFunc.circom";
include "../utils/switcher.circom";

// Calculates 2 numbers with CHUNK_NUMBER multiplication using karatsuba method
// out is overflowed
// Use only for CHUNK_NUMBER in 2 ** k (powers of 2), othewise you will get error
template KaratsubaOverflow(CHUNK_NUMBER) {
    signal input in[2][CHUNK_NUMBER];
    signal output out[2 * CHUNK_NUMBER];
    
    if (CHUNK_NUMBER == 1) {
        out[0] <== in[0][0] * in[1][0];
    } else {
        component karatsubaA1B1 = KaratsubaOverflow(CHUNK_NUMBER / 2);
        component karatsubaA2B2 = KaratsubaOverflow(CHUNK_NUMBER / 2);
        component karatsubaA1A2B1B2 = KaratsubaOverflow(CHUNK_NUMBER / 2);
        
        for (var i = 0; i < CHUNK_NUMBER / 2; i++) {
            karatsubaA1B1.in[0][i] <== in[0][i];
            karatsubaA1B1.in[1][i] <== in[1][i];
            karatsubaA2B2.in[0][i] <== in[0][i + CHUNK_NUMBER / 2];
            karatsubaA2B2.in[1][i] <== in[1][i + CHUNK_NUMBER / 2];
            karatsubaA1A2B1B2.in[0][i] <== in[0][i] + in[0][i + CHUNK_NUMBER / 2];
            karatsubaA1A2B1B2.in[1][i] <== in[1][i] + in[1][i + CHUNK_NUMBER / 2];
        }
        
        for (var i = 0; i < 2 * CHUNK_NUMBER; i++) {
            if (i < CHUNK_NUMBER) {
                if (CHUNK_NUMBER / 2 <= i && i < 3 * (CHUNK_NUMBER / 2)) {
                    out[i] <== karatsubaA1B1.out[i]
                    + karatsubaA1A2B1B2.out[i - CHUNK_NUMBER / 2]
                    - karatsubaA1B1.out[i - CHUNK_NUMBER / 2]
                    - karatsubaA2B2.out[i - CHUNK_NUMBER / 2];
                } else {
                    out[i] <== karatsubaA1B1.out[i];
                }
            } else {
                if (CHUNK_NUMBER / 2 <= i && i < 3 * (CHUNK_NUMBER / 2)) {
                    out[i] <== karatsubaA2B2.out[i - CHUNK_NUMBER]
                    + karatsubaA1A2B1B2.out[i - CHUNK_NUMBER / 2]
                    - karatsubaA1B1.out[i - CHUNK_NUMBER / 2]
                    - karatsubaA2B2.out[i - CHUNK_NUMBER / 2];
                } else {
                    out[i] <== karatsubaA2B2.out[i - CHUNK_NUMBER];
                }
            }
        }
    }
}

template BigMultNonEqualOverflow(CHUNK_SIZE, CHUNK_NUMBER_GREATER, CHUNK_NUMBER_LESS){
    
    assert(CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS <= 252);
    assert(CHUNK_NUMBER_GREATER >= CHUNK_NUMBER_LESS);
    
    signal input in1[CHUNK_NUMBER_GREATER];
    signal input in2[CHUNK_NUMBER_LESS];
    
    signal output out[CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS - 1];
    
    
    // We can`t mult multiply 2 big nums without multiplying each chunks of first with each chunk of second
    
    signal tmpMults[CHUNK_NUMBER_GREATER][CHUNK_NUMBER_LESS];
    for (var i = 0; i < CHUNK_NUMBER_GREATER; i++){
        for (var j = 0; j < CHUNK_NUMBER_LESS; j++){
            tmpMults[i][j] <== in1[i] * in2[j];
        }
    }
    
    // left - in1[idx], right - in2[idx]  || n - CHUNK_NUMBER_GREATER, m - CHUNK_NUMBER_LESS
    // 0*0 0*1 ... 0*n
    // 1*0 1*1 ... 1*n
    //  ⋮   ⋮    \   ⋮
    // m*0 m*1 ... m*n
    //
    // result[idx].length = count(i+j === idx)
    // result[0].length = 1 (i = 0; j = 0)
    // result[1].length = 2 (i = 1; j = 0; i = 0; j = 1);
// result[i].length = { result[i-1].length + 1,  i <= CHUNK_NUMBER_LESS}
//                    {  result[i-1].length - 1,  i > CHUNK_NUMBER_GREATER}
//                    {  result[i-1].length,      CHUNK_NUMBER_LESS < i <= CHUNK_NUMBER_GREATER}
    
    signal tmpResult[CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS - 1][CHUNK_NUMBER_LESS];
    
    for (var i = 0; i < CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS - 1; i++){
        
        if (i < CHUNK_NUMBER_LESS){
            for (var j = 0; j < i + 1; j++){
                if (j == 0){
                    tmpResult[i][j] <== tmpMults[i - j][j];
                } else {
                    tmpResult[i][j] <== tmpMults[i - j][j] + tmpResult[i][j - 1];
                }
            }
            out[i] <== tmpResult[i][i];
            
        } else {
            if (i < CHUNK_NUMBER_GREATER) {
                for (var j = 0; j < CHUNK_NUMBER_LESS; j++){
                    if (j == 0){
                        tmpResult[i][j] <== tmpMults[i - j][j];
                    } else {
                        tmpResult[i][j] <== tmpMults[i - j][j] + tmpResult[i][j - 1];
                    }
                }
                out[i] <== tmpResult[i][CHUNK_NUMBER_LESS - 1];
            } else {
                for (var j = 0; j < CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS - 1 - i; j++){
                    if (j == 0){
                        tmpResult[i][j] <== tmpMults[CHUNK_NUMBER_GREATER - 1 - j][i + j - CHUNK_NUMBER_GREATER + 1];
                    } else {
                        tmpResult[i][j] <== tmpMults[CHUNK_NUMBER_GREATER - 1 - j][i + j - CHUNK_NUMBER_GREATER + 1] + tmpResult[i][j - 1];
                    }
                }
                out[i] <== tmpResult[i][CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS - 2 - i];
            }
        }
    }
}

// Internal template. Don`t use it outside of remove overflow template
// in <- chunk value, chunk sign
// out -> chunk without overflow, overflow
template ProcessChunk(CHUNK_SIZE, MAX_CHUNK_SIZE){
    // sign == 0 if positive else 1
    signal input sign;
    signal input in;
    signal output overflow;
    signal output out;
    
    component getDiv;
    component getMod;
    component num2Bits;
    component isZero;
    component zeroSwitcher;
    component modSwitcher;
    
    // Selects mod or 2 ** CHUNK_SIZE - mod (inverse mod)
    modSwitcher = Switcher();
    zeroSwitcher = Switcher();
    isZero = IsZero();
    num2Bits = Num2Bits(MAX_CHUNK_SIZE + 1);
    getMod = Bits2Num(CHUNK_SIZE);
    getDiv = Bits2Num(MAX_CHUNK_SIZE - CHUNK_SIZE + 1);
    
    // in if in > 0 else - in
    num2Bits.in <== in * (- 2 * sign + 1);
    for (var j = 0; j < CHUNK_SIZE; j++)
    {
        getMod.in[j] <== num2Bits.out[j];
    }
    
    isZero.in <== getMod.out;
    
    modSwitcher.in[0] <== getMod.out;
    modSwitcher.in[1] <== 2 ** CHUNK_SIZE - getMod.out;
    modSwitcher.bool <== sign;
    
    // Handling negative numbers modulus
    // Example: (-7 % 4) = 1 (div -2), while (7 % 4) = 3
    //  correct:   -2 * 4 + 1 == -7
    //  incorrect: -1 * 4 - 3 == -7 (mod >=0)
    // We make mod = (modulus - mod) and increase div value by 1 in case mod != 0
    // If it is zero we do nothing
    zeroSwitcher.bool <== isZero.out;
    zeroSwitcher.in[0] <== modSwitcher.out[0];
    zeroSwitcher.in[1] <== 0;
    
    out <== zeroSwitcher.out[0];
    
    for (var j = 0; j < MAX_CHUNK_SIZE - CHUNK_SIZE + 1; j++){
        getDiv.in[j] <== num2Bits.out[j + CHUNK_SIZE];
    }
    
    // Add 1 for negative div with non-zero modulus
    overflow <== getDiv.out + sign * (1 - isZero.out);
    
}

// Removes overflow from BigNum
//  input <- CHUNK_NUMBER of chunks with MAX_CHUNK_SIZE bits each (|input| < 2 ** MAX_CHUNK_SIZE)
//  out -> MAX_CHUNK_NUMBER of chunks with CHUNK_SIZE each
// If input is negative only last chunk of out will be negative
template RemoveOverflow(CHUNK_SIZE, MAX_CHUNK_SIZE, CHUNK_NUMBER, MAX_CHUNK_NUMBER){
    assert (CHUNK_NUMBER <= MAX_CHUNK_NUMBER);
    
    signal input in[CHUNK_NUMBER];
    signal output out[MAX_CHUNK_NUMBER];
    
    signal signs[MAX_CHUNK_SIZE];
    signal overflows[MAX_CHUNK_NUMBER];
    component processChunk[MAX_CHUNK_NUMBER - 1];
    
    
    for (var i = 0; i < CHUNK_NUMBER; i++){
        if (i != MAX_CHUNK_NUMBER - 1){
            processChunk[i] = ProcessChunk(CHUNK_SIZE, MAX_CHUNK_SIZE);
        }
        if (i == 0){
            // For element of $in is first chunk
            signs[i] <-- is_negative_chunk(in[i], MAX_CHUNK_SIZE);
            signs[i] * (1 - signs[i]) === 0;
            
            processChunk[i].in <== in[i];
            processChunk[i].sign <== signs[i];
            
            out[i] <== processChunk[i].out;
            overflows[i] <== processChunk[i].overflow;
        } else {
            if (i != MAX_CHUNK_NUMBER - 1){
                // For non-first or last chunks $in is chunk + previous chunk overflow
                signs[i] <-- is_negative_chunk(in[i] + overflows[i - 1] * (-2 * signs[i - 1] + 1), MAX_CHUNK_SIZE);
                signs[i] * (1 - signs[i]) === 0;
                
                processChunk[i].in <== in[i] + overflows[i - 1] * (-2 * signs[i - 1] + 1);
                processChunk[i].sign <== signs[i];
                
                out[i] <== processChunk[i].out;
                overflows[i] <== processChunk[i].overflow;
            } else {
                // For the last chunk in case of same size of result and input: out = chunk + previous overflow
                out[i] <== in[i] + overflows[i - 1] * (-2 * signs[i - 1] + 1);
            }
            
        }
    }
    for (var i = CHUNK_NUMBER; i < MAX_CHUNK_NUMBER; i++){
        if (i != MAX_CHUNK_NUMBER - 1){
            processChunk[i] = ProcessChunk(CHUNK_SIZE, MAX_CHUNK_SIZE);
            signs[i] <-- is_negative_chunk(overflows[i - 1] * (-2 * signs[i - 1] + 1), MAX_CHUNK_SIZE);
            signs[i] * (1 - signs[i]) === 0;
            
            processChunk[i].in <== overflows[i - 1] * (-2 * signs[i - 1] + 1);
            processChunk[i].sign <== signs[i];
            
            out[i] <== processChunk[i].out;
            overflows[i] <== processChunk[i].overflow;
            
        } else {
            // For the last chunk in case of different size of result and input we put previous overflow
            out[i] <== overflows[i - 1] * (- 2 * signs[i - 1] + 1);
        }
    }
}
