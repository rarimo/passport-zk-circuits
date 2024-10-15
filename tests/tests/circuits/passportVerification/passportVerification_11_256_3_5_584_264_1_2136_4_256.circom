pragma circom 2.1.6;

include "../../../../circuits/passportVerification/passportVerificationBuilder.circom";

component main { public [slaveMerkleRoot] } = PassportVerificationBuilder(
		8,	 //dg15 chunk number
		8,	//encapsulated content chunk number
		11,	//sig_algo
		256,	//dg hash algo
		5,	//encapsulated content len in blocks
		584,	///encapsulated content  shift in bits
		264,	//dg1 shift in bits
		1,	//dg15 sig algo (0 if not present)
		2136,	//dg15 shift in bits
		4,	//dg15 blocks
		256	//AA shift in bits
);