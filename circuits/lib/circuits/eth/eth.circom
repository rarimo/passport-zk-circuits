pragma circom 2.1.6;

include "../hasher/hash.circom";
include "../bitify/bitify.circom";


template GetEthAddrFromPubKey(CHUNK_SIZE, CHUNK_NUMBER){
    signal input in[2][CHUNK_NUMBER];
    signal output out;

    component n2b[8];

    for (var i = 0; i < CHUNK_NUMBER * 2; i++){
        n2b[i] = Num2Bits(CHUNK_SIZE);
        n2b[i].in <== in[i \ CHUNK_NUMBER][i % CHUNK_NUMBER];
    }

    component hasher = ShaHashBits(512, 3256);

    signal concated[512];

    for (var i = 0; i < CHUNK_NUMBER; i++){
        for (var j = 0; j < CHUNK_SIZE; j++){
            concated[i * CHUNK_SIZE + j] <== n2b[CHUNK_NUMBER - 1 - i].out[CHUNK_SIZE - 1 - j];
        }
    }
    for (var i = 0; i < CHUNK_NUMBER; i++){
        for (var j = 0; j < CHUNK_SIZE; j++){
            concated[(i + 4) * CHUNK_SIZE + j] <== n2b[CHUNK_NUMBER * 2 - 1 - i].out[CHUNK_SIZE - 1 - j];
        }
    }

    hasher.in <== concated;

    component b2n = Bits2Num(160);
    for (var i = 0; i < 160; i++){
        b2n.in[i] <== hasher.out[255 - i];
    }

    out <== b2n.out;
}