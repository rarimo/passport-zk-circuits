pragma circom 2.1.6;

include "./comparators.circom";
include "./aliascheck.circom";
// Here is operation to convert number to bit array and bit array to number
//------------------------------------------------------------------------------------------------------------------------------------------------------------------

// Convert number to bit array of len
// We are checking if out[i] is a bit, so LEN + 1 constraints
template Num2Bits(LEN){
    assert(LEN <= 254);
    assert(LEN > 0);

    signal input in;
    signal output out[LEN];
    for (var i = 0; i < LEN; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] - 1) === 0;
    }
    signal sum[LEN];
    sum[0] <== out[0] * out[0];
    for (var i = 1; i < LEN; i++){
        sum[i] <== 2 ** i * out[i] + sum[i - 1];
    }
    
    in === sum[LEN - 1];

    if (LEN == 254){
        component aliascheck = AliasCheck();
        aliascheck.in <== out;
    }
}


//------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Here bit check is not present, use only with bits else error will appear!!!
// No bit check so only 1 constarint
template Bits2Num(LEN){
    assert(LEN <= 254);
    assert(LEN > 0);

    signal input in[LEN];
    signal output out;
    signal sum[LEN];
    sum[0] <== in[0] * in[0];
    
    for (var i = 1; i < LEN; i++){
        sum[i] <== 2 ** i * in[i] + sum[i - 1];
    }
    out <== sum[LEN - 1];
    if (LEN == 254){
        component aliascheck = AliasCheck();
        aliascheck.in <== in;
    } 

}