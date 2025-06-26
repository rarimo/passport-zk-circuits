pragma circom  2.1.6;

include "./bitify.circom";

// template Num2Bits(n) {
//     signal input in;
//     signal output out[n];
//     var lc1=0;
//     var e2=1;
//     for (var i = 0; i<n; i++) {
//         out[i] <-- (in >> i) & 1;
//         out[i] * (out[i] -1 ) === 0;
//         lc1 += out[i] * e2;
//         e2 = e2+e2;
//     }
//     lc1 === in;
// }

component main{ public [in] }  = Num2Bits(254);