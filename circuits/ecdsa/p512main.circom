pragma circom  2.1.6;

include "./brainpoolP512r1/signatureVerification.circom";

component main = verifyBrainpool(32,16,512);
