pragma circom  2.1.6;

include "../node_modules/circomlib/circuits/bitify.circom";

template QueryIdentity() {
    // signal output nullifier;    // Poseidon3(sk_i, Poseidon1(sk_i), eventID)

    // signal output birthDate;
    // signal output expirationDate;
    signal output name;
    // signal output nationality;
    signal output citizenship;
    signal output sex;
    // signal output documentNumber;
    
    // public signals
    signal input eventID;       // challenge
    signal input idMerkleRoot;  // identity state Merkle root
    signal input selector;      //  blinds personal data

    // private signals
    signal input skIdentity;
    signal input pkPassport;
    signal input dg1[744];     // 744 bits

    // selector decoding
    component num2BitsSelector = Num2Bits(7);
    num2BitsSelector.in <== selector;

    // Passport data decoding

    // BIRTH DATE

    // EXPIRATION DATE

    // NAME [80..320), 30*8 = 240 bits
    var NAME_FIELD_SIZE = 240;
    var NAME_FIELD_SHIFT = 80;
    component nameEncoder = Bits2Num(NAME_FIELD_SIZE);

    for (var i = 0; i < NAME_FIELD_SIZE; i++) {
        nameEncoder.in[i] <== dg1[NAME_FIELD_SHIFT + NAME_FIELD_SIZE];
    }
    name <== nameEncoder.out;

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
    component bits2NumSex = Bits2Num(SEX_FIELD_SIZE);

    var SEX_POSITION = 69;
    for (var i = 0; i < SEX_FIELD_SIZE; i++) {
        bits2NumSex.in[i] <== dg1[SEX_POSITION*8 + i];
    }

    // DOCUMENT NUMBER


   

}


component main = QueryIdentity();