pragma circom  2.1.6;


include "../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../node_modules/circomlib/circuits/bitify.circom";
include "./dateComparison.circom";

template SignatureVerification(N) {
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

    for (var i = 0; i < 4; i++) {
        bits2NumExpYearDigit1.in[3-i]  <== in[564+i];
        bits2NumExpYearDigit2.in[3-i]  <== in[572+i];
        bits2NumExpMonthDigit1.in[3-i] <== in[580+i];
        bits2NumExpMonthDigit2.in[3-i] <== in[588+i];
        bits2NumExpDayDigit1.in[3-i]   <== in[596+i];
        bits2NumExpDayDigit2.in[3-i]   <== in[604+i];
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
    var SHIFT = 24;
    for (var i = 0; i < 4; i++) {
        bits2NumBirthYearDigit1.in[3-i]  <== in[SHIFT+612+i];
        bits2NumBirthYearDigit2.in[3-i]  <== in[SHIFT+620+i];
        bits2NumBirthMonthDigit1.in[3-i] <== in[SHIFT+628+i];
        bits2NumBirthMonthDigit2.in[3-i] <== in[SHIFT+636+i];
        bits2NumBirthDayDigit1.in[3-i]   <== in[SHIFT+644+i];
        bits2NumBirthDayDigit2.in[3-i]   <== in[SHIFT+652+i];
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

    out[2] <== passportIssuer.out;

    // -------

    component hasher = Sha256(N);

    hasher.in <== in;

    component bits2NumFirst = Bits2Num(128);
    component bits2NumSecond = Bits2Num(128);

    for (var i = 0; i < 128; i++) {
        bits2NumFirst.in[127-i] <== hasher.out[i];
    }

    for (var i = 0; i < 128; i++) {
        bits2NumSecond.in[127-i] <== hasher.out[128 + i];
    }

    out[0] <== bits2NumFirst.out;
    out[1] <== bits2NumSecond.out;
}

component main {public [currDateDay, currDateMonth, currDateYear]} = SignatureVerification(744);