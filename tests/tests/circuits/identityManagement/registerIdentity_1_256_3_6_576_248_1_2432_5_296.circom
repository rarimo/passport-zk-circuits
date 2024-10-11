pragma circom 2.1.6;

include  "../../../../circuits/identityManagement/circuits/registerIdentityBuilder.circom";

component main { public [slaveMerkleRoot] } = RegisterIdentityBuilder(
		1,	//sig_algo
		256,	//dg hash algo
		3,	//document type
		6,	//encapsulated content len in blocks
		576,	///encapsulated content  shift in bits
		248,	//dg1 shift in bits
		1,	//dg15 sig algo (0 if not present)
		2432,	//dg15 shift in bits
		5,	//dg15 blocks
		296	//AA shift in bits
);