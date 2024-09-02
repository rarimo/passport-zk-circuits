pragma circom  2.1.6;

include "./passportVerificationBuilder.circom";

component main = PassportVerificationBuilder(
    2,
    8,
    8,
    8,
    512,
    256,
    7,
    32,
    17,
    64,
    4,
    20,
    [[248, 3056, 576, 6, 7, 1]],
    1,
    [
     [0,0,0,0,0,1,0,0],
     [0,0,0,0,0,0,1,0],
     [0,1,0,0,0,0,0,0]
    ]
);