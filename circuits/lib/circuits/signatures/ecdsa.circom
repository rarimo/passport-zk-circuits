pragma circom  2.1.6;

include "../ec/curve.circom";
include "../ec/get.circom";
include "../bigInt/bigInt.circom";

// Here is ecdsa signature verification
// For now, only 256 bit curves are allowed with chunking 64 4
//--------------------------------------------------------------------------------------------------------------------------------
// Use this one if you hash message in circuit (message is bits, not chunked int)!!!
// signature[2] = [r, s] - signature
// pubkey[2] = [x, y] - pubkey for signature
// hashed[ALGO] = h - hashed message by some algo (typically sha-2 256 for 256 bit curves)
// n is curve order
// s_inv = s ^ -1 mod n
// (x1, y1) = h * s_inv * G + r * s_inv * (x, y)
// x1 === r
template verifyECDSABits(CHUNK_SIZE, CHUNK_NUMBER, A, B, P, ALGO){
    
    signal input pubkey[2][CHUNK_NUMBER];
    signal input signature[2][CHUNK_NUMBER];
    signal input hashed[ALGO];
    

    signal hashedChunked[CHUNK_NUMBER];
    
    signal one[CHUNK_NUMBER];
    one[0] <== 1;
    for (var i = 1; i < CHUNK_NUMBER; i++){
        one[i] <== 0;
    }

    component bits2Num[CHUNK_NUMBER];
    for (var i = 0; i < CHUNK_NUMBER; i++) {
        bits2Num[i] = Bits2Num(CHUNK_SIZE);
        for (var j = 0; j < CHUNK_SIZE; j++) {
            bits2Num[i].in[CHUNK_SIZE - 1 - j] <== hashed[i * CHUNK_SIZE + j];
        }
        hashedChunked[CHUNK_NUMBER - 1 - i] <== bits2Num[i].out;
    }
    
    component getOrder = EllipicCurveGetOrder(CHUNK_SIZE,CHUNK_NUMBER, A, B, P);
    signal order[CHUNK_NUMBER];
    order <== getOrder.order;
    
    // s_inv = s ^ -1 mod n
    signal sinv[CHUNK_NUMBER];
    
    component modInv = BigModInv(CHUNK_SIZE, CHUNK_NUMBER);
    
    modInv.in <== signature[1];
    modInv.modulus <== order;
    modInv.out ==> sinv;
    
    // (s ^ -1 mod n) * h mod n
    component mult = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER, CHUNK_NUMBER);
    mult.in1 <== sinv;
    mult.in2 <== hashedChunked;
    mult.modulus <== order;

    // (s ^ -1 mod n) * r mod n
    component mult2 = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER, CHUNK_NUMBER);
    mult2.in1 <== sinv;
    mult2.in2 <== signature[0];
    mult2.modulus <== order;
    
    // h * s_inv * G
    component scalarMult1 = EllipicCurveScalarGeneratorMult(CHUNK_SIZE, CHUNK_NUMBER, A, B, P);
    scalarMult1.scalar <== mult.mod;
    
    // r * s_inv * (x, y)
    component scalarMult2 = EllipticCurveScalarMult(CHUNK_SIZE, CHUNK_NUMBER, A, B, P, 4);
    scalarMult2.scalar <== mult2.mod;
    scalarMult2.in <== pubkey;

    // (x1, y1) = h * s_inv * G + r * s_inv * (x, y)
    component add = EllipticCurveAdd(CHUNK_SIZE, CHUNK_NUMBER, A, B, P);
    add.in1 <== scalarMult1.out;
    add.in2 <== scalarMult2.out;

    // x1%n
    component modOrder = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER, CHUNK_NUMBER);
    modOrder.in1 <== add.out[0];
    modOrder.in2 <== one;
    modOrder.modulus <== order;
    
    // x1%n === r
    for (var i = 0; i < CHUNK_NUMBER; i++){
        modOrder.mod[i] === signature[0][i];
    }
}


// Use this one if yours message is chunk bigint 
// pubkey[2] = [x, y] - pubkey for signature
// signature[2] = [r, s] - signature
// hashed = h - hashed message 
// n is curve order
// s_inv = s ^ -1 mod n
// (x1, y1) = h * s_inv * G + r * s_inv * (x, y)
// x1 === r
template verifyECDSABigInt(CHUNK_SIZE, CHUNK_NUMBER, A, B, P){
    
    signal input pubkey[2][CHUNK_NUMBER];
    signal input signature[2][CHUNK_NUMBER];
    signal input hashed[CHUNK_NUMBER];

    signal one[CHUNK_NUMBER];
    one[0] <== 1;
    for (var i = 1; i < CHUNK_NUMBER; i++){
        one[i] <== 0;
    }
    
    component getOrder = EllipicCurveGetOrder(CHUNK_SIZE,CHUNK_NUMBER, A, B, P);
    signal order[CHUNK_NUMBER];
    order <== getOrder.order;
    
    // s_inv = s ^ -1 mod n
    signal sinv[CHUNK_NUMBER];
    
    component modInv = BigModInv(CHUNK_SIZE, CHUNK_NUMBER);
    
    modInv.in <== signature[1];
    modInv.modulus <== order;
    modInv.out ==> sinv;
    
    // (s ^ -1 mod n) * h mod n
    component mult = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER, CHUNK_NUMBER);
    mult.in1 <== sinv;
    mult.in2 <== hashed;
    mult.modulus <== order;

    // (s ^ -1 mod n) * r mod n
    component mult2 = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER, CHUNK_NUMBER);
    mult2.in1 <== sinv;
    mult2.in2 <== signature[0];
    mult2.modulus <== order;
    
    // h * s_inv * G
    component scalarMult1 = EllipicCurveScalarGeneratorMult(CHUNK_SIZE, CHUNK_NUMBER, A, B, P);
    scalarMult1.scalar <== mult.mod;
    
    // r * s_inv * (x, y)
    component scalarMult2 = EllipticCurveScalarMult(CHUNK_SIZE, CHUNK_NUMBER, A, B, P, 4);
    scalarMult2.scalar <== mult2.mod;
    scalarMult2.in <== pubkey;

    // (x1, y1) = h * s_inv * G + r * s_inv * (x, y)
    component add = EllipticCurveAdd(CHUNK_SIZE, CHUNK_NUMBER, A, B, P);
    add.in1 <== scalarMult1.out;
    add.in2 <== scalarMult2.out;

    // x1%n
    component modOrder = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER, CHUNK_NUMBER);
    modOrder.in1 <== add.out[0];
    modOrder.in2 <== one;
    modOrder.modulus <== order;
    // x1%n === r
    for (var i = 0; i < CHUNK_NUMBER; i++){
        modOrder.mod[i] === signature[0][i];
    }
}