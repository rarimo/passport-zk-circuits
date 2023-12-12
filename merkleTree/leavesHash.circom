pragma circom  2.1.6;

include "../node_modules/circomlib/circuits/poseidon.circom";
// include "../node_modules/circomlib/circuits/bitify.circom";

template HashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    component hasher = Poseidon(2);
    hasher.inputs[0] <== left;
    hasher.inputs[1] <== right;
    hash <== hasher.out;
}

component main = HashLeftRight();