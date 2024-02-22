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
    component _SMTVerifier_1 = SMTVerifier(treeDepth);

    _SMTVerifier_1.root <== root1;
    _SMTVerifier_1.secret <== secret;
    _SMTVerifier_1.nullifier <== nullifier;

    _SMTVerifier_1.siblings <== siblings;

    // SMT inclusion verification. 2nd tree check
    component _SMTVerifier_2 = SMTVerifier(treeDepth);

    _SMTVerifier_2.root <== root2;
    _SMTVerifier_2.secret <== secret;
    _SMTVerifier_2.nullifier <== nullifier;

    _SMTVerifier_2.siblings <== siblings;

    // Check whether there is any successful inclusion in the provided tree roots
    signal totalInclusion <== _SMTVerifier_1.isVerified + _SMTVerifier_2.isVerified;

    component isAnyVerified = LessThan(3);
    
    isAnyVerified.in[0] <== 0;
    isAnyVerified.in[1] <== totalInclusion;

    isAnyVerified.out === 1;
    
    // Setting the nullifierHash as an output to prevent double voting
    nullifierHash <== _SMTVerifier_1.nullifierHash;
    
    // Adding constraints on voting parameters
    // Squares are used to prevent optimizer from removing those constraints
    // The voting parameters are not used in any computation
    signal _vote <== vote * vote;
    signal _votingAddress <== votingAddress * votingAddress;
}

component main {public [root1,
                        root2,
                        vote,
                        votingAddress]} = VoteSMT2(80);