pragma circom  2.1.6;

include "../lib/circuits/hasher/hash.circom";
include "../lib/circuits/babyjubjub/curve.circom";
include "../merkleTree/SMTVerifier.circom";
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
    component pkIdentityHasher = PoseidonHash(2);
    pkIdentityHasher.in[0] <== babyPbk.Ax;
    pkIdentityHasher.in[1] <== babyPbk.Ay;
    
    // Identity tree position
    component positionHasher = PoseidonHash(2);
    positionHasher.in[0] <== pkPassHash;
    positionHasher.in[1] <== pkIdentityHasher.out;
    signal treePosition <== positionHasher.out;

    // Identity tree value
    component valueHasher = PoseidonHash(3);
    valueHasher.in[0] <== dgCommit;
    valueHasher.in[1] <== identityCounter;
    valueHasher.in[2] <== timestamp;

    // Verify identity tree
    component smtVerifier = SMTVerifier(idTreeDepth);
    smtVerifier.key <== treePosition;
    smtVerifier.root <== idStateRoot;
    smtVerifier.leaf <== valueHasher.out;
    smtVerifier.siblings <== idStateSiblings;
    
    smtVerifier.isVerified === 1;
}