pragma circom 2.1.6;

include "./signatureVerification.circom";

component main = Verify{curve_name}({n}, {k}, {algo})
