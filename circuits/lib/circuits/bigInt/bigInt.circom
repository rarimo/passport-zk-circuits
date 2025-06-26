pragma circom  2.1.6;

include "bigIntHelpers.circom";
include "bigIntOverflow.circom";
include "bigIntComparators.circom";
include "../bitify/bitify.circom";

// What BigInt in this lib means
// We represent big number as array of chunks with some shunk_size (will be explained later) 
// for this example we will use N for number, n for chunk size and k for chunk_number:
// N[k];
// Number can be calculated by this formula:
// N = N[0] * 2 ** (0 * n) + N[1] * 2 ** (1 * n) + ... + N[k - 1] * 2 ** ((k-1) * n)
// By overflow we mean situation where N[i] >= 2 ** n
// Without overflow every number has one and only one representation
// To reduce overflow we must leave N[i] % 2 ** n for N[i] and add N[i] // 2 ** n to N[i + 1]
// If u want to do many operation in a row, it is better to use overflow operations from "./bigIntOverflow" and then just reduce overflow from result

// If u want to convert any number to this representation, u can this python3 function:
// ```
// def bigint_to_array(n, k, x):
//     # Initialize mod to 1 (Python's int can handle arbitrarily large numbers)
//     mod = 1
//     for idx in range(n):
//         mod *= 2
//     # Initialize the return list
//     ret = []
//     x_temp = x
//     for idx in range(k):
//         # Append x_temp mod mod to the list
//         ret.append(str(x_temp % mod))
//         # Divide x_temp by mod for the next iteration
//         x_temp //= mod  # Use integer division in Python
//     return ret
// ```

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// Get sum of each chunk with same positions
// Out has no overflow and has CHUNK_NUMBER_GREATER + 1 chunks
template BigAdd(CHUNK_SIZE, CHUNK_NUMBER_GREATER, CHUNK_NUMBER_LESS){
    
    signal input in1[CHUNK_NUMBER_GREATER];
    signal input in2[CHUNK_NUMBER_LESS];
    
    
    signal output out[CHUNK_NUMBER_GREATER + 1];
    
    component num2bits[CHUNK_NUMBER_GREATER];
    
    // sum of each chunks on the same position with overflow
    component bigAddOverflow = BigAddOverflow(CHUNK_SIZE, CHUNK_NUMBER_GREATER, CHUNK_NUMBER_LESS);
    bigAddOverflow.in1 <== in1;
    bigAddOverflow.in2 <== in2;
    
    for (var i = 0; i < CHUNK_NUMBER_GREATER; i++){
        num2bits[i] = Num2Bits(CHUNK_SIZE + 1);
        
        //if >= 2**CHUNK_SIZE, overflow, left in this chunk mod 2 ** CHUNK_SIZE, and put div(0 or 1) to next one.
        if (i == 0){
            num2bits[i].in <== bigAddOverflow.out[i];
        } else {
            num2bits[i].in <== bigAddOverflow.out[i] + num2bits[i - 1].out[CHUNK_SIZE];
        }
    }
    
    for (var i = 0; i < CHUNK_NUMBER_GREATER; i++){
        if (i == 0) {
            out[i] <== bigAddOverflow.out[i] - (num2bits[i].out[CHUNK_SIZE]) * (2 ** CHUNK_SIZE);
        }
        else {
            out[i] <== bigAddOverflow.out[i] - (num2bits[i].out[CHUNK_SIZE]) * (2 ** CHUNK_SIZE) + num2bits[i - 1].out[CHUNK_SIZE];
        }
    }
    // We can overflow only 1 in next chunk for sum of 2 non-overflowed  
    out[CHUNK_NUMBER_GREATER] <== num2bits[CHUNK_NUMBER_GREATER - 1].out[CHUNK_SIZE];
}

