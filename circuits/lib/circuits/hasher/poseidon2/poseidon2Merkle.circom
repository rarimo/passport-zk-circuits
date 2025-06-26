pragma circom 2.0.0;

include "poseidon2Perm.circom";

//------------------------------------------------------------------------------
// Merkle tree built using the Poseidon2 permutation
//
// The number of leaves is `2**nLevels`
//

template PoseidonMerkle(nLevels) {
    
    var nLeaves = 2 ** nLevels;
    
    signal input  in[nLeaves];
    signal output outRoot;
    
    component hsh[nLeaves - 1];
    signal aux[2 * nLeaves - 1];
    
    for (var k = 0; k < nLeaves; k++) {
        aux[k] <== in[k];
    }
    
    var a = 0; 
    var u = 0; 
    
    for (var lev = 0; lev < nLevels; lev++) {
        
        var b = a + 2 ** (nLevels - lev);
        var v = u + 2 ** (nLevels - lev - 1);
        
        var nCherries = 2 ** (nLevels - lev - 1);
        for (var k = 0; k < nCherries; k++) {
            hsh[u + k] = Compression();
            hsh[u + k].in[0] <== aux[a + 2 * k  ];
            hsh[u + k].in[1] <== aux[a + 2 * k + 1];
            hsh[u + k].out ==> aux[b + k];
        }
        
        a = b;
        u = v;
    }
    
    aux[2 * nLeaves - 2] ==> outRoot;
}

//------------------------------------------------------------------------------

