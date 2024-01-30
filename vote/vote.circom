pragma circom  2.1.6;
include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

include "../merkleTree/merkleTree.circom";

template CommitmentHasher() {
    signal input nullifier;
    signal input secret;
    signal output commitment;
    signal output nullifierHash;

    component commitmentHasher = Poseidon(2);
    component nullifierHasher = Poseidon(1);
    
    commitmentHasher.inputs[0] <== nullifier;
    commitmentHasher.inputs[1] <== secret;
    nullifierHasher.inputs[0] <== nullifier;

    commitment <== commitmentHasher.out;
    nullifierHash <== nullifierHasher.out;
}

// Verifies that commitment that corresponds to given secret and nullifier is included in the merkle tree of deposits
template Vote(levels) {
    signal input root;                 // public; MiMC hash for the tree
    signal input nullifierHash;        // public; Poseidon Hash
    signal input vote;                 // public; not taking part in any computations; binds the vote to the proof
    signal input nullifier;            // private
    signal input secret;               // private
    signal input pathElements[levels]; // private
    signal input pathIndices[levels];  // private; 0 - left, 1 - right

    component hasher = CommitmentHasher();
    hasher.nullifier <== nullifier;
    hasher.secret <== secret;
    hasher.nullifierHash === nullifierHash;

    component tree = MerkleTreeVerifier(levels);
    tree.leaf <== hasher.commitment;
    tree.merkleRoot <== root;
    for (var i = 0; i < levels; i++) {
        tree.merkleBranches[i] <== pathElements[i];
        tree.merkleOrder[i] <== pathIndices[i];
    }

    // Add hidden signals to make sure that tampering with a vote will invalidate the snark proof
    // Squares are used to prevent optimizer from removing those constraints

    signal voteSquare;
    voteSquare <== vote * vote;
}

component main {public [root, nullifierHash, vote]} = Vote(20);
