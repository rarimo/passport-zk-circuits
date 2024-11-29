pragma circom 2.1.6;

include "../../../../circuits/passportVerification/passportVerificationBuilder.circom";

component main { public [slaveMerkleRoot] } = PassportVerificationBuilder(
		8,	 //dg15 chunk number
		8,	//encapsulated content chunk number
		10,	//sig_algo
		256,	//dg hash algo
		3,	//encapsulated content len in blocks
		576,	///encapsulated content  shift in bits
		248,	//dg1 shift in bits
		1,	//dg15 sig algo (0 if not present)
		1184,	//dg15 shift in bits
		5,	//dg15 blocks
		264	//AA shift in bits
);