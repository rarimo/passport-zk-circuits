pragma circom  2.1.6;

include "../../merkleTree/SMTVerifier.circom";

// Public signals:
// [0] challengedNullifier
// [1] nullifiersTreeRoot
// [2] participationEventId
// [3] challengedEventId

template ParticipationProof(treeDepth) {
    // Public outputs
    signal output challengedNullifier;

    // Public input signals
    signal input nullifiersTreeRoot;
    signal input participationEventId;
    signal input challengedEventId;
    
    // Private input signals
    signal input nullifiersTreeSiblings[treeDepth];
    signal input skIdentity;

    // Calculating nullifiers    
    component skIdentityHasher = Poseidon(1);
    skIdentityHasher.inputs[0] <== skIdentity;

    // nullifier => Poseidon3(sk_i, Poseidon1(sk_i), eventID)
    component challengedNullifierHasher = Poseidon(3);
    challengedNullifierHasher.inputs[0] <== skIdentity;
    challengedNullifierHasher.inputs[1] <== skIdentityHasher.out;
    challengedNullifierHasher.inputs[2] <== challengedEventId;

    challengedNullifier <== challengedNullifierHasher.out;

    component participationNullifierHasher = Poseidon(3);
    participationNullifierHasher.inputs[0] <== skIdentity;
    participationNullifierHasher.inputs[1] <== skIdentityHasher.out;
    participationNullifierHasher.inputs[2] <== participationEventId;

    // Verify nullifier tree state
    component smtVerifier = SMTVerifier(treeDepth);
    smtVerifier.key <== participationNullifierHasher.out;
    smtVerifier.root <== nullifiersTreeRoot;
    smtVerifier.leaf <== participationNullifierHasher.out;
    smtVerifier.siblings <== nullifiersTreeSiblings;
    
    smtVerifier.isVerified === 1;
}