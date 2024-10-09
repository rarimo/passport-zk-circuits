pragma circom 2.1.6;

include "../../../../circuits/passportVerification/passportVerificationBuilder.circom";

component main = PassportVerificationBuilder(
		8,	 //dg15 chunk number
		8,	//encapsulated content chunk number
		21,	//sig_algo
		256,	//dg hash algo
		7,	//encapsulated content len in blocks
		576,	///encapsulated content  shift in bits
		248,	//dg1 shift in bits
		21,	//dg15 sig algo (0 if not present)
		3056,	//dg15 shift in bits
		6,	//dg15 blocks
		2008	//AA shift in bits
);