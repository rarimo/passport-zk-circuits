pragma circom 2.1.6;

include  "./circuits/registerIdentityBuilder.circom";

component main = RegisterIdentityBuilder(
		8,	 //dg15 chunk number
		8,	//encapsulated content chunk number
		512,	//hash chunk size
		256,	//hash type
		1,	//sig_algo
		0,	//salt
		17,	// e_bits
		64,	//chunk size
		32,	//chunk_num
		512,	//dg hash size chunk size
		256,	//dg hash algo
		1,	//document type
		80,	//merkle tree depth
		[[248, 256, 576, 1, 5, 0]],	//flow matrix
		1,	//flow matrix height
		[
			[1, 0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 1, 0, 0, 0]
		],	//hash block matrix,
        0,
        0
);