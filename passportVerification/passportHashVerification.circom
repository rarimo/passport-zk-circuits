pragma circom 2.1.6;

include "../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../node_modules/circomlib/circuits/bitify.circom";

template PassportHashVerifier() {
    signal input encapsulatedContent[2688];
    signal input signedAttributes[592];
    
    // Hash encupsulated content
    component encapsulatedContentHasher = Sha256(2688);
    encapsulatedContentHasher.in <== encapsulatedContent;

    // signedAttributes passport hash == encapsulatedContent hash

    for (var i = 0; i < 256; i++) {
        encapsulatedContentHasher.out[i] === signedAttributes[592-256+i];
    }

}

component main = PassportHashVerifier();
