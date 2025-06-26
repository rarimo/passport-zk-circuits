pragma circom  2.1.6;

include "../int/arithmetic.circom";
include "./floatFunc.circom";
include "../utils/switcher.circom";
include "../bitify/comparators.circom";

// There are some templates to operate with float nums
// In our implementation, every float number has presicion n,
// which mean that our representation on number:
// our_representation = (real_number * 2 **n) % 1
// for example, 6.5 with presition 8 will be (6.5 * 2**8) // 1 = 1664
// Addition and substraction for those numbers is the same as default:
// c <== a + b,
// a, b, c - floats in our realisation
// (don`t forget about linear constraint here!)
// for multiplying floats use next templates
//------------------------------------------------------------
// Multiplication of 2 floats with flooring
// Uses n*2 + 1 constraints
template FloatMult(n){
    signal input in[2];
    signal output out;
    
    component cutPrecision = CutPrecision(n, 2 * n);
    cutPrecision.in <== in[0] * in[1];
    out <== cutPrecision.out;
    
    // var print1 = log_float(in[0], n);
    // var print2 = log_float(in[1], n);
    // var print3 = log_float(out, n);
    // var print4 = log_float(in[1] * in[0], 2 * n);
}

// calculates inverse (1 / in) of float in
template FloatInverse(n){
    signal input in;
    signal output out;
    var absBitsOut[253] = abs_in_bits(2 ** (2 * n) % in);
    var carry = 0;
    for(var i = 48; i < 253; i++){
        carry += absBitsOut[i];
    }
    out <-- 2 ** (2 * n) \ in + (carry != 0);

    signal mults[3];
    
    // mults[0] - in * (out+1)
    // mults[1] - in * out
    // mults[2] - in * (out-1)
    for (var i = 0; i < 3; i++){
        mults[i] <== in * (out + 1 - i) - 2 ** (2 * n);
    }

    var absBits1[253] = abs_in_bits(mults[0]);
    
    signal absInBits1[253];
    component abs1 = Bits2Num(253);
    for (var i = 0; i < 253; i++) {
        absInBits1[i] <-- absBits1[i];
        absInBits1[i] * (1 - absInBits1[i]) === 0;
        abs1.in[i] <== absInBits1[i];
    }
    (abs1.out - mults[0]) * (abs1.out + mults[0]) === 0;

    
    var absBits2[253] = abs_in_bits(mults[1]);
    
    signal absInBits2[253];
    component abs2 = Bits2Num(253);
    for (var i = 0; i < 253; i++) {
        absInBits2[i] <-- absBits2[i];
        absInBits2[i] * (1 - absInBits2[i]) === 0;
        abs2.in[i] <== absInBits2[i];
    }
    (abs2.out -  mults[1]) * (abs2.out + mults[1]) === 0;

    var absBits3[253] = abs_in_bits(mults[2]);
    
    signal absInBits3[253];
    component abs3 = Bits2Num(253);
    for (var i = 0; i < 253; i++) {
        absInBits3[i] <-- absBits3[i];
        absInBits3[i] * (1 - absInBits3[i]) === 0;
        abs3.in[i] <== absInBits3[i];
    }
    (abs3.out - mults[2]) * (abs3.out + mults[2]) === 0;

    component comparators[2];
    for (var i = 0; i < 2; i++){
        comparators[i] = LessEqThan(252 - n);
    }
    comparators[0].in[0] <== abs2.out;
    comparators[0].in[1] <== abs1.out;
    comparators[0].out === 1;

    comparators[1].in[0] <== abs2.out;
    comparators[1].in[1] <== abs3.out;
    comparators[1].out === 1;
    
}


// Set new presicition 
// new presition(n2) is always smaller than old one(n1)
// use for sum of multiple muls for more accuracy and less constraints
template RemovePrecision(n1, n2){
    assert (n2 > n1);
    
    signal input in;
    signal output out;
    component num2Bits = Num2Bits(253);
    num2Bits.in <== in;
    component bits2Num = Bits2Num(253);
    for (var i = 0; i < 253; i++) {
        if (i > 252 - (n2 - n1)) {
            bits2Num.in[i] <== 0;
        }
        else {
            bits2Num.in[i] <== num2Bits.out[(n2 - n1) + i];
        }
    }
    out <== bits2Num.out;
}

template CutPrecision(precNew, precOld) {
    assert(precNew < precOld);
    
    signal input in;
    signal output out;
    
    var absBits[253] = abs_in_bits(in);
    
    signal absInBits[253];
    component abs = Bits2Num(253);
    for (var i = 0; i < 253; i++) {
        absInBits[i] <-- absBits[i];
        absInBits[i] * (1 - absInBits[i]) === 0;
        abs.in[i] <== absInBits[i];
    }
    (abs.out - in) * (abs.out + in) === 0;
    
    component sign = IsEqual();
    sign.in[0] <== abs.out;
    sign.in[1] <== in;
    
    component bits2Num = Bits2Num(253);
    for (var i = 0; i < 253; i++) {
        if (i > 252 - (precOld - precNew)) {
            bits2Num.in[i] <== 0;
        }
        else {
            bits2Num.in[i] <== absInBits[(precOld - precNew) + i];
        }
    }
    component switcher = Switcher();
    switcher.bool <== 1 - sign.out;
    switcher.in[0] <== bits2Num.out * sign.out;
    switcher.in[1] <==  - bits2Num.out * (1 - sign.out);
    out <== switcher.out[0];
}

// Computes e ^ x, where x is float by Teilor series.
//      inf
// e^x = ∑ (x^k)/(k!)
//      k=0
template Exp(n){
    assert(n >= 4);
    signal input in;
    
    signal output out;
    
    component mult[n \ 2 - 1];
    for (var i = 0; i < n \ 2 - 1; i++){
        mult[i] = FloatMult(n);
        if (i == 0){
            mult[i].in[0] <== in;
            mult[i].in[1] <== in;
        } else {
            mult[i].in[0] <== in;
            mult[i].in[1] <== mult[i - 1].out;
        }
    }
    
    var precompute[100] = precompute_exp_constants(n \ 2 + 1, n);
    component sum = GetSumOfNElements(n \ 2 + 1);
    sum.in[0] <== precompute[0] * 2 ** n;
    for (var i = 1; i < n \ 2 + 1; i++){
        if (i == 1){
            sum.in[i] <== in * precompute[i];
        } else {
            sum.in[i] <== mult[i - 2].out * precompute[i];
        }
    }
    
    component reduce = CutPrecision(n, 2 * n);
    reduce.in <== sum.out;
    out <== reduce.out;
}

//Use for values |in| <= (add value later)
template FloatIsNegative(){
    signal input in;
    signal output out;
    
    component num2Bits = Num2Bits(254);
    
    num2Bits.in <== in;
    
    out <== num2Bits.out[253];
    
}