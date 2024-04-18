pragma circom  2.1.6;

include "./dateComparison.circom";
include "./dateDecoder.circom";

template EncodedDateIsLess() {
    signal output out;

    signal input first;
    signal input second;

    component firstDateDecoder = DateDecoder();
    firstDateDecoder.dateEncoded <== first;

    component secondDateDecoder = DateDecoder();
    secondDateDecoder.dateEncoded <== second;

    component dateIsLess = DateIsLess();

    dateIsLess.firstDay    <== firstDateDecoder.day;
    dateIsLess.secondDay   <== secondDateDecoder.day;
    dateIsLess.firstMonth  <== firstDateDecoder.month;
    dateIsLess.secondMonth <== secondDateDecoder.month;
    dateIsLess.firstYear   <== firstDateDecoder.year;
    dateIsLess.secondYear  <== secondDateDecoder.year;

    out <== dateIsLess.out;
}