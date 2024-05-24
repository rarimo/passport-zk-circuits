pragma circom  2.1.6;

include "./dateDecoder.circom";
include "./dateComparison.circom";
include "./dateComparisonEncoded.circom";

// Because passport stores only the last two digits of the year, normalization is required 
// in order to correctly compare dates. 
// How to distinguish whether "010140" is 01-01-1940 or 01-01-2040?
// We use currentDate as a separator between centuries:
//  If date if greater than currentDate -> previous century
//  Otherwise -> current century. Add 100 to year

template EncodedDateIsLessNormalized() {
    signal output out;

    signal input first;
    signal input second;
    signal input currentDate;

    component firstDateDecoder = DateDecoder();
    firstDateDecoder.dateEncoded <== first;

    component secondDateDecoder = DateDecoder();
    secondDateDecoder.dateEncoded <== second;

    // if first date < currentDate => it is 20th century => add 100 to year
    component firstDateNormalization = EncodedDateIsLess();
    firstDateNormalization.first <== first;
    firstDateNormalization.second <== currentDate;

    // if second date < currentDate => it is 20th century => add 100 to year
    component secondDateNormalization = EncodedDateIsLess();
    secondDateNormalization.first <== second;
    secondDateNormalization.second <== currentDate;

    component dateIsLess = DateIsLess();

    signal CENTURY <== 100;

    dateIsLess.firstDay    <== firstDateDecoder.day;
    dateIsLess.secondDay   <== secondDateDecoder.day;
    dateIsLess.firstMonth  <== firstDateDecoder.month;
    dateIsLess.secondMonth <== secondDateDecoder.month;
    dateIsLess.firstYear   <== firstDateDecoder.year + CENTURY * firstDateNormalization.out;
    dateIsLess.secondYear  <== secondDateDecoder.year + CENTURY * secondDateNormalization.out;

    out <== dateIsLess.out;
}