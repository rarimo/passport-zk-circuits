pragma circom 2.1.6;

include "../../../../circuits/passportVerification/passportVerificationBuilder.circom";

component main { public [slaveMerkleRoot] } = PassportVerificationBuilder(
		8,	 //dg15 chunk number
		8,	//encapsulated content chunk number
		4,	//sig_algo
		160,	//dg hash algo
		3,	//encapsulated content len in blocks
		336,	///encapsulated content  shift in bits
		216,	//dg1 shift in bits
		1,	//dg15 sig algo (0 if not present)
		1296,	//dg15 shift in bits
		3,	//dg15 blocks
		256	//AA shift in bits
);