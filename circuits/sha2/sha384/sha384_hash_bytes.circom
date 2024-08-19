pragma circom 2.0.0;

include "../sha2_common.circom";
include "sha384_hash_bits.circom";

//------------------------------------------------------------------------------
// Computes the SHA384 hash of a sequence of bytes
// The output is 6 little-endian 64-bit words.
// See below for the more standard "digest" version

template Sha384_hash_bytes(n) {

  signal input  inp_bytes[n];             // `n` bytes
  signal output hash_qwords[6][64];       // 384 bits, as 6 little-endian 64-bit words

  signal        inp_bits[8*n];

  component sha = Sha384_hash_bits(8*n);
  component tobits[n];

  for(var j=0; j<n; j++) {
    tobits[j] = ToBits(8);
    tobits[j].inp <== inp_bytes[j];
    for(var i=0; i<8; i++) {
      tobits[j].out[i] ==> inp_bits[ j*8 + 7-i ];
    }
  }

  sha.inp_bits    <== inp_bits;
  sha.hash_qwords ==> hash_qwords;
}

//------------------------------------------------------------------------------
// Computes the SHA384 hash of a sequence of bits
// The output is 48 bytes in the standard order

template Sha384_hash_bytes_digest(n) {

  signal input  inp_bytes [n];       // `n` bytes
  signal output hash_bytes[48];      // 48 bytes

  component sha = Sha384_hash_bytes(n);
  component ser = QWordsToByteString(6);

  inp_bytes       ==> sha.inp_bytes;
  sha.hash_qwords ==> ser.inp;
  ser.out         ==> hash_bytes;
}

//------------------------------------------------------------------------------
