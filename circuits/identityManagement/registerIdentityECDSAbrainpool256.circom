pragma circom 2.1.6;

include "./circuits/registerIdentityBuilder.circom";

component main { public [slaveMerkleRoot] } = RegisterIdentityBuilder(
		8,	 //dg15 chunk number
		8,	//encapsulated content chunk number
		512,	//hash chunk size
		256,	//hash type
		7,	//sig_algo
		0,	//salt
		0,	// e_bits
		64,	//chunk size
		4,	//chunk_num
		512,	//dg hash size chunk size
		256,	//dg hash algo
		3, //document type
		80,	//merkle tree depth
		[[248, 3056, 576, 6, 7, 1]],	//flow matrix
		1,	//flow matrix height
		[
			[0, 0, 0, 0, 0, 1, 0, 0],
			[0, 0, 0, 0, 0, 0, 1, 0]
		]	//hash block matrix
);