// Get multiplication of 2 numbers with CHUNK_NUMBER chunks
// out is 2 * CHUNK_NUMBER chunks without overflows
template BigMult(CHUNK_SIZE, CHUNK_NUMBER_GREATER, CHUNK_NUMBER_LESS){
    signal input in1[CHUNK_NUMBER_GREATER];
    signal input in2[CHUNK_NUMBER_LESS];
    
    signal output out[CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS];
    
    // Mult with overflow with kartsuba or default poly mul (detects automatically)
    component bigMultOverflow = BigMultOverflow(CHUNK_SIZE, CHUNK_NUMBER_GREATER, CHUNK_NUMBER_LESS);
    bigMultOverflow.in1 <== in1;
    bigMultOverflow.in2 <== in2;
    
    component num2bits[CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS - 1];
    component bits2numOverflow[CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS - 1];
    component bits2numModulus[CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS - 1];
    //overflow = no carry (multiplication result / 2 ** chunk_size) === chunk_size first bits in result
    for (var i = 0; i < CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS - 1; i++){
        //bigMultOverflow = CHUNK_i * CHUNK_j (2 * CHUNK_SIZE) + CHUNK_i0 * CHUNK_j0 (2 * CHUNK_SIZE) + ..., up to len times,
        // => 2 * CHUNK_SIZE + ADDITIONAL_LEN 
        var ADDITIONAL_LEN = i;
        if (i >= CHUNK_NUMBER_LESS){
            ADDITIONAL_LEN = CHUNK_NUMBER_LESS - 1;
        }
        if (i >= CHUNK_NUMBER_GREATER){
            ADDITIONAL_LEN = CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS - 1 - i;
        }
        
        num2bits[i] = Num2Bits(CHUNK_SIZE * 2 + ADDITIONAL_LEN);
        
        if (i == 0){
            num2bits[i].in <== bigMultOverflow.out[i];
        } else {
            num2bits[i].in <== bigMultOverflow.out[i] + bits2numOverflow[i - 1].out;
        }
        
        // Overflow is div by 2 ** CHUNK_SIZE (all except CHUNK_SIZE lesser bits)
        bits2numOverflow[i] = Bits2Num(CHUNK_SIZE + ADDITIONAL_LEN);
        for (var j = 0; j < CHUNK_SIZE + ADDITIONAL_LEN; j++){
            bits2numOverflow[i].in[j] <== num2bits[i].out[CHUNK_SIZE + j];
        }
        
        // Overflow is mod by 2 ** CHUNK_SIZE (CHUNK_SIZE lesser bits)
        bits2numModulus[i] = Bits2Num(CHUNK_SIZE);
        for (var j = 0; j < CHUNK_SIZE; j++){
            bits2numModulus[i].in[j] <== num2bits[i].out[j];
        }
    }
    for (var i = 0; i < CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS; i++){
        if (i == CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS - 1){
            // last chunk is overflow of previous
            out[i] <== bits2numOverflow[i - 1].out;
        } else {
            // any other chunk is mod of it`s chunk counting overflow of revious
            out[i] <== bits2numModulus[i].out;
        }
    }
}

