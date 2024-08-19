pragma circom 2.0.0;

include "../sha2_common.circom";
include "sha512_padding.circom";
include "sha512_initial_value.circom";
include "sha512_schedule.circom";
include "sha512_rounds.circom";

//------------------------------------------------------------------------------
// Computes the SHA512 hash of a sequence of bits
// The output is 8 little-endian 64-bit words.
// See below for the more standard "digest" version

template Sha512_hash_bits(len) {

  signal input  inp_bits[len];            // `len` bits
  signal output hash_qwords[8][64];       // 512 bits, as 8 little-endian 64-bit words

  var nchunks = SHA2_384_512_compute_number_of_chunks(len);

  signal chunks[nchunks  ][1024];
  signal states[nchunks+1][8][64];

  component pad = SHA2_384_512_padding(len);
  pad.inp <== inp_bits;
  pad.out ==> chunks;

  component iv = Sha512_initial_value();
  iv.out ==> states[0];

  component sch[nchunks]; 
  component rds[nchunks]; 

  for(var m=0; m<nchunks; m++) { 

    sch[m] = SHA2_384_512_schedule();
    rds[m] = SHA2_384_512_rounds(80); 

    for(var k=0; k<16; k++) {
      for(var i=0; i<64; i++) {
        sch[m].chunk_bits[k][i] <== chunks[m][ k*64 + (63-i) ];
      }
    }

    sch[m].out_words ==> rds[m].words;

    rds[m].inp_hash  <== states[m  ];
    rds[m].out_hash  ==> states[m+1];
  }

  hash_qwords <== states[nchunks];

}

//------------------------------------------------------------------------------
// Computes the SHA512 hash of a sequence of bits
// The output is 64 bytes in the standard order

template Sha512_hash_bits_digest(len) {

  signal input  inp_bits[len];      // `len` bits
  signal output hash_bytes[64];     // 64 bytes

  component sha = Sha512_hash_bits(len);
  component ser = QWordsToByteString(8);

  inp_bits        ==> sha.inp_bits;
  sha.hash_qwords ==> ser.inp;
  ser.out         ==> hash_bytes;
}

//------------------------------------------------------------------------------
