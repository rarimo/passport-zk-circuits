pragma circom  2.1.6;

include "../../node_modules/circomlib/circuits/bitify.circom";

template DG1DataExtractor() {
    signal output birthDate;
    signal output expirationDate;

    // name has 30 (TD1), 31(TD3) or 39 (TD3) bytes. 
    // Max we can fit into one signal is 31 * 8 = 248 bits
    // Name is splitted into name (31 bytes) + nameResidual(8 bytes)
    signal output name;
    signal output nameResidual;

    signal output nationality;
    signal output citizenship;
    signal output sex;
    signal output documentNumber;

    signal input dg1[744];

    // BIRTH DATE
    var BIRTH_DATE_SIZE  = 48;
    var BIRTH_DATE_SHIFT = 496;
    component birthDateEncoder = Bits2Num(BIRTH_DATE_SIZE);
    for (var i = 0; i < BIRTH_DATE_SIZE; i++) {
        birthDateEncoder.in[BIRTH_DATE_SIZE - 1 - i] <== dg1[BIRTH_DATE_SHIFT + i];
    }
    birthDate <== birthDateEncoder.out;

    // EXPIRATION DATE
    var EXPIRATION_DATE_SIZE  = 48;
    var EXPIRATION_DATE_SHIFT = 560;
    component expirationDateEncoder = Bits2Num(EXPIRATION_DATE_SIZE);
    for (var i = 0; i < EXPIRATION_DATE_SIZE; i++) {
        expirationDateEncoder.in[EXPIRATION_DATE_SIZE - 1 - i] <== dg1[EXPIRATION_DATE_SHIFT + i];
    }

    expirationDate <== expirationDateEncoder.out;

    // NAME [80..320), 31*8 = 248 bits
    var NAME_FIELD_SIZE     = 248;
    var NAME_FIELD_SHIFT    = 80;
    var NAME_FIELD_RESIDUAL = 64;
    component nameEncoder = Bits2Num(NAME_FIELD_SIZE);
    component nameResidualEncoder = Bits2Num(NAME_FIELD_RESIDUAL);

    for (var i = 0; i < NAME_FIELD_SIZE; i++) {
        nameEncoder.in[NAME_FIELD_SIZE - 1 - i] <== dg1[NAME_FIELD_SHIFT + i];
    }

    for (var i = 0; i < NAME_FIELD_RESIDUAL; i++) {
        nameResidualEncoder.in[NAME_FIELD_RESIDUAL - 1 - i] <== dg1[NAME_FIELD_SHIFT + NAME_FIELD_SIZE + i];
    }
    name <== nameEncoder.out;
    nameResidual <== nameResidualEncoder.out;

    // NATIONALITY 
    var NATIONALITY_FIELD_SIZE  = 24;
    var NATIONALITY_FIELD_SHIFT = 472;
    component nationalityEncoder = Bits2Num(NATIONALITY_FIELD_SIZE);

    for (var i = 0; i < NATIONALITY_FIELD_SIZE; i++) {
        nationalityEncoder.in[NATIONALITY_FIELD_SIZE - 1 - i] <== dg1[NATIONALITY_FIELD_SHIFT + i];
    }
    nationality <== nationalityEncoder.out;

    // CITIZENSHIP CODE [56..80), 3*8 = 24 bits (== issuing authority)
    var CITIZENSHIP_FIELD_SIZE  = 24;
    var CITIZENSHIP_FIELD_SHIFT = 56;
    component citizenshipEncoder = Bits2Num(CITIZENSHIP_FIELD_SIZE);

    for (var i = 0; i < CITIZENSHIP_FIELD_SIZE; i++) {
        citizenshipEncoder.in[CITIZENSHIP_FIELD_SIZE - 1 - i] <== dg1[CITIZENSHIP_FIELD_SHIFT + i];
    }
    citizenship <== citizenshipEncoder.out;

    // SEX
    var SEX_FIELD_SIZE = 8;
    var SEX_POSITION   = 69;
    component sexEncoder = Bits2Num(SEX_FIELD_SIZE);

    for (var i = 0; i < SEX_FIELD_SIZE; i++) {
        sexEncoder.in[SEX_FIELD_SIZE - 1 - i] <== dg1[SEX_POSITION * 8 + i];
    }
    sex <== sexEncoder.out;

    // DOCUMENT NUMBER
    var DOCUMENT_NUMBER_SHIFT = 392;
    var DOCUMENT_NUMBER_SIZE  = 72;
    component documentNumberEncoder = Bits2Num(DOCUMENT_NUMBER_SIZE);

    for (var i = 0; i < DOCUMENT_NUMBER_SIZE; i++) {
        documentNumberEncoder.in[DOCUMENT_NUMBER_SIZE - 1 - i] <== dg1[DOCUMENT_NUMBER_SHIFT + i];
    }

    documentNumber <== documentNumberEncoder.out;
}