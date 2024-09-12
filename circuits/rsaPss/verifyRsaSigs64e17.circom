pragma circom 2.1.8;

include "./rsaPss.circom";

component main = VerifyRsaSig(64, 32, 64, 17, 256);
