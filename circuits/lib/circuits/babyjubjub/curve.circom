pragma circom 2.1.6;

include "../bitify/bitify.circom";
include "../bitify/comparators.circom";
include "../int/arithmetic.circom";
include "../utils/switcher.circom";
include "./get.circom";

// Those templates for Babujubjub curve operations

//---------------------------------------------------------------------------------------------------------------------------------------
// Helpers templates, don`t use without full understanding!!!

// Returns sum of 2 points if two non-zero points,
// returns in1 if in2 point is zero,
// returns in2 if in1 point is zero,
// returns zero if in1 and in2 points are zero
// This template uses in scalar multiplication, don`t use it without undersrtanding what are u doing!!! 
template addZeroBabyjub(){
    signal input in1[2];
    signal input in2[2];
    signal output out[2];
    
    // Check for point are zeroes
    component isZeroIn1 = IsZero();
    isZeroIn1.in <== in1[0];
    component isZeroIn2 = IsZero();
    isZeroIn2.in <== in2[0];
    
    // sum of 2 points
    component adder = BabyjubjubAdd();
    adder.in1 <== in1;
    adder.in2 <== in2;
    
    // 0 - point isn`t zero, 1 - point is Zero, left one - for left point, right - for right
    // 0 0 -> adders
    // 0 1 -> left
    // 1 0 -> right
    // 1 1 -> right

    component switcherLeft[2];
    component switcherRight[2];
    
    for (var i = 0; i < 2; i++){
        switcherLeft[i] = Switcher();
        switcherLeft[i].bool <== isZeroIn2.out;
        switcherLeft[i].in[0] <== adder.out[i];
        switcherLeft[i].in[1] <== in1[i];

        switcherRight[i] = Switcher();
        switcherRight[i].bool <== isZeroIn1.out;
        switcherRight[i].in[0] <== switcherLeft[i].out[0];
        switcherRight[i].in[1] <== in2[i];
    }
    
    out[0] <== switcherRight[0].out[0];
    out[1] <== switcherRight[1].out[0];
}

//---------------------------------------------------------------------------------------------------------------------------------------

// Computes (x3, y3) = (x1, y1) + (x2, y2)
// a = 168700
// d = 168696
// β = x1 * y2
// Ɣ = x2 * y1
// δ = (y1 - x1 * a) * (x2 + y2)
// τ = x1 * x2 * y1 * y2
// x3 = (β + Ɣ) / (1 + d * τ)
// y3 = (δ + a * β - Ɣ) / (1 - d * τ)
template BabyjubjubAdd() {
    signal input in1[2];
    signal input in2[2];
    signal output out[2];
    
    signal beta;
    signal gamma;
    signal delta;
    signal tau;
    
    var a = 168700;
    var d = 168696;
    
    // β = x1 * y2
    beta <== in1[0] * in2[1];

    // Ɣ = x2 * y1
    gamma <== in1[1] * in2[0];

    // δ = (y1 - x1 * a) * (x2 + y2)
    delta <== (in1[1] - a * in1[0]) * (in2[0] + in2[1]);

    // τ = x1 * x2 * y1 * y2
    tau <== beta * gamma;
    
    // (β + Ɣ) / (1 + d * τ)
    out[0] <-- (beta + gamma) / (1 + d * tau);
    (1 + d * tau) * out[0] === (beta + gamma);
    
    // y3 = (δ + a * β - Ɣ) / (1 - d * τ)
    out[1] <-- (delta + a * beta - gamma) / (1 - d * tau);
    (1 - d * tau) * out[1] === (delta + a * beta - gamma);

    // log(out[0], out[1]);
}

// Computes (x2, y2) = (x1, y1) + (x1, y1)
// Uses add under the hood
template BabyjubjubDouble() {
    signal input in[2];
    signal output out[2];
    
    component adder = BabyjubjubAdd();
    adder.in1 <== in;
    adder.in2 <== in;
    
    adder.out ==> out;
}

// Check is given point is point on curve
// Pass if point is on curve or fails if not
template BabyjubjubPointOnCurve() {
    signal input x;
    signal input y;
    
    signal x2;
    signal y2;
    
    var a = 168700;
    var d = 168696;
    
    x2 <== x * x;
    y2 <== y * y;
    
    a * x2 + y2 === 1 + d * x2 * y2;
}

// Scalar multiplication with base8 point
// Same as convert private key to public key
// Don`t use 0 scalar, u will get [0,0], not error
// Double and add method for now
// TODO: optimise - make it use less constraints because we know base8
template BabyjubjubBase8Multiplication(){
    signal input scalar;
    signal output out[2];
    
    component getBase8 = GetBabyjubjubBase8();
    
    component num2Bits = Num2Bits(254);
    num2Bits.in <== scalar;
    
    component adders[254];
    component doublers[253];
    
    for (var i = 0; i < 254; i++){
        adders[i] = addZeroBabyjub();
        if (i == 0){
            adders[i].in1 <== [0,0];
            adders[i].in2[0] <== getBase8.base8[0] * num2Bits.out[253 - i];
            adders[i].in2[1] <== getBase8.base8[1] * num2Bits.out[253 - i];
        } else {
            doublers[i - 1] = BabyjubjubDouble();
            doublers[i - 1].in <== adders[i - 1].out;
            adders[i].in1 <== doublers[i - 1].out;
            adders[i].in2[0] <== getBase8.base8[0] * num2Bits.out[253 - i];
            adders[i].in2[1] <== getBase8.base8[1] * num2Bits.out[253 - i];
        }
    }
    
    out <== adders[253].out;
}

// Scalar multiplication with any point
// in is point to multiply, scalar is scalar to multiply
// Don`t use 0 scalar, u will get [0,0], not error
// Double and add method
template BabyjubjubMultiplication(){
    signal input scalar;
    signal input in[2];
    
    signal output out[2];
    
    // Decompose scalar into bits
    component num2Bits = Num2Bits(254);
    num2Bits.in <== scalar;
    
    component adders[254];
    component doublers[253];
    
    for (var i = 0; i < 254; i++){
        adders[i] = addZeroBabyjub();
        if (i == 0){
            adders[i].in1 <== [0,0];
            adders[i].in2[0] <== in[0] * num2Bits.out[253 - i];
            adders[i].in2[1] <== in[1] * num2Bits.out[253 - i];
        } else {
            doublers[i - 1] = BabyjubjubDouble();
            doublers[i - 1].in <== adders[i - 1].out;
            adders[i].in1 <== doublers[i - 1].out;
            adders[i].in2[0] <== in[0] * num2Bits.out[253 - i];
            adders[i].in2[1] <== in[1] * num2Bits.out[253 - i];
        }
    }
    
    out <== adders[253].out;
}
