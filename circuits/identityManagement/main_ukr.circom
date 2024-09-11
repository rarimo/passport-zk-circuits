pragma circom  2.1.6;

include "./circuits/registerIdentityBuilder.circom";

// HASH_TYPE: 
//   - 160: SHA1 (160 bits)
//   - 256: SHA2-256 (256 bits)
//   - 384: SHA2-384 (384 bits)
//   - 512: SHA2-512 (512 bits)

// SIGNATURE_TYPE:
//   - 1: RSA 2048 bits + SHA2-256
//   - 2: RSA 4096 bits + SHA2-256

component main = RegisterIdentityBuilder(
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
    1,
    80,
    [
        [264, 2448, 336, 6, 6, 1]
    ],
    1,
    [
     [0,0,0,0,0,1,0,0],
     [0,0,0,0,0,1,0,0],
     [0,1,0,0,0,0,0,0]
    ]
);
//ukr