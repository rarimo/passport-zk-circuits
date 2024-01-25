pragma circom  2.1.6;

include "../node_modules/circomlib/circuits/bitify.circom";
include "./dateComparison.circom";
include "./utils/sha1.circom";

template PassportVerificationSHA1(N) {
    signal input currDateYear;
    signal input currDateMonth;
    signal input currDateDay;
    signal input in[N];
    signal output out[3];

    // DATE OF EXPIRACY DECODING
    component bits2NumExpYearDigit1  = Bits2Num(4);
    component bits2NumExpYearDigit2  = Bits2Num(4);
    component bits2NumExpMonthDigit1 = Bits2Num(4);
    component bits2NumExpMonthDigit2 = Bits2Num(4);
    component bits2NumExpDayDigit1   = Bits2Num(4);
    component bits2NumExpDayDigit2   = Bits2Num(4);

    var POSITION = 564;
    var SHIFT = 8;
    for (var i = 0; i < 4; i++) {
        bits2NumExpYearDigit1.in[3-i]  <== in[POSITION + 0*SHIFT + i];
        bits2NumExpYearDigit2.in[3-i]  <== in[POSITION + 1*SHIFT + i];
        bits2NumExpMonthDigit1.in[3-i] <== in[POSITION + 2*SHIFT + i];
        bits2NumExpMonthDigit2.in[3-i] <== in[POSITION + 3*SHIFT + i];
        bits2NumExpDayDigit1.in[3-i]   <== in[POSITION + 4*SHIFT + i];
        bits2NumExpDayDigit2.in[3-i]   <== in[POSITION + 5*SHIFT + i];
    }

    signal TEN <== 10;
    signal expYear  <== bits2NumExpYearDigit1.out  * TEN + bits2NumExpYearDigit2.out;
    signal expMonth <== bits2NumExpMonthDigit1.out * TEN + bits2NumExpMonthDigit2.out;
    signal expDay   <== bits2NumExpDayDigit1.out   * TEN + bits2NumExpDayDigit2.out;

    //DATE OF BIRTH DECODING

    component bits2NumBirthYearDigit1  = Bits2Num(4);
    component bits2NumBirthYearDigit2  = Bits2Num(4);
    component bits2NumBirthMonthDigit1 = Bits2Num(4);
    component bits2NumBirthMonthDigit2 = Bits2Num(4);
    component bits2NumBirthDayDigit1   = Bits2Num(4);
    component bits2NumBirthDayDigit2   = Bits2Num(4);
    
    POSITION = 496+4;
    for (var i = 0; i < 4; i++) {
        bits2NumBirthYearDigit1.in[3-i]  <== in[POSITION + 0*SHIFT + i];
        bits2NumBirthYearDigit2.in[3-i]  <== in[POSITION + 1*SHIFT + i];
        bits2NumBirthMonthDigit1.in[3-i] <== in[POSITION + 2*SHIFT + i];
        bits2NumBirthMonthDigit2.in[3-i] <== in[POSITION + 3*SHIFT + i];
        bits2NumBirthDayDigit1.in[3-i]   <== in[POSITION + 4*SHIFT + i];
        bits2NumBirthDayDigit2.in[3-i]   <== in[POSITION + 5*SHIFT + i];
    }

    signal birthYear  <== bits2NumBirthYearDigit1.out  * TEN + bits2NumBirthYearDigit2.out;
    signal birthMonth <== bits2NumBirthMonthDigit1.out * TEN + bits2NumBirthMonthDigit2.out;
    signal birthDay   <== bits2NumBirthDayDigit1.out   * TEN + bits2NumBirthDayDigit2.out;

    // ----------
    // CURRENT DATE < EXPIRACY DATE

    component isCurrLessExpiracy = DateIsLess();
    isCurrLessExpiracy.firstYear  <== currDateYear;
    isCurrLessExpiracy.firstMonth <== currDateMonth;
    isCurrLessExpiracy.firstDay   <== currDateDay;

    isCurrLessExpiracy.secondYear  <== expYear;
    isCurrLessExpiracy.secondMonth <== expMonth;
    isCurrLessExpiracy.secondDay   <== expDay;
    
    isCurrLessExpiracy.out === 1;

    // ---------
    // BIRTH_DATE + 18 < CURRENT DATE

    component isAdult = DateIsLess();

    signal ADULT_YEARS <== 18; 

    isAdult.firstYear  <== birthYear + ADULT_YEARS;
    isAdult.firstMonth <== birthMonth;
    isAdult.firstDay   <== birthDay;

    isAdult.secondYear  <== currDateYear;
    isAdult.secondMonth <== currDateMonth;
    isAdult.secondDay   <== currDateDay;

    isAdult.out === 1;

    // --------
    // OUT PASSPORT ISSUER CODE [56..80], 3*8 = 24 bits

    component passportIssuer = Bits2Num(24);

    for (var i = 0; i < 24; i++) {
        passportIssuer.in[i] <== in[56+i];
    }

    out[1] <== passportIssuer.out;

    // -------

    component hasher = Sha1(N);

    hasher.in <== in;

    component bits2NumHash = Bits2Num(160);

    for (var i = 0; i < 160; i++) {
        bits2NumHash.in[160-1-i] <== hasher.out[i];
    }

    out[0] <== bits2NumHash.out;
}

component main {public [currDateDay, currDateMonth, currDateYear]} = PassportVerificationSHA1(744);