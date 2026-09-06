pragma circom 2.0.0;
  
include "../sha2Common.circom";

//------------------------------------------------------------------------------
// message schedule for SHA224 / SHA256
//
// NOTE: the individual 64 bit words are in little-endian order 
//

template Sha2_224_256Shedule() {
  
  signal input  chunkBits[16][32];   // 512 bits = 16 dwords = 64 bytes
  signal output outWords [64];       // 64 dwords
  signal        outBits  [64][32];   // 2048 bits = 64 dwords = 256 bytes

  for(var k=0; k<16; k++) {
    var sum = 0;
    for(var i=0; i<32; i++) { sum += (1<<i) * chunkBits[k][i]; }
    outWords[k] <== sum;
    outBits [k] <== chunkBits[k];
  }

  component s0Xor [64-16][32];
  component s1Xor [64-16][32];
  component modulo[64-16];

  for(var m=16; m<64; m++) {
    var r = m-16;
    var k = m-15;
    var l = m- 2;

    var S0_SUM = 0;
    var S1_SUM = 0;
  
    for(var i=0; i<32; i++) {

      // note: with XOR3_v2, circom optimizes away the constant zero `z` thing
      // with XOR3_v1, it does not. But otherwise it's the same number of constraints.

      s0Xor[r][i] = XOR3_v2();
      s0Xor[r][i].x <==               outBits[k][ (i +  7) % 32 ]     ;
      s0Xor[r][i].y <==               outBits[k][ (i + 18) % 32 ]     ;
      s0Xor[r][i].z <== (i < 32- 3) ? outBits[k][ (i +  3)      ] : 0 ;
      S0_SUM += (1<<i) * s0Xor[r][i].out;
   
      s1Xor[r][i] = XOR3_v2();
      s1Xor[r][i].x <==               outBits[l][ (i + 17) % 32 ]     ;
      s1Xor[r][i].y <==               outBits[l][ (i + 19) % 32 ]     ;
      s1Xor[r][i].z <== (i < 32-10) ? outBits[l][ (i + 10)      ] : 0 ;
      S1_SUM += (1<<i) * s1Xor[r][i].out;

    }

    var tmp = S1_SUM + outWords[m-7] + S0_SUM + outWords[m-16] ;

    modulo[r] = Bits34();
    modulo[r].inp      <== tmp;
    modulo[r].outBits  ==> outBits [m];
    modulo[r].outWord ==> outWords[m];

  }
}

//------------------------------------------------------------------------------
