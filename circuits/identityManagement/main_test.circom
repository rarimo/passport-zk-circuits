pragma circom 2.1.6;

include  "./circuits/registerIdentityBuilder.circom";

component main = RegisterIdentityBuilder(
		11,	//sig_algo
		256,	//dg hash algo
		1,	//document type
        5,
        576,
        248,
        1,
        1808,
        4,
        256
);