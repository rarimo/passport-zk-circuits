pragma circom  2.1.6;

include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/babyjub.circom";

template RegisterIdentity(
        DG15_SIZE,                      // size in hash blocks
        HASH_BLOCK_SIZE,                // size in bits
        SIGNATURE_TYPE,                 // 1, 2..  (list above) ^^^
        DOCUMENT_TYPE,                  // 1: TD1; 3: TD3
        AA_SIGNATURE_ALGO,                          // 0, 1
        AA_SHIFT                        // shift in bits
    ) {

    signal output dg15PubKeyHash;
    signal output dg1Commitment;
    signal output pkIdentityHash;
    
    var DG1_LEN = 1024;

    signal input dg1[DG1_LEN];                  // 744 || 760 bits + padding
    signal input dg15[DG15_SIZE * HASH_BLOCK_SIZE];                // 1320 || 2096 || 1832 || 2384 || 2520 bits + padding
    signal input skIdentity;
    if (AA_SIGNATURE_ALGO != 0) {
        if (AA_SIGNATURE_ALGO < 20) { // rsa keys stored
            component dg15Chunking[5];

            // 1024 bit RSA key is splitted into | 200 bit | 200 bit | 200 bit | 200 bit | 224 bit |
            var DG15_CHUNK_SIZE = 200;
            var LAST_CHUNK_SIZE = 224;
            for (var j = 0; j < 4; j++) {
                dg15Chunking[j] = Bits2Num(DG15_CHUNK_SIZE);
                for (var i = 0; i < DG15_CHUNK_SIZE; i++) {
                    dg15Chunking[j].in[DG15_CHUNK_SIZE - 1 - i] <== dg15[AA_SHIFT + j * DG15_CHUNK_SIZE + i];
                }
            }

            dg15Chunking[4] = Bits2Num(LAST_CHUNK_SIZE);
            for (var i = 0; i < LAST_CHUNK_SIZE; i++) {
                dg15Chunking[4].in[LAST_CHUNK_SIZE - 1 - i] <== dg15[AA_SHIFT + 4 * DG15_CHUNK_SIZE + i];
            }

            // Poseidon5 is applied on chunks 
            component dg15Hasher = Poseidon(5);
            for (var i = 0; i < 5; i++) {
                dg15Hasher.inputs[i] <== dg15Chunking[i].out;
            }

            dg15PubKeyHash <== dg15Hasher.out;

        } else { // Elliptic Curve Active Auth key extraction

            
            var HASH_SIZE = 248;


            var EC_FIELD_SIZE = 256;
            if (AA_SIGNATURE_ALGO == 22){
                EC_FIELD_SIZE = 320;
            }
            if (AA_SIGNATURE_ALGO == 23){
                EC_FIELD_SIZE = 192;
                HASH_SIZE = 192;
            }

            var X_Y_SHIFT = EC_FIELD_SIZE - HASH_SIZE;

            component xToNum = Bits2Num(HASH_SIZE);
            component yToNum = Bits2Num(HASH_SIZE);


            for (var i = 0; i < HASH_SIZE; i++) {
                xToNum.in[HASH_SIZE-1-i] <== dg15[AA_SHIFT + i + X_Y_SHIFT];
                yToNum.in[HASH_SIZE-1-i] <== dg15[AA_SHIFT + EC_FIELD_SIZE + i + X_Y_SHIFT];
            }

            component dg15Hasher = Poseidon(2);
            
            dg15Hasher.inputs[0] <== xToNum.out;
            dg15Hasher.inputs[1] <== yToNum.out;
            
            dg15PubKeyHash <== dg15Hasher.out;

        }
    } else {
        dg15PubKeyHash <== 0;
    }
    
    // DG1 hash 744 bits => 4 * 186 || 760 bits = 190 * 4
    component dg1Chunking[4];
    component dg1Hasher = Poseidon(5);
    var DG1_CHUNK_SIZE = 186;
    if (DOCUMENT_TYPE == 1){
        DG1_CHUNK_SIZE = 190;
    }
    
    for (var i = 0; i < 4; i++) {
        dg1Chunking[i] = Bits2Num(DG1_CHUNK_SIZE);
        for (var j = 0; j < DG1_CHUNK_SIZE; j++) {
            dg1Chunking[i].in[j] <== dg1[i * DG1_CHUNK_SIZE + j]; 
        }
        dg1Hasher.inputs[i] <== dg1Chunking[i].out;
    }

    component skIndentityHasher = Poseidon(1);   //skData = Poseidon(skIdentity)
    skIndentityHasher.inputs[0] <== skIdentity;
    dg1Hasher.inputs[4] <== skIndentityHasher.out;

    dg1Commitment <== dg1Hasher.out;


    // Forming EdDSA BybyJubJub public key point from private key (identity)
    component pkIdentityCalc = BabyPbk();
    pkIdentityCalc.in <== skIdentity;
    
    component pkIdentityHasher = Poseidon(2);
    pkIdentityHasher.inputs[0] <== pkIdentityCalc.Ax;
    pkIdentityHasher.inputs[1] <== pkIdentityCalc.Ay;
    
    pkIdentityHash <== pkIdentityHasher.out;
}