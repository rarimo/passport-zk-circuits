pragma circom  2.1.6;

include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/poseidon.circom";
include "dg1DataExtractor.circom";
include "identityStateVerifier.circom";
include "../../dateUtilities/dateComparisonEncoded.circom";
include "circomlib/circuits/comparators.circom";
include "../../dateUtilities/dateComparisonEncodedNormalized.circom";
include "./citizenshipCheck.circom";

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
// 14 - birth date lowerbound
// 15 - birth date upperbound
// 16 - verify citizenship mask as a whitelist
// 17 - verify citizenship mask as a blacklist

// Passport encoding time is UTF-8 "YYMMDD"
// Timestamps has 2 times of encoding: 
// - standard (UNIX) timestamp, like 1716482295 (UT - UNIX timestamp)
// - passport timestamp, like UTF-8 "010203" -> 0x303130323033 -> 52987820126259 (PT - passport timestamp)

template QueryIdentity(idTreeDepth) {
    signal output nullifier;    // Poseidon3(sk_i, Poseidon1(sk_i), eventID)

    signal output birthDate;       // *(PT - passport timestamp)
    signal output expirationDate;  // *(PT - passport timestamp)
    signal output name;            // 31 bytes | TD3 has 39 = 31 + 8 bytes for name
    signal output nameResidual;    // 8 bytes
    signal output nationality;     // UTF-8 encoded | "USA" -> 0x555341 -> 5591873
    signal output citizenship;     // UTF-8 encoded | "USA" -> 0x555341 -> 5591873
    signal output sex;             // UTF-8 encoded | "F" -> 0x46 -> 70
    signal output documentNumber;  // UTF-8 encoded
    
    // public signals
    signal input eventID;       // challenge | for single eventID -> single nullifier for one identity
    signal input eventData;     // event data binded to the proof; not involved in comp
    signal input idStateRoot;   // identity state Merkle root
    signal input selector;      // blinds personal data | 0 is not used
    signal input currentDate;   // used to differ 19 and 20th centuries in passport encoded dates *(PT)

    // query parameters (set 0 if not used)
    signal input timestampLowerbound;  // identity is issued in this time range  *(UT)
    signal input timestampUpperbound;  // timestamp E [timestampLowerbound, timestampUpperbound)   *(UT)

    signal input identityCounterLowerbound; // Number of identities connected to the specific passport
    signal input identityCounterUpperbound; // identityCounter E [timestampLowerbound, timestampUpperbound)

    signal input birthDateLowerbound;  // birthDateLowerbound < birthDate | 0x303030303030 if not used   *(PT)
    signal input birthDateUpperbound;  // birthDate < birthDateUpperbound | 0x303030303030 if not used   *(PT)

    signal input expirationDateLowerbound; // expirationDateLowerbound < expirationDate | 0x303030303030 if not used   *(PT)
    signal input expirationDateUpperbound; // expirationDate < expirationDateUpperbound | 0x303030303030 if not used   *(PT)

    signal input citizenshipMask;      // binary mask to whitelist | blacklist citizenships

    // private signals
    signal input skIdentity;          // identity secret (private) key
    signal input pkPassportHash;      // passport public key (DG15) hash
    signal input dg1[744];            // 744 bits | DG1 in binary
    signal input idStateSiblings[80]; // identity tree inclusion proof
    signal input timestamp;           // identity creation timestamp   *(UT)
    signal input identityCounter;     // number of times identities were reissuied for the same passport

    // selector decoding
    component selectorBits = Num2Bits(18); // selector is used to selectively disclose personal data
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

    // ----------------------
    // Nullifier calculation
    component skIdentityHasher = Poseidon(1);
    skIdentityHasher.inputs[0] <== skIdentity;
    // nullifier => Poseidon3(sk_i, Poseidon1(sk_i), eventID)
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

    component identityCounterLowerboundCheck = ForceEqualIfEnabled();
    identityCounterLowerboundCheck.in[0] <== greaterEqThanIdentity.out;
    identityCounterLowerboundCheck.in[1] <== 1;
    identityCounterLowerboundCheck.enabled <== selectorBits.out[10];

    // Identity counter upperbound
    component lessThanIdentity = LessThan(64);
    lessThanIdentity.in[0] <== identityCounter;
    lessThanIdentity.in[1] <== identityCounterUpperbound;

    component identityCounterUpperboundCheck = ForceEqualIfEnabled();
    identityCounterUpperboundCheck.in[0] <== lessThanIdentity.out;
    identityCounterUpperboundCheck.in[1] <== 1;
    identityCounterUpperboundCheck.enabled <== selectorBits.out[11];

    // Expiration date lowerbound: expirationDateLowerbound < expirationDate
    component expirationDateLowerboundCompare = EncodedDateIsLess();
    expirationDateLowerboundCompare.first <== expirationDateLowerbound;
    expirationDateLowerboundCompare.second <== dg1DataExtractor.expirationDate;

    component verifyExpirationDateLowerbound = ForceEqualIfEnabled();
    verifyExpirationDateLowerbound.in[0] <== expirationDateLowerboundCompare.out;
    verifyExpirationDateLowerbound.in[1] <== 1;
    verifyExpirationDateLowerbound.enabled <== selectorBits.out[12];

    // Expiration date upperbound: expirationDate < expirationDateUpperbound
    component expirationDateUpperboundCompare = EncodedDateIsLess();
    expirationDateUpperboundCompare.first <== dg1DataExtractor.expirationDate;
    expirationDateUpperboundCompare.second <== expirationDateUpperbound;

    component verifyExpirationDateUpperbound = ForceEqualIfEnabled();
    verifyExpirationDateUpperbound.in[0] <== expirationDateUpperboundCompare.out;
    verifyExpirationDateUpperbound.in[1] <== 1;
    verifyExpirationDateUpperbound.enabled <== selectorBits.out[13];

    // Birth date lowerbound: birthDateLowerbound < birthDate
    component birthDateLowerboundCompare = EncodedDateIsLessNormalized();
    birthDateLowerboundCompare.first <== birthDateLowerbound;
    birthDateLowerboundCompare.second <== dg1DataExtractor.birthDate;
    birthDateLowerboundCompare.currentDate <== currentDate;

    component verifyBirthDateLowerbound = ForceEqualIfEnabled();
    verifyBirthDateLowerbound.in[0] <== birthDateLowerboundCompare.out;
    verifyBirthDateLowerbound.in[1] <== 1;
    verifyBirthDateLowerbound.enabled <== selectorBits.out[14];

    // Birth date upperbound: birthDate < birthDateUpperbound
    component birthDateUpperboundCompare = EncodedDateIsLessNormalized();
    birthDateUpperboundCompare.first <== dg1DataExtractor.birthDate;
    birthDateUpperboundCompare.second <== birthDateUpperbound;
    birthDateUpperboundCompare.currentDate <== currentDate;

    component verifyBirthDateUpperbound = ForceEqualIfEnabled();
    verifyBirthDateUpperbound.in[0] <== birthDateUpperboundCompare.out;
    verifyBirthDateUpperbound.in[1] <== 1;
    verifyBirthDateUpperbound.enabled <== selectorBits.out[15];

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

    //---------------------------------
    //Citizenship Blacklist check

    component citizenshipCheck = CitizenshipCheck();
    citizenshipCheck.citizenship <== dg1DataExtractor.citizenship;
    citizenshipCheck.blacklist <== citizenshipMask;

}
