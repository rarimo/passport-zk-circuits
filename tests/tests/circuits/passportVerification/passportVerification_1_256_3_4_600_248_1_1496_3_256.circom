pragma circom 2.1.6;

include "../../../../circuits/passportVerification/passportVerificationBuilder.circom";

component main { public [slaveMerkleRoot] } = PassportVerificationBuilder(
		8,	 //dg15 chunk number
		8,	//encapsulated content chunk number
		1,	//sig_algo
		256,	//dg hash algo
		4,	//encapsulated content len in blocks
		600,	///encapsulated content  shift in bits
		248,	//dg1 shift in bits
		1,	//dg15 sig algo (0 if not present)
		1496,	//dg15 shift in bits
		3,	//dg15 blocks
		256	//AA shift in bits
);