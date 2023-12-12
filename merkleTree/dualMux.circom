pragma circom 2.1.6

template DualMux() {
    signal input in[2];
    signal input order;
    signal output out[2];

    order * (1 - order) === 0 // order is 0 or 1

    // if order == 0 returns [in[0], in[1]]
    // if order == 1 returns [in[1], in[0]]
    
    out[0] <== (in[1] - in[0]) * order + in[0];
    out[1] <== (in[0] - in[1]) * order + in[1];
}
