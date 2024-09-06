pragma circom 2.0.0;

include "../sha2Common.circom";
include "sha256Schedule.circom";
include "sha256Rounds.circom";
include "sha256Initial_value.circom";

//------------------------------------------------------------------------------
// hashes 512 bits into 256 bits, without applying any padding
// this can be possibly useful for constructing a Merkle tree

template Sha256_hash_chunk() {

  signal input  inp_bits[512];          // 512 bits
  signal output outHash[8][32];        // 256 bits, as 8 little-endian 32-bit words
  signal output outBits[256];          // 256 flat bits, big-endian order

  component iv  = Sha256InitialValue();
  component sch = Sha2_224_256Shedule();
  component rds = Sha2_224_256Rounds(64); 

  for(var k=0; k<16; k++) {
    for(var i=0; i<32; i++) {
      sch.chunkBits[k][i] <== inp_bits[ k*32 + (31-i) ];
    }
  }

  iv.out         ==> rds.inpHash;
  sch.outWords  ==> rds.words;
  rds.outHash   ==> outHash;

  for(var k=0; k<8; k++) {
    for(var i=0; i<32; i++) {
      outBits[ 32*k + i ] <== outHash[k][31-i];
    }
  }

}

//------------------------------------------------------------------------------
