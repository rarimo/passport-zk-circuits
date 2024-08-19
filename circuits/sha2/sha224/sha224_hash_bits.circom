pragma circom 2.0.0;

include "../sha2_common.circom";
include "../sha256/sha256_padding.circom";
include "../sha256/sha256_schedule.circom";
include "../sha256/sha256_rounds.circom";
include "sha224_initial_value.circom";

//------------------------------------------------------------------------------
// Computes the SHA224 hash of a sequence of bits
// The output is 7 little-endian 32-bit words.
// See below for the more standard "digest" version

template Sha224_hash_bits(len) {

  signal input  inp_bits[len];            // `len` bits
  signal output hash_dwords[7][32];       // 224 bits, as 7 little-endian 32-bit words

  var nchunks = SHA2_224_256_compute_number_of_chunks(len);

  signal chunks[nchunks  ][512];
  signal states[nchunks+1][8][32];

  component pad = SHA2_224_256_padding(len);
  pad.inp <== inp_bits;
  pad.out ==> chunks;

  component iv = Sha224_initial_value();
  iv.out ==> states[0];

  component sch[nchunks]; 
  component rds[nchunks]; 

  for(var m=0; m<nchunks; m++) { 

    sch[m] = SHA2_224_256_schedule();
    rds[m] = SHA2_224_256_rounds(64); 

    for(var k=0; k<16; k++) {
      for(var i=0; i<32; i++) {
        sch[m].chunk_bits[k][i] <== chunks[m][ k*32 + (31-i) ];
      }
    }

    sch[m].out_words ==> rds[m].words;

    rds[m].inp_hash  <== states[m  ];
    rds[m].out_hash  ==> states[m+1];
  }

  for(var j=0; j<7; j++) {
    hash_dwords[j] <== states[nchunks][j];
  }

}

//------------------------------------------------------------------------------
// Computes the SHA224 hash of a sequence of bits
// The output is 28 bytes in the standard order

template Sha224_hash_bits_digest(len) {

  signal input  inp_bits[len];      // `len` bits
  signal output hash_bytes[28];     // 28 bytes

  component sha = Sha224_hash_bits(len);
  component ser = DWordsToByteString(7);

  inp_bits        ==> sha.inp_bits;
  sha.hash_dwords ==> ser.inp;
  ser.out         ==> hash_bytes;
}

//------------------------------------------------------------------------------
