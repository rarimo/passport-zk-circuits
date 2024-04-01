pragma circom  2.1.6;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/poseidon.circom";

template QueryIdentity() {
    signal output nullifier;    // Poseidon3(sk_i, Poseidon1(sk_i), eventID)

    // signal output birthDate;
    // signal output expirationDate;

    // name has 30 (TD1), 31(TD3) or 39 (TD3) bytes. 
    // Max we can fit into one signal is 31 * 8 = 248 bits
    // Name is splitted into name (31 bytes) + nameResidual(8 bytes)
    signal output name;
    signal output nameResidual;

    signal output nationality;
    signal output citizenship;
    signal output sex;
    signal output documentNumber;
    
    // public signals
    signal input eventID;       // challenge
    signal input idMerkleRoot;  // identity state Merkle root
    signal input selector;      //  blinds personal data

    // private signals
    signal input skIdentity;
    signal input pkPassport;
    signal input dg1[744];     // 744 bits

    // selector decoding
    component selectorBits = Num2Bits(8);
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

    // Nullifier calculation
    component skIdentityHasher = Poseidon(1);
    skIdentityHasher.inputs[0] <== skIdentity;

    component nulliferHasher = Poseidon(3);
    nulliferHasher.inputs[0] <== skIdentity;
    nulliferHasher.inputs[1] <== skIdentityHasher.out;
    nulliferHasher.inputs[2] <== eventID;

    nullifier <== nulliferHasher.out * selectorBits.out[0];

    // Passport data decoding

    // BIRTH DATE

    // EXPIRATION DATE

    // NAME [80..320), 31*8 = 248 bits
    var NAME_FIELD_SIZE = 248;
    var NAME_FIELD_SHIFT = 80;
    var NAME_FIELD_RESIDUAL = 64;
    component nameEncoder = Bits2Num(NAME_FIELD_SIZE);
    component nameResidualEncoder = Bits2Num(NAME_FIELD_RESIDUAL);

    for (var i = 0; i < NAME_FIELD_SIZE; i++) {
        nameEncoder.in[i] <== dg1[NAME_FIELD_SHIFT + i];
    }

    for (var i = 0; i < NAME_FIELD_RESIDUAL; i++) {
        nameResidualEncoder.in[i] <== dg1[NAME_FIELD_SHIFT + NAME_FIELD_SIZE + i]
    }
    name <== nameEncoder.out;
    nameResidual <== nameResidualEncoder.out;

    // NATIONALITY 

    // CITIZENSHIP CODE [56..80), 3*8 = 24 bits (== issuing authority)
    var CITIZENSHIP_FIELD_SIZE = 24;
    var CITIZENSHIP_FIELD_SHIFT = 56;
    component citizenshipEncoder = Bits2Num(CITIZENSHIP_FIELD_SIZE);

    for (var i = 0; i < CITIZENSHIP_FIELD_SIZE; i++) {
        citizenshipEncoder.in[i] <== dg1[CITIZENSHIP_FIELD_SHIFT + i];
    }
    citizenship <== citizenshipEncoder.out;

    // SEX
    var SEX_FIELD_SIZE = 8;
    var SEX_POSITION = 69;
    component bits2NumSex = Bits2Num(SEX_FIELD_SIZE);

    for (var i = 0; i < SEX_FIELD_SIZE; i++) {
        bits2NumSex.in[i] <== dg1[SEX_POSITION * 8 + i];
    }

    // DOCUMENT NUMBER
    var DOCUMENT_NUMBER_SHIFT = 392;
    var DOCUMENT_NUMBER_SIZE  = 72;
    component bits2NumDocumentNumber = Bits2Num(DOCUMENT_NUMBER_SIZE);

    for (var i = 0; i < DOCUMENT_NUMBER_SIZE; i++) {
        bits2NumDocumentNumber.in[i] <== dg1[DOCUMENT_NUMBER_SHIFT + i];
    }

    documentNumber <== bits2NumDocumentNumber.out;




}


component main = QueryIdentity();