pragma circom  2.1.6;

include "../node_modules/circomlib/circuits/bitify.circom";
include "./dateEncoder.circom";

template DateDecoder() {
    signal output day;
    signal output month;
    signal output year;

    signal input dateEncoded;

    signal dayDecoded <-- (((dateEncoded >> 8) & 15) * 10) + (dateEncoded & 15);
    signal monthDecoded <-- (((dateEncoded >> (8*3)) & 15) * 10) + ((dateEncoded >> (8*2)) & 15);
    signal yearDecoded <-- (((dateEncoded >> (8*5)) & 15) * 10) + ((dateEncoded >> (8*4)) & 15);
    
    component dateEncoder = DateEncoder();
    dateEncoder.day <== dayDecoded;
    dateEncoder.month <== monthDecoded;
    dateEncoder.year <== yearDecoded;

    dateEncoder.encoded === dateEncoded;
}

component main = DateDecoder();