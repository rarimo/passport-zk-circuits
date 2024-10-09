pragma circom 2.1.6;

include "../../../../../circuits/ecdsa/secp256r1/p256.circom";

template PipingerMultTest(CHUNK_SIZE, CHUNK_NUMBER){
    signal input scalar[CHUNK_NUMBER];
    signal input point[2][CHUNK_NUMBER];
    signal input point2[2][CHUNK_NUMBER];

    component mult = P256PipingerMult(CHUNK_SIZE, CHUNK_NUMBER, 4);
    mult.scalar <== scalar;
    mult.point  <== point;

    signal output out[2][CHUNK_NUMBER];
    out <== mult.out;

}

template NonPipingerMultTest(CHUNK_SIZE, CHUNK_NUMBER){
    signal input scalar[CHUNK_NUMBER];
    signal input point[2][CHUNK_NUMBER];
    signal input point2[2][CHUNK_NUMBER];

    component mult = P256ScalarMult(CHUNK_SIZE, CHUNK_NUMBER);
    mult.scalar <== scalar;
    mult.point  <== point;

    signal output out[2][CHUNK_NUMBER];
    out <== mult.out;
}

template Add(CHUNK_SIZE, CHUNK_NUMBER){
    signal input scalar[CHUNK_NUMBER];
    signal input point[2][CHUNK_NUMBER];
    signal input point2[2][CHUNK_NUMBER];

    component add = P256AddUnequal(CHUNK_SIZE, CHUNK_NUMBER);
    add.point1 <== point;
    add.point2 <== point2;

    signal output out[2][CHUNK_NUMBER];
    out <== add.out;

}

template Double(CHUNK_SIZE, CHUNK_NUMBER){
    signal input scalar[CHUNK_NUMBER];
    signal input point[2][CHUNK_NUMBER];
    signal input point2[2][CHUNK_NUMBER];

    component doubling = P256Double(CHUNK_SIZE, CHUNK_NUMBER);
    doubling.in <== point;

    signal output out[2][CHUNK_NUMBER];
    out <== doubling.out;
}

