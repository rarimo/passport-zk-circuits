pragma circom  2.1.8;

include "./passportHash.circom";

component main = PassportHash(512, 1, 224);