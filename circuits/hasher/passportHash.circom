pragma circom 2.1.8;

include "./sha1/sha1.circom";
include "./sha2/sha224/sha224HashChunks.circom";
include "./sha2/sha256/sha256_hash_bits.circom";
include "./sha2/sha384/sha384_hash_bits.circom";
include "./sha2/sha512/sha512_hash_bits.circom";

template PassportHash(BLOCK_SIZE, BLOCK_NUM, ALGO){

    assert(ALGO == 160 || ALGO == 224 || ALGO == 256 || ALGO == 384 || ALGO == 512);

    signal input in[BLOCK_SIZE * BLOCK_NUM];
    signal output out[ALGO];

    if (ALGO == 160) {
        component hash160 = Sha1(BLOCK_NUM);
        hash160.in <== in;
        hash160.out ==> out;
    }
    if (ALGO == 224) {
        component hash224 = Sha224HashChunks(BLOCK_NUM);
        hash224.in <== in;
        hash224.out ==> out;
    }
    if (ALGO == 256) {
        component hash256 = Sha256_hash_chunks(BLOCK_NUM);
        hash256.in <== in;
        hash256.out ==> out;
    }
    if (ALGO == 384) {
        component hash384 = Sha384_hash_chunks(BLOCK_NUM);
        hash384.in <== in;
        hash384.out ==> out;
    }
    if (ALGO == 512) {
        component hash512 = Sha512_hash_chunks(BLOCK_NUM);
        hash512.in <== in;
        hash512.out ==> out;
    }

}