// Get base % modulus and base // modulus
template BigMod(CHUNK_SIZE, CHUNK_NUMBER_BASE, CHUNK_NUMBER_MODULUS){
    assert(CHUNK_NUMBER_BASE <= 252);
    assert(CHUNK_NUMBER_MODULUS <= 252);
    assert(CHUNK_NUMBER_MODULUS <= CHUNK_NUMBER_BASE);
    
    var CHUNK_NUMBER_DIV = CHUNK_NUMBER_BASE - CHUNK_NUMBER_MODULUS + 1;
    
    signal input base[CHUNK_NUMBER_BASE];
    signal input modulus[CHUNK_NUMBER_MODULUS];
    
    
    signal output div[CHUNK_NUMBER_DIV];
    signal output mod[CHUNK_NUMBER_MODULUS];
    
    // uncostrainted calculation of mod and div
    var long_division[2][200] = long_div(CHUNK_SIZE, CHUNK_NUMBER_MODULUS, CHUNK_NUMBER_DIV - 1, base, modulus);
    
    for (var i = 0; i < CHUNK_NUMBER_DIV; i++){
        div[i] <-- long_division[0][i];
        
    }
    component modChecks[CHUNK_NUMBER_MODULUS];
    for (var i = 0; i < CHUNK_NUMBER_MODULUS; i++){
        mod[i] <-- long_division[1][i];
        // Check to avoid negative numbers
        modChecks[i] = Num2Bits(CHUNK_SIZE);
        modChecks[i].in <== mod[i];
        
    }
    
    // Check to avoid mod >= modulus
    component greaterThan = BigGreaterThan(CHUNK_SIZE, CHUNK_NUMBER_MODULUS);
    
    greaterThan.in[0] <== modulus;
    greaterThan.in[1] <== mod;
    greaterThan.out === 1;
    
    component mult;
    
    // We need to check div * modulus + mod === in
    // To perform nultiplication we need to mult num witn more chunks with num with less chunks
    // So we do this if, cause we know chunk numbers at compilation moment
    if (CHUNK_NUMBER_DIV >= CHUNK_NUMBER_MODULUS){
        mult = BigMultOverflow(CHUNK_SIZE, CHUNK_NUMBER_DIV, CHUNK_NUMBER_MODULUS);
        mult.in1 <== div;
        mult.in2 <== modulus;
    } else {
        mult = BigMultOverflow(CHUNK_SIZE, CHUNK_NUMBER_MODULUS, CHUNK_NUMBER_DIV);
        mult.in2 <== div;
        mult.in1 <== modulus;
    }
    
    for (var i = CHUNK_NUMBER_BASE - 1; i < CHUNK_NUMBER_MODULUS + CHUNK_NUMBER_DIV - 1; i++){
        mult.out[i] === 0;
    }
    
    // in - (div * modulus + mod) === 0
    component checkCarry = BigIntIsZero(CHUNK_SIZE, CHUNK_SIZE * 2 + log_ceil(CHUNK_NUMBER_MODULUS + CHUNK_NUMBER_DIV - 1), CHUNK_NUMBER_BASE);
    for (var i = 0; i < CHUNK_NUMBER_MODULUS; i++) {
        checkCarry.in[i] <== base[i] - mult.out[i] - mod[i];
    }
    for (var i = CHUNK_NUMBER_MODULUS; i < CHUNK_NUMBER_BASE; i++) {
        checkCarry.in[i] <== base[i] - mult.out[i];
    }
}

