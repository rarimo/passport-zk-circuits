pragma circom 2.1.6;

include "./rsa.circom";

component main = RsaVerifyPkcs1v15Sha1(64, 32, 17, 160);