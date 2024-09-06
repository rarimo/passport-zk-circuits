pragma circom 2.0.0;
  
include "../sha2Common.circom";

//------------------------------------------------------------------------------
// SHA256 (and also SHA224) compression function inner loop
//
// note: the d,h,inp,key inputs (and outputs) are 32 bit numbers;
// the rest are little-endian bit vectors.

template Sha2_224_256CompressInner() {
  
  signal input inp;
  signal input key;

  signal input a[32];    
  signal input b[32];
  signal input c[32];
  signal input dd;
  signal input e[32];
  signal input f[32];
  signal input g[32];
  signal input hh;

  signal output outA[32];
  signal output outB[32];
  signal output outC[32];
  signal output outDD;
  signal output outE[32];
  signal output outF[32];
  signal output outG[32];
  signal output outHH;

  outG <== f;
  outF <== e;
  outC <== b;
  outB <== a;

  var d_sum = 0;
  var h_sum = 0;
  for(var i=0; i<32; i++) {
    d_sum += (1<<i) * c[i];
    h_sum += (1<<i) * g[i];
  }
  outDD <== d_sum;
  outHH <== h_sum;
  
  signal chb[32];

  component major[32];
  component s0Xor[32];
  component s1Xor[32];

  var S0_SUM = 0;
  var S1_SUM = 0;
  var mj_sum = 0;
  var ch_sum = 0;

  for(var i=0; i<32; i++) {

    // ch(e,f,g) = if e then f else g = e(f-g)+g
    chb[i] <== e[i] * (f[i] - g[i]) + g[i];    
    ch_sum += (1<<i) * chb[i];

    // maj(a,b,c) = at least two of them is 1 = second bit of the sum
    major[i] = Bits2();
    major[i].xy <== a[i] + b[i] + c[i];
    mj_sum += (1<<i) * major[i].hi;

    s0Xor[i] = XOR3_v2();
    s0Xor[i].x <== a[ (i +  2) % 32 ];
    s0Xor[i].y <== a[ (i + 13) % 32 ];
    s0Xor[i].z <== a[ (i + 22) % 32 ];
    S0_SUM += (1<<i) * s0Xor[i].out;

    s1Xor[i] = XOR3_v2();
    s1Xor[i].x <== e[ (i +  6) % 32 ]; 
    s1Xor[i].y <== e[ (i + 11) % 32 ];
    s1Xor[i].z <== e[ (i + 25) % 32 ];
    S1_SUM += (1<<i) * s1Xor[i].out;

  }

  signal owerflowE <== dd + hh + S1_SUM + ch_sum + key + inp;
  signal owerflowA <==      hh + S1_SUM + ch_sum + key + inp + S0_SUM + mj_sum;

  component decomposeE = Bits35();
  decomposeE.inp      <== owerflowE;
  decomposeE.outBits ==> outE;

  component decomposeA = Bits35();
  decomposeA.inp      <== owerflowA;
  decomposeA.outBits ==> outA;

}

//------------------------------------------------------------------------------