// Get in1 * in2 % modulus and in1 * in2 // modulus
template BigMultModP(CHUNK_SIZE, CHUNK_NUMBER_GREATER, CHUNK_NUMBER_LESS, CHUNK_NUMBER_MODULUS){
    signal input in1[CHUNK_NUMBER_GREATER];
    signal input in2[CHUNK_NUMBER_LESS];
    signal input modulus[CHUNK_NUMBER_MODULUS];
    

    var CHUNK_NUMBER_BASE = CHUNK_NUMBER_GREATER + CHUNK_NUMBER_LESS;
    var CHUNK_NUMBER_DIV = CHUNK_NUMBER_BASE - CHUNK_NUMBER_MODULUS + 1;

    signal output div[CHUNK_NUMBER_DIV];
    signal output mod[CHUNK_NUMBER_MODULUS];
    
    // get overfloved mult result
    component mult = BigMultOverflow(CHUNK_SIZE, CHUNK_NUMBER_GREATER, CHUNK_NUMBER_LESS);
    mult.in1 <== in1;
    mult.in2 <== in2;

    // unconstrainted calculation of div and mod
    var reduced[200] = reduce_overflow(CHUNK_SIZE, CHUNK_NUMBER_BASE - 1, CHUNK_NUMBER_BASE, mult.out);
    var long_division[2][200] = long_div(CHUNK_SIZE, CHUNK_NUMBER_MODULUS, CHUNK_NUMBER_DIV - 1, reduced, modulus);
    
    for (var i = 0; i < CHUNK_NUMBER_DIV; i++){
        div[i] <-- long_division[0][i];

    }
    component modChecks[CHUNK_NUMBER_MODULUS];
    for (var i = 0; i < CHUNK_NUMBER_MODULUS; i++){
        mod[i] <-- long_division[1][i];
        // Check to avoid negative numbers
        modChecks[i] = Num2Bits(CHUNK_SIZE);
        modChecks[i].in <== mod[i];

    }
    
    // To avoid mod >= modulus
    component greaterThan = BigGreaterThan(CHUNK_SIZE, CHUNK_NUMBER_MODULUS);
    
    greaterThan.in[0] <== modulus;
    greaterThan.in[1] <== mod;
    greaterThan.out === 1;
    
    component mult2;

    // We need to check div * modulus + mod === in1 * in2
    // To perform nultiplication we need to mult num witn more chunks with num with less chunks
    // So we do this if, cause we know chunk numbers at compilation moment
    if (CHUNK_NUMBER_DIV >= CHUNK_NUMBER_MODULUS){
        mult2 = BigMultNonEqualOverflow(CHUNK_SIZE, CHUNK_NUMBER_DIV, CHUNK_NUMBER_MODULUS);
        
        mult2.in1 <== div;
        mult2.in2 <== modulus;
    } else {
        mult2 = BigMultNonEqualOverflow(CHUNK_SIZE, CHUNK_NUMBER_MODULUS, CHUNK_NUMBER_DIV);
        
        mult2.in2 <== div;
        mult2.in1 <== modulus;
    }

    // in1 * in2 - (div * modulus + mod) === 0
    component isZero = BigIntIsZero(CHUNK_SIZE, CHUNK_SIZE * 2 + log_ceil(CHUNK_NUMBER_MODULUS + CHUNK_NUMBER_DIV - 1), CHUNK_NUMBER_BASE - 1);
    for (var i = 0; i < CHUNK_NUMBER_MODULUS; i++) {
        isZero.in[i] <== mult.out[i] - mult2.out[i] - mod[i];
    }
    for (var i = CHUNK_NUMBER_MODULUS; i < CHUNK_NUMBER_BASE - 1; i++) {
        isZero.in[i] <== mult.out[i] - mult2.out[i];
    }
}

// Computes CHUNK_NUMBER number power with EXP = exponent
// EXP is default num, not chunked bigInt!!!
// CHUNK_NUMBER_BASE == CHUNK_NUMBER_MODULUS because other options don`t have much sense:
// if CHUNK_NUMBER_BASE > CHUNK_NUMBER_MODULUS, do one mod before and get less constraints
// if CHUNK_NUMBER_BASE < CHUNK_NUMBER_MODULUS, just put zero in first chunk, this won`t affect at constraints
// we will get CHUNK_NUMBER_MODULUS num after first multiplication anyway
template PowerMod(CHUNK_SIZE, CHUNK_NUMBER, EXP) {

    assert(EXP >= 2);
    
    signal input base[CHUNK_NUMBER];
    signal input modulus[CHUNK_NUMBER];
    
    
    signal output out[CHUNK_NUMBER];
    
    // exp is known on compilaction, so we can do secure operations with it without constraints.
    // exp_process[0] is greatest "1" bit index (max pover of base we need)
    // exp_process[1] is num of all "1" bit in exp (to get nums of extra muls we need)
    // exp_process[2:256] are 254 bits of exp 
    var exp_process[256] = exp_to_bits(EXP);
    
    component muls[exp_process[0]];
    component resultMuls[exp_process[1] - 1];
    
    for (var i = 0; i < exp_process[0]; i++){
        muls[i] = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER, CHUNK_NUMBER);
        muls[i].modulus <== modulus;
    }
    
    for (var i = 0; i < exp_process[1] - 1; i++){
        resultMuls[i] = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER, CHUNK_NUMBER);
        resultMuls[i].modulus <== modulus;
    }

    // Here we calculate base ** (2**0), base ** (2**1), base ** (2 ** 2), ... ,base ** (2** greatest "1" bit index) 
    muls[0].in1 <== base;
    muls[0].in2 <== base;
    
    for (var i = 1; i < exp_process[0]; i++){
        muls[i].in1 <== muls[i - 1].mod;
        muls[i].in2 <== muls[i - 1].mod;
    }
    
    // Here we mult res(base ** (2 ** greatest bit index)) by (base ** (2 ** all other indexes of "1"))
    for (var i = 0; i < exp_process[1] - 1; i++){
        if (i == 0){
            if (exp_process[i + 2] == 0){
                resultMuls[i].in1 <== base;
            } else {
                resultMuls[i].in1 <== muls[exp_process[i + 2] - 1].mod;
            }
            resultMuls[i].in2 <== muls[exp_process[i + 3] - 1].mod;
        }
        else {
            resultMuls[i].in1 <== resultMuls[i - 1].mod;
            resultMuls[i].in2 <== muls[exp_process[i + 3] - 1].mod;
        }
    }

    // if we have only one "1" bit return before previous loop, else return res of loop
    if (exp_process[1] == 1){
        out <== muls[exp_process[0] - 1].mod;
    } else {
        out <== resultMuls[exp_process[1] - 2].mod;
    }
}

