pragma circom 2.1.6;

include  "./circuits/registerIdentityBuilder.circom";

component main = RegisterIdentityBuilder(
		10,	//sig_algo
		256,	//dg hash algo
		3,	//document type
        3,
        576,
        248,
        1,
        1184,
        5,
        268
);