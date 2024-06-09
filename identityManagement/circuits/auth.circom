pragma circom  2.1.6;

include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/babyjub.circom";

// Public signals order
// [0] - nullifier
// [1] - pkIdentityHash
// [2] - eventId
// [3] - eventData
// [4] - revealPkIdentityHash

template Auth() {
    signal output nullifier;    // Poseidon3(sk_i, Poseidon1(sk_i), eventID)
    signal output pkIdentityHash;

    // public
    signal input eventID;       // challenge
    signal input eventData;     // event data binded to the proof; not involved in comp
    signal input revealPkIdentityHash; // 0 - NOT, 1 - REVEAL

    // private
    signal input skIdentity;

    // Force revealPk equals 0 or 1
    0 === (revealPkIdentityHash - 1) * revealPkIdentityHash;

    // Retrieve pkIdentity from skIdentity + proving id ownership
    component babyPbk = BabyPbk();
    babyPbk.in <== skIdentity;

    // Hashing identity pk
    component pkIdentityHasher = Poseidon(2);
    pkIdentityHasher.inputs[0] <== babyPbk.Ax;
    pkIdentityHasher.inputs[1] <== babyPbk.Ay;

    pkIdentityHash <== pkIdentityHasher.out * revealPkIdentityHash;

    // Nullifier calculation
    component skIdentityHasher = Poseidon(1);
    skIdentityHasher.inputs[0] <== skIdentity;

    component nulliferHasher = Poseidon(3);
    nulliferHasher.inputs[0] <== skIdentity;
    nulliferHasher.inputs[1] <== skIdentityHasher.out;
    nulliferHasher.inputs[2] <== eventID;

    nullifier <== nulliferHasher.out;

    // Adding constraint on eventData
    signal eventDataSq <== eventData * eventData;
}
