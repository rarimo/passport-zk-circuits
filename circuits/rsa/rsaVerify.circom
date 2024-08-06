pragma circom 2.1.6;

include "./rsa.circom";

component main{public [exp, sign, modulus, hashed]} = RsaVerifyPkcs1v15(64, 32, 17, 4);