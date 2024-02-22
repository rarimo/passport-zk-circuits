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
    component _SMTVerifier = SMTVerifier(treeDepth);

    _SMTVerifier.root <== root;
    _SMTVerifier.secret <== secret;
    _SMTVerifier.nullifier <== nullifier;

    _SMTVerifier.siblings <== siblings;

    _SMTVerifier.isVerified === 1;
    
    // Setting the nullifierHash as an output to prevent double voting
    nullifierHash <== _SMTVerifier.nullifierHash;
    
    // Adding constraints on voting parameters
    // Squares are used to prevent optimizer from removing those constraints
    // The voting parameters are not used in any computation
    // signal _vote <== vote * vote;
    // signal _votingAddress <== votingAddress * votingAddress;
}

component main {public [root,
                        vote,
                        votingAddress]} = VoteSMT(80);