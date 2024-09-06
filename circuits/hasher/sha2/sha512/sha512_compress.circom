pragma circom 2.0.0;
  
include "../sha2Common.circom";

//------------------------------------------------------------------------------
// SHA384 / SHA512 compression function inner loop
//
// note: the d,h,inp,key inputs (and outputs) are 64 bit numbers;
// the rest are little-endian bit vectors.

template SHA2_384_512_compress_inner() {
  
  signal input inp;
  signal input key;

  signal input a[64];    
  signal input b[64];
  signal input c[64];
  signal input dd;
  signal input e[64];
  signal input f[64];
  signal input g[64];
  signal input hh;

  signal output out_a[64];
  signal output out_b[64];
  signal output out_c[64];
  signal output out_dd;
  signal output out_e[64];
  signal output out_f[64];
  signal output out_g[64];
  signal output out_hh;

  var d_sum = 0;
  var h_sum = 0;
  for(var i=0; i<64; i++) {
    out_g[i] <== f[i];
    out_f[i] <== e[i];
    out_c[i] <== b[i];
    out_b[i] <== a[i];
    d_sum += (1<<i) * c[i];
    h_sum += (1<<i) * g[i];
  }
  out_dd <== d_sum;
  out_hh <== h_sum;
  
  signal chb[64];

  component major[64];
  component s0Xor[64];
  component s1Xor[64];

  var S0_SUM = 0;
  var S1_SUM = 0;
  var mj_sum = 0;
  var ch_sum = 0;

  for(var i=0; i<64; i++) {

    // ch(e,f,g) = if e then f else g = e(f-g)+g
    chb[i] <== e[i] * (f[i] - g[i]) + g[i];    
    ch_sum += (1<<i) * chb[i];

    // maj(a,b,c) = at least two of them is 1 = second bit of the sum
    major[i] = Bits2();
    major[i].xy <== a[i] + b[i] + c[i];
    mj_sum += (1<<i) * major[i].hi;

    s0Xor[i] = XOR3_v2();
    s0Xor[i].x <== a[ (i + 28) % 64 ];
    s0Xor[i].y <== a[ (i + 34) % 64 ];
    s0Xor[i].z <== a[ (i + 39) % 64 ];
    S0_SUM += (1<<i) * s0Xor[i].out;

    s1Xor[i] = XOR3_v2();
    s1Xor[i].x <== e[ (i + 14) % 64 ]; 
    s1Xor[i].y <== e[ (i + 18) % 64 ];
    s1Xor[i].z <== e[ (i + 41) % 64 ];
    S1_SUM += (1<<i) * s1Xor[i].out;

  }

  signal overflow_e <== dd + hh + S1_SUM + ch_sum + key + inp;
  signal overflow_a <==      hh + S1_SUM + ch_sum + key + inp + S0_SUM + mj_sum;

  component decompose_e = Bits67();
  decompose_e.inp      <== overflow_e;
  decompose_e.outBits ==> out_e;

  component decompose_a = Bits67();
  decompose_a.inp      <== overflow_a;
  decompose_a.outBits ==> out_a;

}

//------------------------------------------------------------------------------
