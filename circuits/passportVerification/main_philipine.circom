pragma circom  2.1.6;

include "./passportVerificationBuilder.circom";

component main = PassportVerificationBuilder(
    2,
    8,
    8,
    8,
    512,
    256,
    3,
    32,
    17,
    64,
    32,
    256,
    80,
    [
        [248, 1808, 576, 4, 5, 1]
    ],
    1,
    [
        [0,0,0,1,0,0,0,0],
        [0,0,0,0,1,0,0,0],
        [0,1,0,0,0,0,0,0] 
    ]
);
//philipine