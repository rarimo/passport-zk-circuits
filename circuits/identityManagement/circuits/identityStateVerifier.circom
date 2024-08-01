pragma circom  2.1.6;

include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/babyjub.circom";
include "../../merkleTree/SMTVerifier.circom";
// include "@solarity/circom-lib/data-structures/SparseMerkleTree.circom";

template IdentityStateVerifier(idTreeDepth) {
    signal input skIdentity;
    signal input pkPassHash;
    signal input dgCommit;
    signal input identityCounter;
    signal input timestamp;

    signal input idStateRoot;
    signal input idStateSiblings[idTreeDepth];

    // Retrieve pkIdentity from skIdentity + proving id ownership
    component babyPbk = BabyPbk();
    babyPbk.in <== skIdentity;

    // Hashing identity pk
    component pkIdentityHasher = Poseidon(2);
    pkIdentityHasher.inputs[0] <== babyPbk.Ax;
    pkIdentityHasher.inputs[1] <== babyPbk.Ay;
    
    // Identity tree position
    component positionHasher = Poseidon(2);
    positionHasher.inputs[0] <== pkPassHash;
    positionHasher.inputs[1] <== pkIdentityHasher.out;
    signal treePosition <== positionHasher.out;

    // Identity tree value
    component valueHasher = Poseidon(3);
    valueHasher.inputs[0] <== dgCommit;
    valueHasher.inputs[1] <== identityCounter;
    valueHasher.inputs[2] <== timestamp;

    // Verify identity tree
    component smtVerifier = SMTVerifier(idTreeDepth);
    smtVerifier.key <== treePosition;
    smtVerifier.root <== idStateRoot;
    smtVerifier.leaf <== valueHasher.out;
    smtVerifier.siblings <== idStateSiblings;
    
    smtVerifier.isVerified === 1;
}