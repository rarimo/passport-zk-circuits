pragma circom  2.1.6;

// (day, month, year) -> UTF-8 encoded date "YYMMDD"
template DateEncode() {
    signal output encoded;
    signal input  day;
    signal input  month;
    signal input  year;

    signal dayDecimals <-- (day \ 10);
    signal dayRest     <-- (day % 10);

    dayDecimals * 10 + dayRest === day;

    signal monthDecimals <-- (month \ 10);
    signal monthRest     <-- (month % 10);

    monthDecimals * 10 + monthRest === month;

    signal yearDecimals <-- (year \ 10);
    signal yearRest     <-- (year % 10); 

    yearDecimals * 10 + yearRest === year;

     // UTF-8 encoded 0011(decimal)0011(rest)
    signal dayEncoded   <== (dayDecimals * 2**8 + dayRest) + (2**4 + 2**5 + 2**12 + 2**13);
    signal monthEncoded <== (monthDecimals * 2**8 + monthRest) + (2**4 + 2**5 + 2**12 + 2**13);
    signal yearEncoded <== (yearDecimals * 2**8 + yearRest) + (2**4 + 2**5 + 2**12 + 2**13);
    encoded <== yearEncoded * 2**32 + monthEncoded * 2**16 + dayEncoded;
    log(encoded);
}

component main = DateEncode();

// 00110001 00110110 00110000 00110111 00110010 00110010