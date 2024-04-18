pragma circom  2.1.6;

include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "dg1DataExtractor.circom";
include "identityStateVerifier.circom";
include "../../dateUtilities/dateComparisonEncoded.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";

// QUERY SELECTOR:
// 0 - nullifier   (+)
// 1 - birth date  (+)
// 2 - expiration date (+)
// 3 - name (+)
// 4 - nationality (+)
// 5 - citizenship (+)
// 6 - sex (+)
// 7 - document number (+)
// 8 - timestamp lowerbound (+)
// 9 - timestamp upperbound (+)
// 10 - identity counter lowerbound (+)
// 11 - identity counter upperbound (+)
// 12 - passport expiration lowerbound
// 13 - passport expiration upperbound
// 14 - birth date upperbound
// 15 - birth date lowerbound
// 16 - verify citizenship mask as a whitelist
// 17 - verify citizenship mask as a blacklist

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
    signal input eventData;     // event data binded to the proof; not involved in comp
    signal input idStateRoot;   // identity state Merkle root
    signal input selector;      //  blinds personal data | 0 is not used 

    // query parameters (set 0 if not used)
    signal input timestampLowerbound;  // identity is issued in this time range
    signal input timestampUpperbound;  // timestamp E [timestampLowerbound, timestampUpperbound)

    signal input identityCounterLowerbound; // Number of identities connected to the specific passport
    signal input identityCounterUpperbound; // identityCounter E [timestampLowerbound, timestampUpperbound)

    signal input birthDateLowerbound;  // birthDateLowerbound < birthDate
    signal input birthDateUpperbound;  // birthDate < birthDateUpperbound

    signal input expirationDateLowerbound; // expirationDateLowerbound < expirationDate
    signal input expirationDateUpperbound; // expirationDate < expirationDateUpperbound

    signal input citizenshipMask;      // binary mask to whitelist | blacklist citizenships

    // private signals
    signal input skIdentity;
    signal input pkPassportHash;
    signal input dg1[744];      // 744 bits
    signal input idStateSiblings[80];  // identity tree inclusion proof
    signal input timestamp;
    signal input identityCounter;

    // selector decoding
    component selectorBits = Num2Bits(18);
    selectorBits.in <== selector;

    // ----------------------
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

    // Nullifier calculation
    component skIdentityHasher = Poseidon(1);
    skIdentityHasher.inputs[0] <== skIdentity;

    component nulliferHasher = Poseidon(3);
    nulliferHasher.inputs[0] <== skIdentity;
    nulliferHasher.inputs[1] <== skIdentityHasher.out;
    nulliferHasher.inputs[2] <== eventID;

    nullifier <== nulliferHasher.out * selectorBits.out[0];

    // --------------------------
    // Timestamp lowerbound check
    component greaterEqThanLowerTime = GreaterEqThan(64); // compare up to 2**64
    greaterEqThanLowerTime.in[0] <== timestamp;
    greaterEqThanLowerTime.in[1] <== timestampLowerbound;
    
    component timestampLowerboundCheck = ForceEqualIfEnabled();
    timestampLowerboundCheck.in[0] <== greaterEqThanLowerTime.out;
    timestampLowerboundCheck.in[1] <== 1;
    timestampLowerboundCheck.enabled <== selectorBits.out[8];

    // Timestamp upperbound check
    component lessThanUpperTime = LessThan(64); // compare up to 2**64
    lessThanUpperTime.in[0] <== timestamp;
    lessThanUpperTime.in[1] <== timestampUpperbound;

    component timestampUpperboundCheck = ForceEqualIfEnabled();
    timestampUpperboundCheck.in[0] <== lessThanUpperTime.out;
    timestampUpperboundCheck.in[1] <== 1;
    timestampUpperboundCheck.enabled <== selectorBits.out[9];

    //---------------------------------
    // Identity counter lowerbound check
    component greaterEqThanIdentity = GreaterEqThan(64);
    greaterEqThanIdentity.in[0] <== identityCounter;
    greaterEqThanIdentity.in[1] <== identityCounterLowerbound;

    component identityCounterLowerCheck = ForceEqualIfEnabled();
    identityCounterLowerCheck.in[0] <== greaterEqThanLowerTime.out;
    identityCounterLowerCheck.in[1] <== 1;
    identityCounterLowerCheck.enabled <== selectorBits.out[10];

    // Identity counter upperbound
    component lessThanIdentity = LessThan(64);
    lessThanIdentity.in[0] <== identityCounter;
    lessThanIdentity.in[1] <== identityCounterUpperbound;

    component identityCounterUpperCheck = ForceEqualIfEnabled();
    identityCounterUpperCheck.in[0] <== lessThanIdentity.out;
    identityCounterUpperCheck.in[1] <== 1;
    identityCounterUpperCheck.enabled <== selectorBits.out[11];

    // Expiration date lowerbound: expirationDateLowerbound < expirationDate
    component expirationDateLowerboundCompare = EncodedDateIsLess();
    expirationDateLowerboundCompare.first <== expirationDateLowerbound;
    expirationDateLowerboundCompare.second <== expirationDate;

    component verifyExpirationDateLowerbound = ForceEqualIfEnabled();
    verifyExpirationDateLowerbound.in[0] <== expirationDateLowerboundCompare.out;
    verifyExpirationDateLowerbound.in[1] <== 1;
    verifyExpirationDateLowerbound.enabled <== selectorBits.out[12];

    // Expiration date upperbound: expirationDate < expirationDateUpperbound
    component expirationDateUpperboundCompare = EncodedDateIsLess();
    expirationDateUpperboundCompare.first <== expirationDate;
    expirationDateUpperboundCompare.second <== expirationDateUpperbound;

    component verifyExpirationDateUpperbound = ForceEqualIfEnabled();
    verifyExpirationDateUpperbound.in[0] <== expirationDateUpperboundCompare.out;
    verifyExpirationDateUpperbound.in[1] <== 1;
    verifyExpirationDateUpperbound.enabled <== selectorBits.out[12];

    // Retrieve DGCommit: DG1 hash 744 bits => 4 * 186
    component dg1Chunking[4];
    component dg1Hasher = Poseidon(5);
    for (var i = 0; i < 4; i++) {
        dg1Chunking[i] = Bits2Num(186);
        for (var j = 0; j < 186; j++) {
            dg1Chunking[i].in[j] <== dg1[i * 186 + j]; 
        }
        dg1Hasher.inputs[i] <== dg1Chunking[i].out;
    }

    component skIndentityHasher = Poseidon(1);   //skData = Poseidon(skIdentity)
    skIndentityHasher.inputs[0] <== skIdentity;
    dg1Hasher.inputs[4] <== skIndentityHasher.out;

    // Bind event data
    signal eventDataSquare <== eventData * eventData;

    // Verify identity ownership
    component identityStateVerifier = IdentityStateVerifier(idTreeDepth);
    identityStateVerifier.skIdentity <== skIdentity;
    identityStateVerifier.pkPassHash <== pkPassportHash;
    identityStateVerifier.dgCommit <== dg1Hasher.out;
    identityStateVerifier.identityCounter <== identityCounter;
    identityStateVerifier.timestamp <== timestamp;

    identityStateVerifier.idStateRoot <== idStateRoot;
    identityStateVerifier.idStateSiblings <== idStateSiblings;
}