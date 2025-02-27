pragma circom 2.1.6;

include "./rotate.circom";
include "circomlib/circuits/binsum.circom";
include "circomlib/circuits/comparators.circom";
include "./f.circom";
include "./constants.circom";

template T(t) {
     signal input a[32];
     signal input b[32];
     signal input c[32];
     signal input d[32];
     signal input e[32];
     signal input kT[32];
     signal input w[32];

     signal output out[32];

     component rotatel5 = RotL(32, 5);
     component f = fT(t);

     var k;
     for (k = 0; k < 32; k++) {
          rotatel5.in[k] <== a[k];
          f.b[k] <== b[k];
          f.c[k] <== c[k];
          f.d[k] <== d[k];
     }

     component sum_binary = BinSum(32, 5);
     var nout = 35; // in BinSum: nbits((2**32 -1)*5);

     for (k = 0; k < 32; k++) {
          sum_binary.in[0][k] <== rotatel5.out[31  - k];
          sum_binary.in[1][k] <== f.out[31 - k];
          sum_binary.in[2][k] <== e[31 - k];
          sum_binary.in[3][k] <== kT[31 - k];
          sum_binary.in[4][k] <== w[31 - k];
     }

     component sum = Bits2Num(nout);
     for (k = 0; k < nout; k++) {
          sum.in[k] <== sum_binary.out[k];
     }

     // perform sum modulo 32
     signal sumModulo;
     signal quotient;
     component lessThan = LessThan(33);

     sumModulo <-- sum.out % 2**32;
     quotient <-- sum.out \ 2**32;

     lessThan.in[0] <== sumModulo;
     lessThan.in[1] <== 2**32;

     sum.out === quotient * 2**32 + sumModulo;
     1 === lessThan.out;
     
     // reconvert to bit array
     component sumBinaryModulo = Num2Bits(32);
     sumBinaryModulo.in <== sumModulo; 

     for (k = 0; k < 32; k++) {
          out[k] <== sumBinaryModulo.out[31 - k];
     }
}