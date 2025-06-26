pragma circom 2.0.0;

include "poseidon2Perm.circom";

//------------------------------------------------------------------------------

function min(a,b) {
    return (a <= b) ? a : b;
}

//------------------------------------------------------------------------------

//
// Poseidon sponge construction
//
//   T = size of state (currently fixed to 3)
//   c = CAPACITY (1 or 2)
//   r = RATE = T - c
//
// everything is measured in number of field elements 
//
// we use the padding `10*` from the original Poseidon paper,
// and initial state constant zero. Note that this is different 
// from the "SAFE padding" recommended in the Poseidon2 paper
// (which uses `0*` padding and a nontrivial initial state)
//

template PoseidonSponge(T, CAPACITY, INPUT_LEN, OUTPUT_LEN) {
    
    var RATE = T - CAPACITY;
    
    assert(T == 3);
    
    assert(CAPACITY != 0);
    assert(RATE != 0);
    assert(CAPACITY < T);
    assert(RATE < T);
    
    signal input in[INPUT_LEN];
    signal output out[OUTPUT_LEN];
    
    // round up to RATE the input + 1 field element ("10*" padding)
    var N_BLOCKS = ((INPUT_LEN + 1) + (RATE - 1)) \ RATE;
    var N_OUT = (OUTPUT_LEN + (RATE - 1)) \ RATE;
    var PADDED_LEN = N_BLOCKS * RATE;
    
    signal padded[PADDED_LEN];
    for (var i = 0; i < INPUT_LEN; i++) {
        padded[i] <== in[i];
    }
    padded[INPUT_LEN] <== 1;
    for (var i = INPUT_LEN + 1; i < PADDED_LEN; i++) {
        padded[i] <== 0;
    }
    
    signal state [N_BLOCKS + N_OUT][T];
    signal sorbed[N_BLOCKS][RATE];
    
    // domain separation, CAPACITY IV:
    var CIV = 2 ** 64 + 256 * T + RATE;
    
    // initialize state
    for (var i = 0; i < T - 1; i++) {
        state[0][i] <== 0;
    }
    state[0][T - 1] <== CIV;
    
    component absorb[N_BLOCKS];
    component squeeze[N_OUT - 1];
    
    for (var m = 0; m < N_BLOCKS; m++) {
        
        for (var i = 0; i < RATE; i++) {
            var a = state[m][i];
            var b = padded[m * RATE + i];
            sorbed[m][i] <== a + b;
        }
        
        absorb[m] = Permutation();
        for (var j = 0; j < RATE; j++) {
            absorb[m].in[j] <== sorbed[m][j];
        }
        for (var j = RATE; j < T; j++) {
            absorb[m].in[j] <== state [m][j];
        }
        absorb[m].out ==> state[m + 1];
        
    }
    
    for (var i = 0; i < min(RATE, OUTPUT_LEN); i++) {
        state[N_BLOCKS][i] ==> out[i];
    }
    var OUT_PTR = RATE;
    
    for (var n = 1; n < N_OUT; n++) {
        squeeze[n - 1] = Permutation();
        squeeze[n - 1].in <== state[N_BLOCKS + n - 1];
        squeeze[n - 1].out ==> state[N_BLOCKS + n  ];
        
        var q = min(RATE, OUTPUT_LEN - OUT_PTR);
        for (var i = 0; i < q; i++) {
            state[N_BLOCKS + n][i] ==> out[OUT_PTR + i];
        }
        OUT_PTR += RATE;
    }
    
}

//------------------------------------------------------------------------------

//
// sponge hash with RATE 1 or 2
//

template Poseidon2SpongeHashRate1(n, RATE) {
    assert(RATE == 1 || RATE == 2);
    signal input  in[n];
    signal output out;
    component sponge;
    if (RATE == 1){
        sponge = PoseidonSponge(3, 2, n, 1);
    } else {
        sponge = PoseidonSponge(3, 1, n, 1);
    }
    sponge.in <== in;
    sponge.out[0] ==> out;
}
