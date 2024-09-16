pragma circom  2.1.6;

include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/babyjub.circom";

template RegisterIdentity(
        DG1_SIZE,                       // size in hash blocks
        DG15_SIZE,                      // size in hash blocks
        HASH_BLOCK_SIZE,                // size in bits
        SIGNATURE_TYPE,                 // 1, 2..  (list above) ^^^
        DOCUMENT_TYPE                   // 1: TD1; 3: TD3
    ) {

    signal output dg15PubKeyHash;
    signal output dg1Commitment;
    signal output pkIdentityHash;

    signal input dg1[DG1_SIZE * HASH_BLOCK_SIZE];                  // 744 || 760 bits + padding
    signal input dg15[DG15_SIZE * HASH_BLOCK_SIZE];                // 1320 || 2096 || 1832 || 2384 || 2520 bits + padding
    signal input skIdentity;

    if (SIGNATURE_TYPE <= 5) { // rsa keys stored
        component dg15Chunking[5];
        var DG15_RSA_SHIFT = 256; // shift in ASN1 encoded content to pk value

        // 1024 bit RSA key is splitted into | 200 bit | 200 bit | 200 bit | 200 bit | 224 bit |
        var DG15_CHUNK_SIZE = 200;
        var LAST_CHUNK_SIZE = 224;
        for (var j = 0; j < 4; j++) {
            dg15Chunking[j] = Bits2Num(DG15_CHUNK_SIZE);
            for (var i = 0; i < DG15_CHUNK_SIZE; i++) {
                dg15Chunking[j].in[DG15_CHUNK_SIZE - 1 - i] <== dg15[DG15_RSA_SHIFT + j * DG15_CHUNK_SIZE + i];
            }
        }

        dg15Chunking[4] = Bits2Num(LAST_CHUNK_SIZE);
        for (var i = 0; i < LAST_CHUNK_SIZE; i++) {
            dg15Chunking[4].in[LAST_CHUNK_SIZE - 1 - i] <== dg15[DG15_RSA_SHIFT + 4 * DG15_CHUNK_SIZE + i];
        }

        // Poseidon5 is applied on chunksEC_FIELD_SIZE
        component dg15Hasher = Poseidon(5);
        for (var i = 0; i < 5; i++) {
            dg15Hasher.inputs[i] <== dg15Chunking[i].out;
        }

        dg15PubKeyHash <== dg15Hasher.out;

    } else { // Elliptic Curve Active Auth key extraction
        component xToNum = Bits2Num(248);
        component yToNum = Bits2Num(248);
        
        var EC_FIELD_SIZE = 256;
        var DG15_ECDSA_SHIFT = 2008;

        for (var i = 0; i < 248; i++) {
            xToNum.in[247-i] <== dg15[DG15_ECDSA_SHIFT + i + 8];
            yToNum.in[247-i] <== dg15[DG15_ECDSA_SHIFT + EC_FIELD_SIZE + i + 8];
        }

        component dg15Hasher = Poseidon(2);
        
        dg15Hasher.inputs[0] <== xToNum.out;
        dg15Hasher.inputs[1] <== yToNum.out;
        
        dg15PubKeyHash <== dg15Hasher.out;
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