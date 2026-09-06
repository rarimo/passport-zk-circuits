pragma circom 2.1.6;

include "./parity.circom";
include "circomlib/circuits/sha256/maj.circom";
include "circomlib/circuits/sha256/ch.circom";

template fT(T) {
     signal input b[32];
     signal input c[32];
     signal input d[32];
     signal output out[32];

     component maj = Maj_t(32);
     component parity = ParityT(32);
     component ch = Ch_t(32);

     // ch(x, y, z)
     for (var k = 0 ; k < 32; k++) {
          ch.a[k] <== b[k];
          ch.b[k] <== c[k];
          ch.c[k] <== d[k];
     }

     // parity(x, y, z)
     for (var k = 0 ; k < 32; k++) {
          parity.a[k] <== b[k];
          parity.b[k] <== c[k];
          parity.c[k] <== d[k];
     }

     // maj(x, y, z)
     for (var k = 0 ; k < 32; k++) {
          maj.a[k] <== b[k];
          maj.b[k] <== c[k];
          maj.c[k] <== d[k];
     }

     if (T <= 19) {
          for (var k = 0 ; k < 32; k++) {
               out[k] <== ch.out[k];
          }
     } else {
          if (T <= 39 || T >= 60) {
               for (var k = 0 ; k < 32; k++) {
                    out[k] <== parity.out[k];
               }
          } else {
               for (var k = 0 ; k < 32; k++) {
                    out[k] <== maj.out[k];
               }
          }
     }
}