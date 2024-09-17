pragma circom  2.1.6;

include "./passportVerificationBuilder.circom";

component main = PassportVerificationBuilder(
    2,
    8,
    8,
    8,
    512,
    256,
    2,
    0,
    17,
    64,
    64,
    256,
    80,
    [
        [248, 2432, 576, 3, 6, 1]
    ],
    1,
    [
     [0,0,1,0,0,0,0,0],
     [0,0,0,0,0,1,0,0],
     [0,1,0,0,0,0,0,0]
    ]
);

