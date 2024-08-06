pragma circom  2.1.6;

include "./SMTVerifier.circom";

template VoteSMT(treeDepth) {
    // In
    signal input root;

    signal input vote; // option voter has choosen
    signal input votingAddress; // address of the voting contract

    signal input secret;
    signal input nullifier;

    signal input siblings[treeDepth];

    // Out
    signal output nullifierHash; 

    // SMT inclusion verification
    component smtVerifier = SMTVerifier(treeDepth);

    smtVerifier.root <== root;
    smtVerifier.secret <== secret;
    smtVerifier.nullifier <== nullifier;

    smtVerifier.siblings <== siblings;

    smtVerifier.isVerified === 1;
    
    // Setting the nullifierHash as an output to prevent double voting
    nullifierHash <== smtVerifier.nullifierHash;
    
    // Adding constraints on voting parameters
    // Squares are used to prevent optimizer from removing those constraints
    // The voting parameters are not used in any computation
    signal voteSquare <== vote * vote;
    signal votingAddressSquare <== votingAddress * votingAddress;
}

component main {public [root,
                        vote,
                        votingAddress]} = VoteSMT(80);