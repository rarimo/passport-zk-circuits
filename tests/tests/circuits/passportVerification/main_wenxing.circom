pragma circom 2.1.6;

include "../../../../circuits/passportVerification/passportVerificationBuilder.circom";

component main = PassportVerificationBuilder(
		2,
		8,
		8,
		8,
		512,
		256,	//hash type
		1,
		0,
		17,
		64,
		32,
		256,
		80,
		[[248, 1496, 600, 3, 4, 1]],
		1,
		[
			[0, 0, 1, 0, 0, 0, 0, 0],
			[0, 0, 0, 1, 0, 0, 0, 0],
			[0, 1, 0, 0, 0, 0, 0, 0]
		]
);