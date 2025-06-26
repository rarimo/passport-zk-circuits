pragma circom  2.1.6;

include "../lib/circuits/hasher/hash.circom";
include "../lib/circuits/hasher/hash.circom";
include "../lib/circuits/bitify/bitify.circom";
include "../lib/circuits/babyjubjub/curve.circom";

// HASH_TYPE: 
//   - 160: SHA1 (160 bits)
//   - 224: SHA2-224 (224 bits)
//   - 256: SHA2-256 (256 bits)
//   - 384: SHA2-384 (384 bits)
//   - 512: SHA2-512 (512 bits)

template RegisterIdentityLight (DG_HASH_TYPE,DOCUMENT_TYPE) { // 1 || 3// 160, 224, 256, 384, 512 (list above)^^^
    assert (DOCUMENT_TYPE == 1 || DOCUMENT_TYPE == 3);
    
    signal output dg1Commitment;
    signal output dg1Hash;
    signal dg1HashBits[DG_HASH_TYPE];
    
    // Poseidon2(PubKey.X, PubKey.Y)
    signal output pkIdentityHash;
    
    // INPUT SIGNALS:
    signal input dg1[1024];
    signal input skIdentity;
    
    
    var HASH_BLOCK_SIZE = 512;
    var HASH_BLOCK_NUMBER = 2;
    if (DG_HASH_TYPE > 256){
        HASH_BLOCK_SIZE = 1024;
        HASH_BLOCK_NUMBER = 1;
    }
    
    // DG1 hash 744 bits => 4 * 186 || 760 bits = 190 * 4
    component dg1Chunking[4];
    component dg1Hasher = PoseidonHash(5);
    var DG1_CHUNK_SIZE = 186;
    if (DOCUMENT_TYPE == 1){
        DG1_CHUNK_SIZE = 190;
    }
    
    for (var i = 0; i < 4; i++) {
        dg1Chunking[i] = Bits2Num(DG1_CHUNK_SIZE);
        for (var j = 0; j < DG1_CHUNK_SIZE; j++) {
            dg1Chunking[i].in[j] <== dg1[i * DG1_CHUNK_SIZE + j];
        }
        dg1Hasher.in[i] <== dg1Chunking[i].out;
    }
    
    component skIndentityHasher = PoseidonHash(1);
    skIndentityHasher.in[0] <== skIdentity;
    dg1Hasher.in[4] <== skIndentityHasher.out;
    
    dg1Commitment <== dg1Hasher.out;
    
    component pkIdentityCalc = BabyPbk();
    pkIdentityCalc.in <== skIdentity;
    
    component pkIdentityHasher = PoseidonHash(2);
    pkIdentityHasher.in[0] <== pkIdentityCalc.Ax;
    pkIdentityHasher.in[1] <== pkIdentityCalc.Ay;
    
    pkIdentityHash <== pkIdentityHasher.out;
    
    component dg1ShaHasher = ShaHashChunks(HASH_BLOCK_NUMBER, DG_HASH_TYPE);
    dg1ShaHasher.in <== dg1;
    dg1HashBits <== dg1ShaHasher.out;
    
    component b2n = Bits2Num(248);
    
    var HASH_DIFF = 0;
    if (DG_HASH_TYPE < 248){
        HASH_DIFF = 248 - DG_HASH_TYPE;
    }
    
    for (var i = 0; i < 248 - HASH_DIFF; i++){
        b2n.in[i] <== dg1HashBits[DG_HASH_TYPE - 1 - i];
    }
    for (var i = 248 - HASH_DIFF; i < 248; i++){
        b2n.in[i] <== 0;
    }
    
    dg1Hash <== b2n.out;
    
    // log(dg1Commitment);
    // log(pkIdentityHash);
    // log(dg1Hash);
    
}




