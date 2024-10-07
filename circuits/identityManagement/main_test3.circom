pragma circom 2.1.6;

include  "./circuits/registerIdentityBuilder.circom";

component main = RegisterIdentityBuilder(
		21,	//sig_algo
		256,	//dg hash algo
		3,	//document type
        7,
        576,
        248,
        1,
        3056,
        6,
        2008
);