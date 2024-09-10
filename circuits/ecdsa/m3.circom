pragma circom  2.1.8;

include "./brainpoolP256r1/multiplyTest.dev.circom";

// component main = PipingerMultTest(43, 6);

component main = NonPipingerMultTest(43, 6);