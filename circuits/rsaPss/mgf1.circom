pragma circom 2.1.6;

include "../sha2/sha384/sha384_hash_bits.circom";
include "circomlib/circuits/bitify.circom";

template Mgf1Sha384(seedLen, maskLen) { //in bytes
    var seedLenBits = seedLen * 8;
    var maskLenBits = maskLen * 8;
    var hashLen = 48; //output len of sha function in bytes 
    var hashLenBits = hashLen * 8;//output len of sha function in bits

    signal input seed[seedLenBits]; //each represents a bit
    signal output out[maskLenBits];
    
    assert(maskLen <= 0xffffffff * hashLen );
    var iterations = (maskLen \ hashLen) + 1; //adding 1, in-case maskLen \ hashLen is 0
    component sha384[iterations];
    component num2Bits[iterations];

    for (var i = 0; i < iterations; i++) {
        sha384[i] = Sha384_hash_bits(seedLenBits + 32); //32 bits for counter
        num2Bits[i] = Num2Bits(32);
    }

    var concated[seedLenBits + 32]; //seed + 32 bits(4 Bytes) for counter
    signal hashed[hashLenBits * (iterations)];

    for (var i = 0; i < seedLenBits; i++) {
        concated[i] = seed[i];
    }

    for (var i = 0; i < iterations; i++) {
        num2Bits[i].in <== i; //convert counter to bits

        for (var j = 0; j < 32; j++) {
            //concat seed and counter
            concated[seedLenBits + j] = num2Bits[i].out[31-j];
        }


        sha384[i].inp_bits <== concated;

        for (var j = 0; j < hashLenBits; j++) {
            hashed[i * hashLenBits + j] <== sha384[i].out[j];
        }
    }

    for (var i = 0; i < maskLenBits; i++) {
        out[i] <== hashed[i];
    }
}