// calculates in ^ (-1) % modulus;
// in, modulus has CHUNK_NUMBER
template BigModInv(CHUNK_SIZE, CHUNK_NUMBER) {
    assert(CHUNK_SIZE <= 252);
    signal input in[CHUNK_NUMBER];
    signal input modulus[CHUNK_NUMBER];
    signal output out[CHUNK_NUMBER];
    
    // calculate inverse unconstrainted
    var inv[200] = mod_inv(CHUNK_SIZE, CHUNK_NUMBER, in, modulus);
    for (var i = 0; i < CHUNK_NUMBER; i++) {
        out[i] <-- inv[i];
    }
    
    // mult in * out % p
    component mult = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER, CHUNK_NUMBER);
    mult.in1 <== in;
    mult.in2 <== out;
    mult.modulus <== modulus;
    
    // check that in * out % p == 1;
    mult.mod[0] === 1;
    for (var i = 1; i < CHUNK_NUMBER; i++) {
        mult.mod[i] === 0;
    }
}


// Only for equal non-overflowed in[0] and in[1], where in[0] >= in[1]
template BigSub(CHUNK_SIZE, CHUNK_NUMBER){
    signal input in[2][CHUNK_NUMBER];
    signal output out[CHUNK_NUMBER];
    
    component lessThan[CHUNK_NUMBER];
    for (var i = 0; i < CHUNK_NUMBER; i++){
        lessThan[i] = LessThan(CHUNK_SIZE + 1);
        lessThan[i].in[1] <== 2 ** CHUNK_SIZE;
        
        if (i == 0){
            // Check that chunk_diff >= 0
            // If so, remins difference
            // Else we add 2 ** CHUNK_SIZE and reduce next chunk by 1 
            lessThan[i].in[0] <== in[0][i] - in[1][i] + 2 ** CHUNK_SIZE;
            out[i] <== in[0][i] - in[1][i] + (2 ** CHUNK_SIZE) * (lessThan[i].out);
        } else {
            // Check that chunk_diff after previous potential carry >= 0
            // If so, remins difference
            // Else we add 2 ** CHUNK_SIZE and reduce next chunk by 1 
            lessThan[i].in[0] <== in[0][i] - in[1][i] - lessThan[i - 1].out + 2 ** CHUNK_SIZE;
            out[i] <== in[0][i] - in[1][i] + (2 ** CHUNK_SIZE) * (lessThan[i].out) - lessThan[i - 1].out;
        }
    }
}