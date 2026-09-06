pragma circom 2.1.6;

include "p256.circom";
include "P256Func.circom";
include "circomlib/circuits/bitify.circom";
include "../utils/func.circom";

template verifyP256(CHUNK_SIZE, CHUNK_NUMBER, ALGO)
{
    signal input pubkey[2 * 256];
    signal input signature[2 * 256];
    signal input hashed[ALGO];

    signal pubkeyChunked[2][CHUNK_NUMBER];
    signal signatureChunked[2][CHUNK_NUMBER];

    signal pubkeyBits[2][CHUNK_SIZE * CHUNK_NUMBER];
    signal signatureBits[2][CHUNK_SIZE * CHUNK_NUMBER];
    pubkeyBits[0][0] <== 0;
    pubkeyBits[1][0] <== 0;
    signatureBits[0][0] <== 0;
    signatureBits[1][0] <== 0;
    pubkeyBits[0][1] <== 0;
    pubkeyBits[1][1] <== 0;
    signatureBits[0][1] <== 0;
    signatureBits[1][1] <== 0;

    for (var i = 0; i < 2; i++){
        for (var j = 0; j < 256; j++){
            pubkeyBits[i][j+2] <== pubkey[i*256 + j];
            signatureBits[i][j+2] <== signature[i*256 +j];
        }
    }

    component bits2NumInput[2*2*CHUNK_NUMBER];

    for (var i = 0; i < 2; i++){
        for (var j = 0; j < CHUNK_NUMBER; j++){
            bits2NumInput[i*CHUNK_NUMBER+j] = Bits2Num(CHUNK_SIZE);
            bits2NumInput[(i+2)*CHUNK_NUMBER+j] = Bits2Num(CHUNK_SIZE);

            for (var z = 0; z < CHUNK_SIZE; z++){
                bits2NumInput[i*CHUNK_NUMBER+j].in[z] <== pubkeyBits[i][CHUNK_SIZE * j + CHUNK_SIZE - 1  - z];
                bits2NumInput[(i+2)*CHUNK_NUMBER+j].in[z] <== signatureBits[i][CHUNK_SIZE * j + CHUNK_SIZE - 1 - z];
            }
            bits2NumInput[i*CHUNK_NUMBER+j].out ==> pubkeyChunked[i][CHUNK_NUMBER - 1 - j];
            bits2NumInput[(i+2)*CHUNK_NUMBER+j].out ==> signatureChunked[i][CHUNK_NUMBER - 1 - j];
        }
    }


    signal hashedMessageBits[CHUNK_SIZE * CHUNK_NUMBER];
    hashedMessageBits[0] <== 0;
    hashedMessageBits[1] <== 0;
    for (var i = 0; i < ALGO; i++){
        hashedMessageBits[i+2] <== hashed[i];
    }


    signal hashedMessageChunked[CHUNK_NUMBER];

    component bits2Num[CHUNK_NUMBER];
    for (var i = 0; i < CHUNK_NUMBER; i++) {
        bits2Num[i] = Bits2Num(CHUNK_SIZE);
        for (var j = 0; j < CHUNK_SIZE; j++) {
            bits2Num[i].in[CHUNK_SIZE-1-j] <== hashedMessageBits[i*CHUNK_SIZE+j];
        }
        hashedMessageChunked[CHUNK_NUMBER-1-i] <== bits2Num[i].out;
    }

    component getOrder = GetP256Order(CHUNK_SIZE,CHUNK_NUMBER);
    signal order[CHUNK_NUMBER];
    order <== getOrder.order;

    signal sinv[CHUNK_NUMBER];

    component modInv = BigModInv(CHUNK_SIZE,CHUNK_NUMBER);

    modInv.in <== signatureChunked[1];
    modInv.p <== order;
    modInv.out ==> sinv;

    signal sh[CHUNK_NUMBER];

    component mult = BigMultModP(CHUNK_SIZE,CHUNK_NUMBER);

    mult.a <== sinv;
    mult.b <== hashedMessageChunked;
    mult.p <== order;
    sh <== mult.out;


    signal sr[CHUNK_NUMBER];

    component mult2 = BigMultModP(CHUNK_SIZE,CHUNK_NUMBER);

    mult2.a <== sinv;
    mult2.b <== signatureChunked[0];
    mult2.p <== order;
    sr <== mult2.out;

    signal tmpPoint1[2][CHUNK_NUMBER];
    signal tmpPoint2[2][CHUNK_NUMBER];

    component scalarMult1 = P256GeneratorMultiplication(CHUNK_SIZE,CHUNK_NUMBER);
    component scalarMult2 = P256PipingerMult(CHUNK_SIZE,CHUNK_NUMBER,4);

    scalarMult1.scalar <== sh;

    tmpPoint1 <== scalarMult1.out;

    scalarMult2.scalar <== sr;
    scalarMult2.point <== pubkeyChunked;

    tmpPoint2 <== scalarMult2.out;

    signal verifyX[CHUNK_NUMBER];

    component sumPoints = P256AddUnequal(CHUNK_SIZE,CHUNK_NUMBER);

    sumPoints.point1 <== tmpPoint1;
    sumPoints.point2 <== tmpPoint2;
    verifyX <== sumPoints.out[0];

    verifyX === signatureChunked[0];
}

