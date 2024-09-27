pragma circom  2.1.6;

include "./secp192r1/signatureVerification.circom";

component main = verifySecp192r1(32, 6, 160);