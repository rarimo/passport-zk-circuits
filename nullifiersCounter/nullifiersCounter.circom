// LICENSE: GPL-3.0
pragma circom  2.1.6;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "../merkleTree/merkleTree.circom";

// BuildNullifier creates a new nullifier from documentHash, blinder and salt in the same way as it 
// is implemented in identity relayer
template BuildNullifier() {
    signal input salt;
    signal input blinder;
    signal input documentHash;

    signal output nullifier;

    component hasher = Poseidon(3);

    documentHash ==> hasher.inputs[0];
    blinder ==> hasher.inputs[1];
    salt ==> hasher.inputs[2];

    nullifier <== hasher.out;
}

template CountNullifiers(nullifiersCount, treeDepth) {
    // Hash of the document to prove nullifiers amount
    signal input documentHash;
    // Blinder factor from identity provider
    signal input blinder;
    // Salt that was added to the documentHash and blinder to create unique nullifiers in the identity provider
    signal input salt[nullifiersCount];

    // Root from tree that was built from nullifiers 
    signal input root;
    // Missing siblings to build root
    signal input proofsBranches[nullifiersCount][treeDepth];
    // Hashing orders to build elements (contains 0 and 1)
    signal input proofsOrder[nullifiersCount][treeDepth];

    // Array with flags that shows if proof is built or not, count of 1 in this output indicates the total amount 
    // of nullifiers that were created for the document
    signal output totalDuplicates;
    // Commitment for the blinder value
    signal output blinderCommitment;
    // Commitment for the preimage for nullifiers 
    signal output documentCommitment;
    
    // Components to build nullifiers
    component nullifierBuilders[nullifiersCount];
    // Components to recover Merkle tree root
    component merkleTreeVerifiers[nullifiersCount];
    // Components to compare recovered roots with required one
    component comparators[nullifiersCount];
    // Components to hash leaves for inclusion proving
    component leavesHashers[nullifiersCount];

    signal verified[nullifiersCount];

    component blinderCommitmentHasher = Poseidon(1);
    blinderCommitmentHasher.inputs[0] <== blinder;
    blinderCommitment <== blinderCommitmentHasher.out;

    component documentCommitmentHasher = Poseidon(2);
    documentCommitmentHasher.inputs[0] <== documentHash;
    documentCommitmentHasher.inputs[1] <== blinder;
    documentCommitment <== documentCommitmentHasher.out;

    // Loop over all possible nullifiers 
    for (var i = 0; i < nullifiersCount; i++) {
        // Init new nullifier builder
        nullifierBuilders[i] = BuildNullifier();

        // Set salt from identity provider
        nullifierBuilders[i].salt <== salt[i];
        // Set blinder from identity provider
        nullifierBuilders[i].blinder <== blinder;
        // Set document hash from which nullifier was built
        nullifierBuilders[i].documentHash <== documentHash;

        // Create new root recoverer with required tree depth
        merkleTreeVerifiers[i] = MerkleTreeVerifier(treeDepth);

        // Leaves are hashed in the tree
        leavesHashers[i] = Poseidon(1);
        leavesHashers[i].inputs[0] <== nullifierBuilders[i].nullifier;

        // Set raw nullifier as the leaf
        merkleTreeVerifiers[i].leaf <== leavesHashers[i].out;
        // Set Merkle branch for that nullifier 
        merkleTreeVerifiers[i].merkleBranches <== proofsBranches[i];
        // Set Merkle order fot the same nullifier
        merkleTreeVerifiers[i].merkleOrder <== proofsOrder[i];
        // Set Merkle root
        merkleTreeVerifiers[i].merkleRoot <== root;

        // Write to the output array result:
        // 1 - nullifier exists in the tree (generated from documentHash)
        // 0 - nullifier is not related to the document
        verified[i] <== merkleTreeVerifiers[i].isVerified;
    }
    
    signal tempSum[nullifiersCount];
    tempSum[0] <== verified[0];

    for (var i = 1; i < nullifiersCount; i++) {
        tempSum[i] <== tempSum[i - 1] + verified[i]; 
    }
    totalDuplicates <== tempSum[nullifiersCount - 1];
}


// TBD: nullifiers counter and tree depth to set optimal values
component main = CountNullifiers(4, 2);
