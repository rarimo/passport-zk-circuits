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
    64,
    17,
    64,
    32,
    256,
    80,
    [[232, 256, 336, 5, 3, 0]],
    1,
    [
        [0,0,0,0,1,0,0,0],
        [0,0,1,0,0,0,0,0],
        [0,1,0,0,0,0,0,0]
    ]
);
// denmark