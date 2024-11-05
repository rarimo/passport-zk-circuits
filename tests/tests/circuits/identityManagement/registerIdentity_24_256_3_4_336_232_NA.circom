pragma circom 2.1.6;

include  "../../../../circuits/identityManagement/circuits/registerIdentityBuilder.circom";

component main { public [slaveMerkleRoot] } = RegisterIdentityBuilder(
		24,	//sig_algo
		256,	//dg hash algo
		3,	//document type
		4,	//encapsulated content len in blocks
		336,	//encapsulated content  shift in bits
		232,	//dg1 shift in bits
		0,	//dg15 sig algo (0 if not present)
		0,	//dg15 shift in bits
		0,	//dg15 blocks
		0	//AA shift in bits
);