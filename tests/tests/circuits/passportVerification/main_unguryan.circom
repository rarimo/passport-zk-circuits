pragma circom 2.1.6;

include "../../../../circuits/passportVerification/passportVerificationBuilder.circom";

component main = PassportVerificationBuilder(
		2,
		8,
		8,
		8,
		512,
		256,	//hash type
		7,
		0,
		0,
		64,
		4,
		256,
		80,
		[[248, 3056, 576, 6, 7, 1]],
		1,
		[
			[0, 0, 0, 0, 0, 1, 0, 0],
			[0, 0, 0, 0, 0, 0, 1, 0],
			[0, 1, 0, 0, 0, 0, 0, 0]
		]
);