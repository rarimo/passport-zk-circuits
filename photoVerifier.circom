pragma circom  2.1.6;

include "node_modules/circomlib/circuits/comparators.circom";
include "node_modules/circomlib/circuits/eddsaposeidon.circom";

template PhotoVerifier {
    signal private input realPhotoHash;     // Poseidon Hash
    signal private input passPhotoHash;     // Poseidon Hash
    signal private input verifierSignature; // EdDSA signature of Poseidon(realPhotoHash, passPhotoHash)

    signal public input verifierMerkleRoot;
    signal private input verifierMerkleBranch[7];  // Tree depth = 8 => 2**8 = 256 verifiers MAX

    
}