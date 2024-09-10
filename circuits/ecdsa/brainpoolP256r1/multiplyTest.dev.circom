include "./brainpool.circom";

template PipingerMultTest(CHUNK_SIZE, CHUNK_NUMBER){
    signal input scalar[CHUNK_NUMBER];
    signal input point[2][CHUNK_NUMBER];

    component mult = BrainpoolPipingerMult(CHUNK_SIZE, CHUNK_NUMBER, 4);
    mult.scalar <== scalar;
    mult.point  <== point;
    for (var j = 0; j< 2; j++){
        for (var i = 0; i< 6; i++){
            log(mult.out[j][i]);
        }
        log("---------");
    }
}

template NonPipingerMultTest(CHUNK_SIZE, CHUNK_NUMBER){
    signal input scalar[CHUNK_NUMBER];
    signal input point[2][CHUNK_NUMBER];

    component mult = BrainpoolScalarMult(CHUNK_SIZE, CHUNK_NUMBER);
    mult.scalar <== scalar;
    mult.point  <== point;
    for (var j = 0; j< 2; j++){
        for (var i = 0; i< 6; i++){
            log(mult.out[j][i]);
        }
        log("---------");
    }
}

