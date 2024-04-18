pragma circom  2.1.6;

include "../node_modules/circomlib/circuits/bitify.circom";
include "./dateEncoder.circom";

template DateDecoder() {
    signal output day;
    signal output month;
    signal output year;

    signal input dateEncoded;

    day <-- (((dateEncoded >> 8) & 15) * 10) + (dateEncoded & 15);
    month <-- (((dateEncoded >> (8*3)) & 15) * 10) + ((dateEncoded >> (8*2)) & 15);
    year <-- (((dateEncoded >> (8*5)) & 15) * 10) + ((dateEncoded >> (8*4)) & 15);
    
    component dateEncoder = DateEncoder();
    dateEncoder.day <== day;
    dateEncoder.month <== month;
    dateEncoder.year <== year;

    dateEncoder.encoded === dateEncoded;
}