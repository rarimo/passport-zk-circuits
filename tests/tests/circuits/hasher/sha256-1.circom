pragma circom  2.1.8;

include "../../../../circuits/hasher/passportHash.circom";


component main = PassportHash(512, 1, 256);