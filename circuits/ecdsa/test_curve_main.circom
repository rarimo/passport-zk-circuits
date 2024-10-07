pragma circom 2.1.6;

// include "./test_curve/p256.circom";

// component main = P256AddUnequal(32, 8);

include "./test_curve/signatureVerification.circom";

component main = verifyP256(43,6, 256);
