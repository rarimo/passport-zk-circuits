pragma circom  2.1.6;

include "./SMTVerifier.circom";

template VoteSMT2(treeDepth) {
    // In
    signal input root1;
    signal input root2;

    signal input vote; // option voter has choosen
    signal input votingAddress; // address of the voting contract

    signal input secret;
    signal input nullifier;

    signal input siblings[treeDepth];

    // Out
    signal output nullifierHash; 

    // SMT inclusion verification. 1st tree check
    component smtVerifier1 = SMTVerifier(treeDepth);

    smtVerifier1.root <== root1;
    smtVerifier1.secret <== secret;
    smtVerifier1.nullifier <== nullifier;

    smtVerifier1.siblings <== siblings;

    // SMT inclusion verification. 2nd tree check
    component smtVerifier2 = SMTVerifier(treeDepth);

    smtVerifier2.root <== root2;
    smtVerifier2.secret <== secret;
    smtVerifier2.nullifier <== nullifier;

    smtVerifier2.siblings <== siblings;

    // Check whether there is any successful inclusion in the provided tree roots
    signal totalInclusion <== smtVerifier1.isVerified + smtVerifier2.isVerified;

    component isEqual = IsEqual();

    isEqual.in[0] <== totalInclusion;
    isEqual.in[1] <== 1;

    // totalInclusion should be 1 if the commitment is included into one of the trees.
    isEqual.out === 1;
    
    // Setting the nullifierHash as an output to prevent double voting
    nullifierHash <== smtVerifier1.nullifierHash;
    
    // Adding constraints on voting parameters
    // Squares are used to prevent optimizer from removing those constraints
    // The voting parameters are not used in any computation
    signal voteSquare <== vote * vote;
    signal votingAddressSquare <== votingAddress * votingAddress;
}

component main {public [root1,
                        root2,
                        vote,
                        votingAddress]} = VoteSMT2(80);