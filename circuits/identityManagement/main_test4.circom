pragma circom 2.1.6;

include  "./circuits/registerIdentityBuilder.circom";

component main = RegisterIdentityBuilder(
		20,	//sig_algo
		256,	//dg hash algo
		3,	//document type
        3,
        336,
        224,
        0,
        256,
        1,
        0
);