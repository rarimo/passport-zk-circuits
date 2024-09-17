pragma circom 2.1.6;

include "./rsaPss.circom";

component main = VerifyRsaSig(64, 32, 64, 17, 256);
