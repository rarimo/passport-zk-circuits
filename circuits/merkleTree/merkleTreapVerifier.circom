// LICENSE: GPL-3.0
pragma circom 2.1.6;

include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/comparators.circom";
include "circomlib/circuits/switcher.circom";
include "circomlib/circuits/poseidon.circom";

template SMTHash2() {
    signal input L;
    signal input R;
    signal output out;

    component h = Poseidon(2);
    h.inputs[0] <== L;
    h.inputs[1] <== R;

    out <== h.out;
}

// siblings: 0x123 0x456 0 0 0 0 0 0 0 0 0 0 0
// isZero:   1     1     0 0 0 0 0 0 0 0 0 0 0
// levIns:   0     0     1 0 0 0 0 0 0 0 0 0 0
// done:     1     1     0 0 0 0 0 0 0 0 0 0 0
template SMTLevIns(nLevels) {
    signal input siblings[nLevels];
    signal output levIns[nLevels];

    signal done[nLevels - 1];

    var i;

    component isZero[nLevels];

    for (i = 0; i < nLevels; i++) {
        isZero[i] = IsZero();
        isZero[i].in <== siblings[i];
    }

    (isZero[nLevels-1].out - 1) === 0;

    levIns[nLevels - 1] <== (1 - isZero[nLevels - 2].out);
    done[nLevels - 2] <== levIns[nLevels - 1];

    for (i = nLevels - 2; i > 0; i--) {
        levIns[i] <== (1 - done[i]) * (1 - isZero[i - 1].out);
        done[i - 1] <== levIns[i] + done[i];
    }

    levIns[0] <== (1 - done[0]);
}

// siblings: 0x123 0x456 0 0 0 0 0 0 0 0 0 0 0
// levIns:   0     0     1 0 0 0 0 0 0 0 0 0 0
// st_top:   1     1     0 0 0 0 0 0 0 0 0 0 0
// st_inew:  0     0     1 0 0 0 0 0 0 0 0 0 0
template SMTVerifierSM() {
    signal input levIns;
    signal input prev_top;

    signal output st_top;
    signal output st_inew;

    st_inew <== prev_top * levIns;
    st_top <== prev_top - st_inew;
}

template SMTVerifierLevel() {
    signal input st_top;
    signal input st_inew;

    signal output root;
    signal input sibling;
    signal input new1leaf;
    signal input lrbit;
    signal input child;

    signal fromProof;

    component proofHash = SMTHash2();
    component switcher = Switcher();

    switcher.L <== child;
    switcher.R <== sibling;

    switcher.sel <== lrbit;
    proofHash.L <== switcher.outL;
    proofHash.R <== switcher.outR;

    fromProof <== proofHash.out * st_top;

    root <== fromProof + (new1leaf * st_inew);
}

template MerkleTreapVerifier(nLevels) {
    signal output nullifierHash;
    signal output isVerified;

    signal input root;
    signal input leaf;

    signal input siblings[nLevels];
    signal input order[nLevels];

    var i;

    signal value <== leaf;

    component smtLevIns = SMTLevIns(nLevels);

    for (i = 0; i < nLevels; i++) {
        smtLevIns.siblings[i] <== siblings[i];
    }

    component sm[nLevels];

    for (i = 0; i < nLevels; i++) {
        sm[i] = SMTVerifierSM();

        if (i == 0) {
            sm[i].prev_top <== 1;
        } else {
            sm[i].prev_top <== sm[i - 1].st_top;
        }

        sm[i].levIns <== smtLevIns.levIns[i];
    }

    component levels[nLevels];

    for (i = nLevels - 1; i != -1; i--) {
        levels[i] = SMTVerifierLevel();

        levels[i].st_top <== sm[i].st_top;
        levels[i].st_inew <== sm[i].st_inew;

        levels[i].sibling <== siblings[i];
        levels[i].new1leaf <== leaf;

        levels[i].lrbit <== order[i];

        if (i == nLevels - 1) {
            levels[i].child <== 0;
        } else {
            levels[i].child <== levels[i + 1].root;
        }
        
    }

    component isEqual = IsEqual();
    isEqual.in[0] <== levels[0].root;
    isEqual.in[1] <== root;
    isVerified <== isEqual.out;
}

component main = MerkleTreapVerifier(16);