pragma circom  2.1.6;

include "./brainpoolP320r1/signatureVerification.circom";

component main = verifyBrainpool320(32,10,256);