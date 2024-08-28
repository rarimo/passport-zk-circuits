pragma circom 2.1.9;

include "p256.circom";
include "p256_func.circom";
include "circomlib/circuits/bitify.circom";

template verifyP256(n, k, ALGO){
    signal input pubkey[2 * n * k];
    signal input signature[2 * n * k];
    signal input hashed[ALGO];

    signal pubkey_43_6[2][6];
    signal signature_43_6[2][6];

    signal pubkey_bits[2][258];
    signal signature_bits[2][258];
    pubkey_bits[0][0] <== 0;
    pubkey_bits[0][1] <== 0;
    pubkey_bits[1][0] <== 0;
    pubkey_bits[1][1] <== 0;
    signature_bits[0][0] <== 0;    
    signature_bits[0][1] <== 0;    
    signature_bits[1][0] <== 0;    
    signature_bits[1][1] <== 0;    

    for (var i = 0; i < 2; i++){
        for (var j = 0; j < 256; j++){
            pubkey_bits[i][j+2] <== pubkey[i*256 + j];
            signature_bits[i][j+2] <== signature[i*256 +j];
        }
    }

    component bits2NumInput[24];

    for (var i = 0; i < 2; i++){
        for (var j = 0; j < 6; j++){
            bits2NumInput[i*6+j] = Bits2Num(43);
            bits2NumInput[(i+2)*6+j] = Bits2Num(43);

            for (var z = 0; z < 43; z++){
                bits2NumInput[i*6+j].in[z] <== pubkey_bits[i][43 * j + 42 - z];
                bits2NumInput[(i+2)*6+j].in[z] <== signature_bits[i][43 * j + 42 - z];
            }
            bits2NumInput[i*6+j].out ==> pubkey_43_6[i][5-j];
            bits2NumInput[(i+2)*6+j].out ==> signature_43_6[i][5-j];
        }
    }


    signal hashed_message_bits[258];
    hashed_message_bits[0] <== 0;
    hashed_message_bits[1] <== 0;
    for (var i = 0; i < ALGO; i++){
        hashed_message_bits[i+2] <== hashed[i];
    }


    signal hashed_message[6];

    component bits2Num[6];
    for (var i = 0; i < 6; i++) {
        bits2Num[i] = Bits2Num(43);
        for (var j = 0; j < 43; j++) {
            bits2Num[i].in[43-1-j] <== hashed_message_bits[i*43+j];
        }
        hashed_message[6-1-i] <== bits2Num[i].out;
    }

    component getOrder = GetP256Order(43,6);
    signal order[6];
    order <== getOrder.order;

    signal sinv[6];

    component mod_inv = BigModInv(43,6);

    mod_inv.in <== signature_43_6[1];
    mod_inv.p <== order;
    mod_inv.out ==> sinv;

    signal sh[6];

    component mult = BigMultModP(43,6);
    
    mult.a <== sinv;
    mult.b <== hashed_message;
    mult.p <== order;
    sh <== mult.out;


    signal sr[6];

    component mult2 = BigMultModP(43,6);
    
    mult2.a <== sinv;
    mult2.b <== signature_43_6[0];
    mult2.p <== order;
    sr <== mult2.out;

    signal tmpPoint1[2][6];
    signal tmpPoint2[2][6];

    component scalarMult1 = P256GeneratorMultiplication(43,6);
    component scalarMult2 = P256ScalarMult(43,6);
    
    scalarMult1.scalar <== sh;

    tmpPoint1 <== scalarMult1.out;

    scalarMult2.scalar <== sr;
    scalarMult2.point <== pubkey_43_6;

    tmpPoint2 <== scalarMult2.out;

    signal verifyX[6];

    component sumPoints = P256AddUnequal(43,6);
    
    sumPoints.point1 <== tmpPoint1;
    sumPoints.point2 <== tmpPoint2;
    verifyX <== sumPoints.out[0];

    verifyX === signature_43_6[0];
}

