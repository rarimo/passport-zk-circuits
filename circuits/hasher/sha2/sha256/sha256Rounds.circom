pragma circom 2.0.0;
  
include "../sha2Common.circom";
include "sha256Compress.circom";
include "sha256RoundConst.circom";

//------------------------------------------------------------------------------
// execute `n` rounds of the SHA224 / SHA256 inner loop
// NOTE: hash state is stored as 8 dwords, each little-endian

template Sha2_224_256Rounds(n) {
 
  assert( n >  0  );
  assert( n <= 64 );

  signal input  words[n];            // round words (32-bit words)
  signal input  inpHash[8][32];     // initial state
  signal output outHash[8][32];     // final state after n rounds (n <= 64)

  signal  a [n+1][32];
  signal  b [n+1][32];
  signal  c [n+1][32];
  signal  dd[n+1];
  signal  e [n+1][32];
  signal  f [n+1][32];
  signal  g [n+1][32];
  signal  hh[n+1];

  signal ROUND_KEYS[64];
  component RC = Sha2_224_256RoundKeys();
  ROUND_KEYS <== RC.out;

  a[0] <== inpHash[0];
  b[0] <== inpHash[1];
  c[0] <== inpHash[2];

  e[0] <== inpHash[4];
  f[0] <== inpHash[5];
  g[0] <== inpHash[6];
  
  var sum_dd = 0;
  var sum_hh = 0;
  for(var i=0; i<32; i++) {
    sum_dd  +=  inpHash[3][i] * (1<<i);  
    sum_hh  +=  inpHash[7][i] * (1<<i);  
  }
  dd[0] <== sum_dd;
  hh[0] <== sum_hh;

  signal hashWords[8];
  for(var j=0; j<8; j++) {
    var sum = 0;
    for(var i=0; i<32; i++) {
      sum += (1<<i) * inpHash[j][i];
    }
    hashWords[j] <== sum;
  }

  component compress[n];  

  for(var k=0; k<n; k++) {

    compress[k] = Sha2_224_256CompressInner();

    compress[k].inp <== words[k];
    compress[k].key <== ROUND_KEYS[k];

    compress[k].a  <== a [k];
    compress[k].b  <== b [k];
    compress[k].c  <== c [k];
    compress[k].dd <== dd[k];
    compress[k].e  <== e [k];
    compress[k].f  <== f [k];
    compress[k].g  <== g [k];
    compress[k].hh <== hh[k];

    compress[k].outA  ==> a [k+1];
    compress[k].outB  ==> b [k+1];
    compress[k].outC  ==> c [k+1];
    compress[k].outDD ==> dd[k+1];
    compress[k].outE  ==> e [k+1];
    compress[k].outF  ==> f [k+1];
    compress[k].outG  ==> g [k+1];
    compress[k].outHH ==> hh[k+1];
  }

  component modulo[8];
  for(var j=0; j<8; j++) {
    modulo[j] = Bits33();
  }

  var sum_a = 0;
  var sum_b = 0;
  var sum_c = 0;
  var sum_e = 0;
  var sum_f = 0;
  var sum_g = 0;
  for(var i=0; i<32; i++) {
    sum_a += (1<<i) * a[n][i];
    sum_b += (1<<i) * b[n][i];
    sum_c += (1<<i) * c[n][i];
    sum_e += (1<<i) * e[n][i];
    sum_f += (1<<i) * f[n][i];
    sum_g += (1<<i) * g[n][i];
  }
  
  modulo[0].inp <== hashWords[0] + sum_a;
  modulo[1].inp <== hashWords[1] + sum_b;
  modulo[2].inp <== hashWords[2] + sum_c;
  modulo[3].inp <== hashWords[3] + dd[n];
  modulo[4].inp <== hashWords[4] + sum_e;
  modulo[5].inp <== hashWords[5] + sum_f;
  modulo[6].inp <== hashWords[6] + sum_g;
  modulo[7].inp <== hashWords[7] + hh[n];

  for(var j=0; j<8; j++) {
    modulo[j].outBits ==> outHash[j];
  }

}

// -----------------------------------------------------------------------------
