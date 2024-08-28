pragma circom 2.1.8;

include "./rsaPss.circom";

component main = VerifyRsaPssSig(64, 32, 2, 256);
