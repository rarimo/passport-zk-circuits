pragma circom  2.1.6;

include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "dg1DataExtractor.circom";
include "identityStateVerifier.circom";

template QueryIdentity(idTreeDepth) {
    signal output nullifier;    // Poseidon3(sk_i, Poseidon1(sk_i), eventID)

    signal output birthDate;
    signal output expirationDate;
    signal output name;
    signal output nameResidual;
    signal output nationality;
    signal output citizenship;
    signal output sex;
    signal output documentNumber;
    
    // public signals
    signal input eventID;       // challenge
    signal input idStateRoot;  // identity state Merkle root
    signal input selector;      //  blinds personal data
    signal input timestampLowerbound;  // identity is issued in this time range
    signal input timestampUpperbound;  // timestamp E [timestampLowerBound, timestampUpperBound)

    // private signals
    signal input skIdentity;
    signal input pkPassportHash;
    signal input dg1[744];      // 744 bits
    signal input idStateSiblings[80];  // identity tree inclusion proof
    signal input timestamp;
    signal input identityCounter;

    // selector decoding
    component selectorBits = Num2Bits(12);
    selectorBits.in <== selector;

    // SELECTOR:
    // 0 - nullifier
    // 1 - birth date
    // 2 - expiration date
    // 3 - name
    // 4 - nationality
    // 5 - citizenship
    // 6 - sex
    // 7 - document number
    // 8 - verify timestamp lowerbound
    // 9 - verify timestamp upperbound
    // 10 - verify 

    // Nullifier calculation
    component skIdentityHasher = Poseidon(1);
    skIdentityHasher.inputs[0] <== skIdentity;

    component nulliferHasher = Poseidon(3);
    nulliferHasher.inputs[0] <== skIdentity;
    nulliferHasher.inputs[1] <== skIdentityHasher.out;
    nulliferHasher.inputs[2] <== eventID;

    nullifier <== nulliferHasher.out * selectorBits.out[0];

    // Passport data decoding
    component dg1DataExtractor = DG1DataExtractor();
    dg1DataExtractor.dg1 <== dg1;

    birthDate <== dg1DataExtractor.birthDate * selectorBits.out[1];
    expirationDate <== dg1DataExtractor.expirationDate * selectorBits.out[2];
    name <== dg1DataExtractor.name * selectorBits.out[3];
    nameResidual <== dg1DataExtractor.nameResidual * selectorBits.out[3];
    nationality <== dg1DataExtractor.nationality * selectorBits.out[4];
    citizenship <== dg1DataExtractor.citizenship * selectorBits.out[5];
    sex <== dg1DataExtractor.sex * selectorBits.out[6];
    documentNumber <== dg1DataExtractor.documentNumber * selectorBits.out[7];

    // Verify identity ownership
    component identityStateVerifier = IdentityStateVerifier(idTreeDepth);
    identityStateVerifier.skIdentity <== skIdentity;
    identityStateVerifier.pkPassHash <== pkPassportHash;
    identityStateVerifier.dgCommit <== pkPassportHash;    // change to dgCommit
    identityStateVerifier.identityCounter <== identityCounter;
    identityStateVerifier.timestamp <== timestamp;

    identityStateVerifier.idStateRoot <== idStateRoot;
    identityStateVerifier.idStateSiblings <== idStateSiblings;
}