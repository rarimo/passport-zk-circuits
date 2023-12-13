pragma circom  2.1.6;

include "node_modules/circomlib/circuits/comparators.circom";
include "node_modules/circomlib/circuits/eddsaposeidon.circom";
include "node_modules/circomlib/circuits/poseidon.circom";

template PhotoVerifier(depth) {
    signal input realPhotoHash;     // Poseidon Hash
    signal input passPhotoHash;     // Poseidon Hash
    // [R8.X, R8.Y, A.X, A.Y, S]
    signal input providerSignature[5]; // EdDSA signature of Poseidon(realPhotoHash, passPhotoHash)

    signal input providerMerkleRoot;
    signal input providerMerkleBranch[depth];  // Tree depth = 8 => 2**8 = 256 verifiers MAX
    signal input merkleOrder[depth]; // 0 - left | 1 - right


    component providerResponseHasher = Poseidon(2);
    providerResponseHasher.inputs[0] <== realPhotoHash;
    providerResponseHasher.inputs[1] <== passPhotoHash;

    component signatureVerifier = EdDSAPoseidonVerifier();

    signatureVerifier.R8x <== providerSignature[0];
    signatureVerifier.R8y <== providerSignature[1];
    
    signatureVerifier.Ax  <== providerSignature[2];
    signatureVerifier.Ay  <== providerSignature[3];
    
    signatureVerifier.S   <== providerSignature[4];

    signatureVerifier.M   <== providerResponseHasher.out;

    signatureVerifier.enabled <== 1;
}

component main = PhotoVerifier(1);