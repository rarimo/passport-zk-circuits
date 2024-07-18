pragma circom  2.1.6;

include "../../merkleTree/SMTVerifier.circom";

template ParticipationProof(treeDepth) {
    // Public outputs
    signal output challangedNullifier;

    // Public input signals
    signal input nullifiersTreeRoot;
    signal input participationEventId;
    signal input challengedEventId;
    
    // Private input signals
    signal input nullifiersTreeSiblings[20];
    signal input skIdentity;

    // Calculating nullifiers    
    component skIdentityHasher = Poseidon(1);
    skIdentityHasher.inputs[0] <== skIdentity;

    // nullifier => Poseidon3(sk_i, Poseidon1(sk_i), eventID)
    component challangedNullifierHasher = Poseidon(3);
    challangedNullifierHasher.inputs[0] <== skIdentity;
    challangedNullifierHasher.inputs[1] <== skIdentityHasher.out;
    challangedNullifierHasher.inputs[2] <== challengedEventId;

    challangedNullifier <== challangedNullifierHasher.out;

    component participationNullifierHasher = Poseidon(3);
    participationNullifierHasher.inputs[0] <== skIdentity;
    participationNullifierHasher.inputs[1] <== skIdentityHasher.out;
    participationNullifierHasher.inputs[2] <== participationEventId;

    // Verify identity tree
    component smtVerifier = SMTVerifier(treeDepth);
    smtVerifier.key <== participationNullifierHasher.out;
    smtVerifier.root <== nullifiersTreeRoot;
    smtVerifier.leaf <== participationNullifierHasher.out;
    smtVerifier.siblings <== nullifiersTreeSiblings;
    
    smtVerifier.isVerified === 1;
}