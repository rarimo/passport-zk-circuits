pragma circom 2.1.6;

// Get base8 point (generator * 8),
// We use base8 point for pubkey computation from private key
template GetBabyjubjubBase8(){
    
    signal output base8[2];
    
    base8[0] <== 5299619240641551281634865583518297030282874472190772894086521144482721001553;
    base8[1] <== 16950150798460657717958625567821834550301663161624707787222815936182638968203;

}