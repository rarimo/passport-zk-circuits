pragma circom  2.1.6;

include "../../node_modules/circomlib/circuits/bitify.circom";

template DG1TD1DataExtractor() {
    signal output birthDate;
    signal output expirationDate;

    // name has 30 (TD1) bytes.
    signal output name;

    signal output nationality;
    signal output citizenship;
    signal output sex;
    signal output documentNumber;
    signal output personalNumber;
    signal output documentType;

    signal input dg1[760];

    // BIRTH DATE
    var BIRTH_DATE_SIZE  = 48;
    var BIRTH_DATE_SHIFT = 280;
    component birthDateEncoder = Bits2Num(BIRTH_DATE_SIZE);
    for (var i = 0; i < BIRTH_DATE_SIZE; i++) {
        birthDateEncoder.in[BIRTH_DATE_SIZE - 1 - i] <== dg1[BIRTH_DATE_SHIFT + i];
    }
    birthDate <== birthDateEncoder.out;

    // EXPIRATION DATE
    var EXPIRATION_DATE_SIZE  = 48;
    var EXPIRATION_DATE_SHIFT = 344;
    component expirationDateEncoder = Bits2Num(EXPIRATION_DATE_SIZE);
    for (var i = 0; i < EXPIRATION_DATE_SIZE; i++) {
        expirationDateEncoder.in[EXPIRATION_DATE_SIZE - 1 - i] <== dg1[EXPIRATION_DATE_SHIFT + i];
    }
    expirationDate <== expirationDateEncoder.out;

    // NAME [80..320), 31*8 = 248 bits
    var NAME_FIELD_SIZE     = 240;
    var NAME_FIELD_SHIFT    = 520;
    component nameEncoder = Bits2Num(NAME_FIELD_SIZE);

    for (var i = 0; i < NAME_FIELD_SIZE; i++) {
        nameEncoder.in[NAME_FIELD_SIZE - 1 - i] <== dg1[NAME_FIELD_SHIFT + i];
    }
    name <== nameEncoder.out;

    // NATIONALITY 
    var NATIONALITY_FIELD_SIZE  = 24;
    var NATIONALITY_FIELD_SHIFT = 400;
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
    var SEX_POSITION   = 336;
    component sexEncoder = Bits2Num(SEX_FIELD_SIZE);

    for (var i = 0; i < SEX_FIELD_SIZE; i++) {
        sexEncoder.in[SEX_FIELD_SIZE - 1 - i] <== dg1[SEX_POSITION + i];
    }
    sex <== sexEncoder.out;

    // DOCUMENT NUMBER
    var DOCUMENT_NUMBER_SHIFT = 80;
    var DOCUMENT_NUMBER_SIZE  = 72;
    component documentNumberEncoder = Bits2Num(DOCUMENT_NUMBER_SIZE);

    for (var i = 0; i < DOCUMENT_NUMBER_SIZE; i++) {
        documentNumberEncoder.in[DOCUMENT_NUMBER_SIZE - 1 - i] <== dg1[DOCUMENT_NUMBER_SHIFT + i];
    }
    documentNumber <== documentNumberEncoder.out;

    // PERSONAL NUMBER
    var PERSONAL_NUMBER_SHIFT = 160;
    var PERSONAL_NUMBER_SIZE  = 88;
    component personalNumberEncoder = Bits2Num(PERSONAL_NUMBER_SIZE);

    for (var i = 0; i < PERSONAL_NUMBER_SIZE; i++) {
        personalNumberEncoder.in[PERSONAL_NUMBER_SIZE - 1 - i] <== dg1[PERSONAL_NUMBER_SHIFT + i];
    }
    personalNumber <== personalNumberEncoder.out;

    // DOCUMENT TYPE
    var DOCUMENT_TYPE_SHIFT = 40;
    var DOCUMENT_TYPE_SIZE  = 16;
    component documentTypeEncoder = Bits2Num(DOCUMENT_TYPE_SIZE);

    for (var i = 0; i < DOCUMENT_TYPE_SIZE; i++) {
        documentTypeEncoder.in[DOCUMENT_TYPE_SIZE - 1 - i] <== dg1[DOCUMENT_TYPE_SHIFT + i];
    }
    documentType <== documentTypeEncoder.out;
}