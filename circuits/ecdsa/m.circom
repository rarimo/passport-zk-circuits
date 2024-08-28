pragma circom  2.1.6;

include "./brainpoolP256r1/signature_verification.circom";

component main = verifyBrainpool(64,4,256);