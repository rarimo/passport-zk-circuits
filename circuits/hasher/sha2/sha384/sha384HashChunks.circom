pragma circom 2.0.0;

include "../sha2Common.circom";
include "../sha512/sha512Schedule.circom";
include "../sha512/sha512Rounds.circom";
include "sha384InitialValue.circom";
include "../sha512/sha512Padding.circom";

template Sha384HashBits(len) {

  signal input  in[len];            // `len` bits
  signal output out[384];      

  var nchunks = SHA2_384_512_compute_number_of_chunks(len);

  signal chunks[nchunks  ][1024];
  signal states[nchunks+1][8][64];

  component pad = SHA2_384_512_padding(len);
  pad.inp <== in;
  pad.out ==> chunks;

  component iv = Sha384InitialValues();
  iv.out ==> states[0];

  component sch[nchunks]; 
  component rds[nchunks]; 

  for(var m=0; m<nchunks; m++) { 

    sch[m] = Sha2_384_512Schedule();
    rds[m] = Sha2_384_512Rounds(80); 

    for(var k=0; k<16; k++) {
      for(var i=0; i<64; i++) {
        sch[m].chunkBits[k][i] <== chunks[m][ k*64 + (63-i) ];
      }
    }

    sch[m].outWords ==> rds[m].words;

    rds[m].inpHash  <== states[m  ];
    rds[m].outHash  ==> states[m+1];
  }


  for(var j=0; j<6; j++) {
    for (var i = 0; i < 64; i++){
      out[j*64 + i] <== states[nchunks][j][63-i]; 
    }
  }

}

template Sha384HashChunks(BLOCK_NUM) {

  signal input  in[BLOCK_NUM * 1024];           
  signal output out[384];

  signal states[BLOCK_NUM+1][8][64];

  component iv = Sha384InitialValues();
  iv.out ==> states[0];

  component sch[BLOCK_NUM]; 
  component rds[BLOCK_NUM]; 

  for(var m=0; m<BLOCK_NUM; m++) { 

    sch[m] = Sha2_384_512Schedule();
    rds[m] = Sha2_384_512Rounds(80); 

    for(var k=0; k<16; k++) {
      for(var i=0; i<64; i++) {
        sch[m].chunkBits[k][i] <== in[m*1024 +  k*64 + (63-i) ];
      }
    }

    sch[m].outWords ==> rds[m].words;

    rds[m].inpHash  <== states[m  ];
    rds[m].outHash  ==> states[m+1];
  }

  for(var j=0; j<6; j++) {
    for (var i = 0; i < 64; i++){
      out[j*64 + i] <== states[BLOCK_NUM][j][63-i]; 
    }
  }
}
