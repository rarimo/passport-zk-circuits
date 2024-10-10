pragma circom 2.1.6;

include  "../../../../circuits/identityManagement/circuits/registerIdentityBuilder.circom";

component main { public [slaveMerkleRoot] } = RegisterIdentityBuilder(
		13,	//sig_algo
		384,	//dg hash algo
		1,	//document type
		5,	//encapsulated content len in blocks
		336,	///encapsulated content  shift in bits
		248,	//dg1 shift in bits
		1,	//dg15 sig algo (0 if not present)
		3768,	//dg15 shift in bits
		2,	//dg15 blocks
		256	//AA shift in bits
);