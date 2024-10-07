pragma circom 2.1.6;

include  "./circuits/registerIdentityBuilder.circom";

component main = RegisterIdentityBuilder(
		1,	//sig_algo
		256,	//dg hash algo
		1,	//document type
        5,
        576,
        248,
        0,
        256,
        1,
        0
);