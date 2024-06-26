
pragma circom  2.1.6;

include "./circuits/registerIdentity.circom";

// pub signals:
// [0]  -  dg15PubKeyHash
// [1]  -  dg1Commitment
// [2]  -  pkIdentityHash
// [3]  -  icaoMerkleRoot
component main { public [icaoMerkleRoot] } = RegisterIdentity(64, 64, 17, 4, 20, 2704, 264, 2448, 2520, 592);