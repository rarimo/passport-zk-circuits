pragma circom 2.1.6;

include  "../../../../circuits/identityManagement/circuits/registerIdentityBuilder.circom";

component main = RegisterIdentityBuilder(
		2,
		8,
		8,
		8,
		512,
		256,	//hash type
		2,
		0,
		17,
		64,
		64,
		256,
		1,
		80,
		[[248, 2432, 576, 3, 6, 1]],
		1,
		[
			[0, 0, 1, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 1, 0, 0],
			[0, 1, 0, 0, 0, 0, 0, 0]
		]
);