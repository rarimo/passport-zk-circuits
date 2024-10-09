pragma circom 2.1.6;

include  "./circuits/registerIdentityBuilder.circom";

component main { public [slaveMerkleRoot] } = RegisterIdentityBuilder(
  8,  //dg15 chunk number
  8, //encapsulated content chunk number
  512, //hash chunk size
  256, //hash type
  1, //sig_algo
  0, //salt
  17, // e_bits
  64, //chunk size
  32, //chunk_num
  512, //dg hash size chunk size
  256, //dg hash algo
  3, //document type
  80, //merkle tree depth
  [
  [248, 2432, 576, 5, 6, 1],
  [248, 2432, 336, 3, 6, 1],
  [248, 2432, 576, 3, 6, 1],
  [264, 2448, 576, 3, 4, 1],
  [264, 1496, 600, 3, 4, 1],
  [248, 1496, 600, 3, 4, 1],
  [232, 1480, 336, 5, 4, 1],
  [248, 2448, 576, 6, 6, 1],
  [264, 2448, 336, 6, 6, 1],
  [248, 256,  336, 6, 3, 0],
  [248, 356,  576, 6, 3, 0],
  [248, 256,  336, 6, 5, 0],
  [232, 256,  336, 6, 4, 0],
  [248, 256,  576, 1, 5, 0]
  ], //flow matrix
  14, //flow matrix height
  [
   [1, 0, 1, 0, 1, 1, 0, 0],
   [0, 0, 1, 1, 1, 1, 0, 0]
  ] //hash block matrix
);