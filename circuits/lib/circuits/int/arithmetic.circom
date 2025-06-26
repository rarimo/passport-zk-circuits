pragma circom 2.1.6;

include "../bitify/comparators.circom";
include "../bitify/bitify.circom";
include "../utils/switcher.circom";

 
//----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Some templates for num operations

// gets inversion in circom prime field
// out * in === 1
template Inverse(){
    signal input in;
    signal output out;
    out <-- 1 / in;
    out * in === 1;
}

// THIS IS UNSECURE VERSION, NEVER (NEVER!!!!!!!!!!!!!) USE IT IN PRODUCTION!!!!
// I hope secure version will appear later
// use if u don`t know what is len of bit representation of in[0] is
template DivisionStrict(){
    signal input in[2];
    
    signal output mod;
    signal output div;
    
    mod <-- in[0] % in[1];
    div <-- in[0] \ in[1];
    
    div * in[1] + mod === in[0];
    component check1 = LessEqThan(252);
    component check2 = GreaterThan(252);
    
    check1.in[0] <== div * in[1];
    check1.in[1] <== in[0];
    check1.out === 1;
    
    check2.in[0] <== (div + 1) * in[1];
    check2.in[1] <== in[0];
    check2.out === 1;
    
}

// THIS IS UNSECURE VERSION, NEVER (NEVER!!!!!!!!!!!!!) USE IT IN PRODUCTION!!!!!
// I hope secure version will appear later
// use this if u know what len of bit representation of in[1] is
template Division(LEN){
    
    assert (LEN < 253);
    signal input in[2];
    
    signal output div;
    signal output mod;
    
    mod <-- in[0] % in[1];
    div <-- in[0] \ in[1];
    
    div * in[1] + mod === in[0];
    component check1 = LessEqThan(LEN);
    component check2 = GreaterThan(LEN);
    
    check1.in[0] <== div * in[1];
    check1.in[1] <== in[0];
    check1.out === 1;
    
    check2.in[0] <== (div + 1) * in[1];
    check2.in[1] <== in[0];
    check2.out === 1;
    
}

// calculated log_2 rounded down (for example, 2.3 ===> 2)
// also can be used as index of first 1 bit in number
// don`t use it for 0!!!
template Log2CeilStrict(){
    signal input in;
    signal output out;
    
    signal bits[252];
    component n2b = Num2Bits(252);
    n2b.in <== in - 1;
    n2b.out ==> bits;
    
    signal counter[252];
    signal sum[252];
    
    counter[0] <== bits[251];
    sum[0] <== counter[0];
    
    for (var i = 1; i < 252; i++){
        counter[i] <== (1 - counter[i - 1]) * bits[251 - i] + counter[i - 1];
        sum[i] <== sum[i - 1] + counter[i];
    }
    
    out <== sum[251];
}

// to calculate log ceil, we should convert num to bits, and if we know it`s len, we already know the answer
// but if u know estimed range of num, u can use this to reduce num of constraints (num < 2 ** RANGE)
// (u don`t need to use convert num to 254 bits if u know that is always less that 1000, for example)
template Log2Ceil(RANGE){
    signal input in;
    signal output out;
    
    signal bits[RANGE];
    component n2b = Num2Bits(RANGE);
    n2b.in <== in - 1;
    n2b.out ==> bits;
    
    signal counter[RANGE];
    signal sum[RANGE];
    
    counter[0] <== bits[RANGE - 1];
    sum[0] <== counter[0];
    
    for (var i = 1; i < RANGE; i++){
        counter[i] <== (1 - counter[i - 1]) * bits[RANGE - 1 - i] + counter[i - 1];
        sum[i] <== sum[i - 1] + counter[i];
    }
    
    out <== sum[RANGE - 1];
}

