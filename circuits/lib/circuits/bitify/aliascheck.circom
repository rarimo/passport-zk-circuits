pragma circom 2.1.6;

include "compconstant.circom";

// Checks number in binary is less than field size.
// Prevents num2Bits(254) manipulation with p + 1 in bits for in = 1, for example.
template AliasCheck() {

    signal input in[254];

    component  compConstant = CompConstant(-1);
    compConstant.in <== in;

    compConstant.out === 0;
}