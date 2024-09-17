pragma circom  2.1.6;

include "./passportVerificationBuilder.circom";

component main = PassportVerificationBuilder(
    2,
    8,
    8,
    8,
    512,
    256,
    1,
    0,
    17,
    64,
    32,
    160,
    80,
    [
        [200,256,576,3,3,0]
    ],
    1,
    [
        [0,0,1,0,0,0,0,0],
        [0,0,1,0,0,0,0,0],
        [0,1,0,0,0,0,0,0] 
    ]
);
//spain
