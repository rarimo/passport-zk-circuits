pragma circom  2.1.6;

include "circomlib/circuits/sha256/sha256.circom";
include "circomlib/circuits/bitify.circom";
include "./passportVerificationValidity.circom";

template PassportVerificationSHA256(N) {
    signal input currDateYear;
    signal input currDateMonth;
    signal input currDateDay;

    signal input credValidYear;
    signal input credValidMonth;
    signal input credValidDay;

    signal input ageLowerbound;

    signal input in[N];
    signal output out[3];

    component passportVerificationValidity = PassportVerificationValidity(N);

    passportVerificationValidity.in <== in;

    passportVerificationValidity.currDateYear   <== currDateYear;
    passportVerificationValidity.currDateMonth  <== currDateMonth;
    passportVerificationValidity.currDateDay    <== currDateDay;

    passportVerificationValidity.credValidYear  <== credValidYear;
    passportVerificationValidity.credValidMonth <== credValidMonth;
    passportVerificationValidity.credValidDay   <== credValidDay;

    passportVerificationValidity.ageLowerbound  <== ageLowerbound;

    out[2] <== passportVerificationValidity.out;
    // -------

    component hasher = Sha256(N);

    hasher.in <== in;

    component bits2NumFirst = Bits2Num(128);
    component bits2NumSecond = Bits2Num(128);

    for (var i = 0; i < 128; i++) {
        bits2NumFirst.in[127 - i] <== hasher.out[i];
    }

    for (var i = 0; i < 128; i++) {
        bits2NumSecond.in[127 - i] <== hasher.out[128 + i];
    }

    out[0] <== bits2NumFirst.out;
    out[1] <== bits2NumSecond.out;
}

component main {public [currDateDay, 
                        currDateMonth, 
                        currDateYear, 
                        credValidYear, 
                        credValidMonth, 
                        credValidDay,
                        ageLowerbound]} = PassportVerificationSHA256(744);