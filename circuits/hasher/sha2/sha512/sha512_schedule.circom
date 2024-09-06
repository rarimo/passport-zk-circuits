pragma circom 2.0.0;
  
include "../sha2Common.circom";

//------------------------------------------------------------------------------
// message schedule for SHA384 / SHA512
//
// NOTE: the individual 64 bit words are in little-endian order 
//

template SHA2_384_512_schedule() {
  
  signal input  chunkBits[16][64];   // 1024 bits = 16 qwords = 128 bytes
  signal output outWords [80];       // 80 words
  signal        outBits  [80][64];   // 5120 bits = 80 qwords = 640 bytes

  for(var k=0; k<16; k++) {
    var sum = 0;
    for(var i=0; i<64; i++) { sum += (1<<i) * chunkBits[k][i]; }
    outWords[k] <== sum;
    outBits [k] <== chunkBits[k];
  }

  component s0Xor [80-16][64];
  component s1Xor [80-16][64];
  component modulo[80-16];

  for(var m=16; m<80; m++) {
    var r = m-16;
    var k = m-15;
    var l = m- 2;

    var S0_SUM = 0;
    var S1_SUM = 0;
  
    for(var i=0; i<64; i++) {

      // note: with XOR3_v2, circom optimizes away the constant zero `z` thing
      // with XOR3_v1, it does not. But otherwise it's the same number of constraints.

      s0Xor[r][i] = XOR3_v2();
      s0Xor[r][i].x <==               outBits[k][ (i +  1) % 64 ]     ;
      s0Xor[r][i].y <==               outBits[k][ (i +  8) % 64 ]     ;
      s0Xor[r][i].z <== (i < 64- 7) ? outBits[k][ (i +  7)      ] : 0 ;
      S0_SUM += (1<<i) * s0Xor[r][i].out;
   
      s1Xor[r][i] = XOR3_v2();
      s1Xor[r][i].x <==               outBits[l][ (i + 19) % 64 ]     ;
      s1Xor[r][i].y <==               outBits[l][ (i + 61) % 64 ]     ;
      s1Xor[r][i].z <== (i < 64- 6) ? outBits[l][ (i +  6)      ] : 0 ;
      S1_SUM += (1<<i) * s1Xor[r][i].out;

    }

    var tmp = S1_SUM + outWords[m-7] + S0_SUM + outWords[m-16] ;

    modulo[r] = Bits66();
    modulo[r].inp      <== tmp;
    modulo[r].outBits ==> outBits [m];
    modulo[r].out_word ==> outWords[m];

  }
}

//------------------------------------------------------------------------------
