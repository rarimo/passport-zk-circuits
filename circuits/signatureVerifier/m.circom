pragma circom  2.1.6;

include "./signatureVerification.circom";

// component main = VerifySignature(64, 32, 32, 17, 1);
// component main = VerifySignature(64, 64, 17, 2);
// component main = VerifySignature(64, 32, 32, 2, 3);
// component main = VerifySignature(64, 32, 2, 4);
// component main = VerifySignature(64, 32, 17, 5);
component main = VerifySignature(64, 4, 0, 0, 6);
// component main = VerifySignature(64, 4, 0, 7);

