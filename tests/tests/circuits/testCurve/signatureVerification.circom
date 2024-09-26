pragma circom 2.1.6;

include "p256.circom";
include "P256Func.circom";
include "../../../../node_modules/circomlib/circuits/bitify.circom";
include "../../../../circuits/ecdsa/utils/func.circom";

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
    pubkeyBits[0][2] <== 0;
    pubkeyBits[1][2] <== 0;
    signatureBits[0][2] <== 0;
    signatureBits[1][2] <== 0;
    pubkeyBits[0][3] <== 0;
    pubkeyBits[1][3] <== 0;
    signatureBits[0][3] <== 0;
    signatureBits[1][3] <== 0;
    pubkeyBits[0][4] <== 0;
    pubkeyBits[1][4] <== 0;
    signatureBits[0][4] <== 0;
    signatureBits[1][4] <== 0;
    pubkeyBits[0][5] <== 0;
    pubkeyBits[1][5] <== 0;
    signatureBits[0][5] <== 0;
    signatureBits[1][5] <== 0;
    pubkeyBits[0][6] <== 0;
    pubkeyBits[1][6] <== 0;
    signatureBits[0][6] <== 0;
    signatureBits[1][6] <== 0;
    pubkeyBits[0][7] <== 0;
    pubkeyBits[1][7] <== 0;
    signatureBits[0][7] <== 0;
    signatureBits[1][7] <== 0;
    pubkeyBits[0][8] <== 0;
    pubkeyBits[1][8] <== 0;
    signatureBits[0][8] <== 0;
    signatureBits[1][8] <== 0;
    pubkeyBits[0][9] <== 0;
    pubkeyBits[1][9] <== 0;
    signatureBits[0][9] <== 0;
    signatureBits[1][9] <== 0;
    pubkeyBits[0][10] <== 0;
    pubkeyBits[1][10] <== 0;
    signatureBits[0][10] <== 0;
    signatureBits[1][10] <== 0;
    pubkeyBits[0][11] <== 0;
    pubkeyBits[1][11] <== 0;
    signatureBits[0][11] <== 0;
    signatureBits[1][11] <== 0;
    pubkeyBits[0][12] <== 0;
    pubkeyBits[1][12] <== 0;
    signatureBits[0][12] <== 0;
    signatureBits[1][12] <== 0;
    pubkeyBits[0][13] <== 0;
    pubkeyBits[1][13] <== 0;
    signatureBits[0][13] <== 0;
    signatureBits[1][13] <== 0;
    pubkeyBits[0][14] <== 0;
    pubkeyBits[1][14] <== 0;
    signatureBits[0][14] <== 0;
    signatureBits[1][14] <== 0;
    pubkeyBits[0][15] <== 0;
    pubkeyBits[1][15] <== 0;
    signatureBits[0][15] <== 0;
    signatureBits[1][15] <== 0;
    pubkeyBits[0][16] <== 0;
    pubkeyBits[1][16] <== 0;
    signatureBits[0][16] <== 0;
    signatureBits[1][16] <== 0;
    pubkeyBits[0][17] <== 0;
    pubkeyBits[1][17] <== 0;
    signatureBits[0][17] <== 0;
    signatureBits[1][17] <== 0;
    pubkeyBits[0][18] <== 0;
    pubkeyBits[1][18] <== 0;
    signatureBits[0][18] <== 0;
    signatureBits[1][18] <== 0;
    pubkeyBits[0][19] <== 0;
    pubkeyBits[1][19] <== 0;
    signatureBits[0][19] <== 0;
    signatureBits[1][19] <== 0;
    pubkeyBits[0][20] <== 0;
    pubkeyBits[1][20] <== 0;
    signatureBits[0][20] <== 0;
    signatureBits[1][20] <== 0;
    pubkeyBits[0][21] <== 0;
    pubkeyBits[1][21] <== 0;
    signatureBits[0][21] <== 0;
    signatureBits[1][21] <== 0;
    pubkeyBits[0][22] <== 0;
    pubkeyBits[1][22] <== 0;
    signatureBits[0][22] <== 0;
    signatureBits[1][22] <== 0;
    pubkeyBits[0][23] <== 0;
    pubkeyBits[1][23] <== 0;
    signatureBits[0][23] <== 0;
    signatureBits[1][23] <== 0;
    pubkeyBits[0][24] <== 0;
    pubkeyBits[1][24] <== 0;
    signatureBits[0][24] <== 0;
    signatureBits[1][24] <== 0;
    pubkeyBits[0][25] <== 0;
    pubkeyBits[1][25] <== 0;
    signatureBits[0][25] <== 0;
    signatureBits[1][25] <== 0;
    pubkeyBits[0][26] <== 0;
    pubkeyBits[1][26] <== 0;
    signatureBits[0][26] <== 0;
    signatureBits[1][26] <== 0;
    pubkeyBits[0][27] <== 0;
    pubkeyBits[1][27] <== 0;
    signatureBits[0][27] <== 0;
    signatureBits[1][27] <== 0;
    pubkeyBits[0][28] <== 0;
    pubkeyBits[1][28] <== 0;
    signatureBits[0][28] <== 0;
    signatureBits[1][28] <== 0;
    pubkeyBits[0][29] <== 0;
    pubkeyBits[1][29] <== 0;
    signatureBits[0][29] <== 0;
    signatureBits[1][29] <== 0;
    pubkeyBits[0][30] <== 0;
    pubkeyBits[1][30] <== 0;
    signatureBits[0][30] <== 0;
    signatureBits[1][30] <== 0;
    pubkeyBits[0][31] <== 0;
    pubkeyBits[1][31] <== 0;
    signatureBits[0][31] <== 0;
    signatureBits[1][31] <== 0;
    pubkeyBits[0][32] <== 0;
    pubkeyBits[1][32] <== 0;
    signatureBits[0][32] <== 0;
    signatureBits[1][32] <== 0;
    pubkeyBits[0][33] <== 0;
    pubkeyBits[1][33] <== 0;
    signatureBits[0][33] <== 0;
    signatureBits[1][33] <== 0;
    pubkeyBits[0][34] <== 0;
    pubkeyBits[1][34] <== 0;
    signatureBits[0][34] <== 0;
    signatureBits[1][34] <== 0;
    pubkeyBits[0][35] <== 0;
    pubkeyBits[1][35] <== 0;
    signatureBits[0][35] <== 0;
    signatureBits[1][35] <== 0;
    pubkeyBits[0][36] <== 0;
    pubkeyBits[1][36] <== 0;
    signatureBits[0][36] <== 0;
    signatureBits[1][36] <== 0;
    pubkeyBits[0][37] <== 0;
    pubkeyBits[1][37] <== 0;
    signatureBits[0][37] <== 0;
    signatureBits[1][37] <== 0;
    pubkeyBits[0][38] <== 0;
    pubkeyBits[1][38] <== 0;
    signatureBits[0][38] <== 0;
    signatureBits[1][38] <== 0;
    pubkeyBits[0][39] <== 0;
    pubkeyBits[1][39] <== 0;
    signatureBits[0][39] <== 0;
    signatureBits[1][39] <== 0;
    pubkeyBits[0][40] <== 0;
    pubkeyBits[1][40] <== 0;
    signatureBits[0][40] <== 0;
    signatureBits[1][40] <== 0;
    pubkeyBits[0][41] <== 0;
    pubkeyBits[1][41] <== 0;
    signatureBits[0][41] <== 0;
    signatureBits[1][41] <== 0;
    pubkeyBits[0][42] <== 0;
    pubkeyBits[1][42] <== 0;
    signatureBits[0][42] <== 0;
    signatureBits[1][42] <== 0;
    pubkeyBits[0][43] <== 0;
    pubkeyBits[1][43] <== 0;
    signatureBits[0][43] <== 0;
    signatureBits[1][43] <== 0;
    pubkeyBits[0][44] <== 0;
    pubkeyBits[1][44] <== 0;
    signatureBits[0][44] <== 0;
    signatureBits[1][44] <== 0;
    pubkeyBits[0][45] <== 0;
    pubkeyBits[1][45] <== 0;
    signatureBits[0][45] <== 0;
    signatureBits[1][45] <== 0;
    pubkeyBits[0][46] <== 0;
    pubkeyBits[1][46] <== 0;
    signatureBits[0][46] <== 0;
    signatureBits[1][46] <== 0;
    pubkeyBits[0][47] <== 0;
    pubkeyBits[1][47] <== 0;
    signatureBits[0][47] <== 0;
    signatureBits[1][47] <== 0;
    pubkeyBits[0][48] <== 0;
    pubkeyBits[1][48] <== 0;
    signatureBits[0][48] <== 0;
    signatureBits[1][48] <== 0;
    pubkeyBits[0][49] <== 0;
    pubkeyBits[1][49] <== 0;
    signatureBits[0][49] <== 0;
    signatureBits[1][49] <== 0;
    pubkeyBits[0][50] <== 0;
    pubkeyBits[1][50] <== 0;
    signatureBits[0][50] <== 0;
    signatureBits[1][50] <== 0;
    pubkeyBits[0][51] <== 0;
    pubkeyBits[1][51] <== 0;
    signatureBits[0][51] <== 0;
    signatureBits[1][51] <== 0;
    pubkeyBits[0][52] <== 0;
    pubkeyBits[1][52] <== 0;
    signatureBits[0][52] <== 0;
    signatureBits[1][52] <== 0;
    pubkeyBits[0][53] <== 0;
    pubkeyBits[1][53] <== 0;
    signatureBits[0][53] <== 0;
    signatureBits[1][53] <== 0;
    pubkeyBits[0][54] <== 0;
    pubkeyBits[1][54] <== 0;
    signatureBits[0][54] <== 0;
    signatureBits[1][54] <== 0;
    pubkeyBits[0][55] <== 0;
    pubkeyBits[1][55] <== 0;
    signatureBits[0][55] <== 0;
    signatureBits[1][55] <== 0;
    pubkeyBits[0][56] <== 0;
    pubkeyBits[1][56] <== 0;
    signatureBits[0][56] <== 0;
    signatureBits[1][56] <== 0;
    pubkeyBits[0][57] <== 0;
    pubkeyBits[1][57] <== 0;
    signatureBits[0][57] <== 0;
    signatureBits[1][57] <== 0;
    pubkeyBits[0][58] <== 0;
    pubkeyBits[1][58] <== 0;
    signatureBits[0][58] <== 0;
    signatureBits[1][58] <== 0;
    pubkeyBits[0][59] <== 0;
    pubkeyBits[1][59] <== 0;
    signatureBits[0][59] <== 0;
    signatureBits[1][59] <== 0;
    pubkeyBits[0][60] <== 0;
    pubkeyBits[1][60] <== 0;
    signatureBits[0][60] <== 0;
    signatureBits[1][60] <== 0;
    pubkeyBits[0][61] <== 0;
    pubkeyBits[1][61] <== 0;
    signatureBits[0][61] <== 0;
    signatureBits[1][61] <== 0;
    pubkeyBits[0][62] <== 0;
    pubkeyBits[1][62] <== 0;
    signatureBits[0][62] <== 0;
    signatureBits[1][62] <== 0;
    pubkeyBits[0][63] <== 0;
    pubkeyBits[1][63] <== 0;
    signatureBits[0][63] <== 0;
    signatureBits[1][63] <== 0;

    for (var i = 0; i < 2; i++){
        for (var j = 0; j < 256; j++){
            pubkeyBits[i][j+64] <== pubkey[i*256 + j];
            signatureBits[i][j+64] <== signature[i*256 +j];
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
        hashedMessageBits[i+64] <== hashed[i];
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