// computes last bit of num with any bit len for 2 constraints
// returns bit (0 or 1) and div = num \ 2
// To get last bit we have to take 2 last bits
// This is because we work in field:
// for example, lets take sammer field p = 17
// in = 5
// There are 2 options:
// bit = 1, div = 2, which is correct and intuitive
// but we calculate it with var, so anything can be put
// and if we put bit = 0, and div = 11:
// 11 * 2 + 0 = 22
// we work in field => 22 = 22 % 17 = 5;
// 5 === 5, pass will check
// THIS IS UNSECURE VERSION, NEVER (NEVER!!!!!!!!!!!!!) USE IT IN PRODUCTION!!!!
template GetLastBit(){
    signal input in;
    signal output bit;
    signal output div;
    
    component getLastBits[2];
    getLastBits[0] = GetLastBitUnsecure();
    getLastBits[0].in <== in;
    getLastBits[1] = GetLastBitUnsecure();
    getLastBits[1].in <==  getLastBits[0].div;

    getLastBits[1].div * 4 + getLastBits[1].bit * 2 + getLastBits[0].bit === in;

    div <== getLastBits[0].div;
    bit <== getLastBits[0].bit;
}

// computes last bit of num with any bit len for 2 constraints
// returns bit (0 or 1) and div = num \ 2
// HAS NO CHECK FOR CHANGING DIV = (p + in) / 2 FLOORED CHANGED!!!! (look explanation for previous template)
// THIS IS UNSECURE VERSION, NEVER (NEVER!!!!!!!!!!!!!) USE IT IN PRODUCTION!!!!
template GetLastBitUnsecure(){
    signal input in;
    signal output bit;
    signal output div;
    
    bit <-- in % 2;
    div <-- in \ 2;
    
    (1 - bit) * bit === 0;
    div * 2 + bit * bit === in;
}

// computes last n bits of any num
// returns array of bits and div
// in fact, this is also just a div for (2 ** N)
// for now, this is only one secured div that can be used
// THIS IS UNSECURE VERSION, NEVER (NEVER!!!!!!!!!!!!!) USE IT IN PRODUCTION!!!!
template GetLastNBits(N){
    assert (N >= 2);
    signal input in;
    signal output div;
    signal output out[N];
    
    component getLastBit[N];
    for (var i = 0; i < N; i++){
        getLastBit[i] = GetLastBitUnsecure();
        if (i == 0){
            getLastBit[i].in <== in;
        } else {
            getLastBit[i].in <== getLastBit[i - 1].div;
        }
        out[i] <== getLastBit[i].bit;
    }
    
    div <== getLastBit[N - 1].div;

    signal check[N];
    check[0] <== out[0] * out[0];
    for (var i = 1; i < N; i ++){
        check[i] <== check[i - 1] + out[i] * (2 ** i);
    }

    check[N - 1] + div * (2 ** N) === in;
}


// Get sum of N elements with 1 constraint.
// Use this instead of a + b + ... + c;
// Circom will drop linear constaraint because of optimisation
template GetSumOfNElements(N){ 
    assert (N >= 2);
    
    signal input in[N];
    signal output out;
    
    signal sum[N - 1];
    
    for (var i = 0; i < N - 1; i++){
        if (i == 0){
            sum[i] <== in[i] + in[i + 1];
        } else {
            sum[i] <== sum[i - 1] + in[i + 1];
        }
    }
    out <== sum[N - 2];
}

// get absolute value of number
// sign = 1 if +, 0 if -
// THIS IS UNSECURE VERSION, NEVER (NEVER!!!!!!!!!!!!!) USE IT IN PRODUCTION!!!!
template Abs(){
    signal input in;
    signal output sign;
    signal output out;

    component lessThan = GreaterEqThan(253);
    lessThan.in[0] <== in;
    lessThan.in[1] <== 10944121435919637611123202872628637544274182200208017171849102093287904247808;
    component switcher = Switcher();
    switcher.bool <== lessThan.out;
    switcher.in[0] <== -in;
    switcher.in[1] <== in;
    out <== switcher.out[0];

} 
