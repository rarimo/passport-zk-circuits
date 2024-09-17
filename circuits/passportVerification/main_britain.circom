pragma circom  2.1.6;

include "./passportVerificationBuilder.circom";

component main = PassportVerificationBuilder(
    2,
    8,
    8,
    8,
    512,
    256,
    6,
    0,
    0,
    64,
    4,
    256,
    80,
    [
        [224,256,336,3,3,0]
    ],
    1,
    [
        [0,0,1,0,0,0,0,0],
        [0,0,1,0,0,0,0,0],
        [0,1,0,0,0,0,0,0] 
    ]
);
//britain