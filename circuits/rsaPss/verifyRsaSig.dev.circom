pragma circom 2.1.8;

include "./rsaPss.circom";

component main = VerifyRSASig(64, 32, 2, 256);
