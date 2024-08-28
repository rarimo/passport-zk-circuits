pragma circom  2.1.6;

include "./brainpoolP256r1/signature_verification.circom";
include "./secp256r1/signature_verification.circom";

// component main = verifyBrainpool(64,4,256);
component main = verifyP256(64,4,256);
