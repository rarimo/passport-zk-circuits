pragma circom 2.1.6;

include "./rsaPss.circom";

component main = VerifyRsaSig(64, 48, 32, 17, 256);
