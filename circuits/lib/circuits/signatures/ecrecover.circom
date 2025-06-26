pragma circom 2.1.6;

include "../ec/curve.circom";
include "../ec/get.circom";
include "../bigInt/bigInt.circom";
include "../bigInt/bigIntFunc.circom";
include "../utils/switcher.circom";

template EcRecover(CHUNK_SIZE, CHUNK_NUMBER, A, B, P){
    signal input v;
    signal input r[CHUNK_NUMBER];
    signal input s[CHUNK_NUMBER];
    signal input hashed[CHUNK_NUMBER];
    
    
    signal output out[2][CHUNK_NUMBER];
    
    
    component getOrder = EllipicCurveGetOrder(CHUNK_SIZE,CHUNK_NUMBER, A, B, P);
    signal order[CHUNK_NUMBER];
    order <== getOrder.order;
    
    
    component getGenerator = EllipticCurveGetGenerator(CHUNK_SIZE,CHUNK_NUMBER, A, B, P);
    signal gen[2][CHUNK_NUMBER];
    gen <== getGenerator.gen;
    
    
    component squareX = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER, CHUNK_NUMBER);
    squareX.in1 <== r;
    squareX.in2 <== r;
    squareX.modulus <== P;
    
    component cubeX = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER, CHUNK_NUMBER);
    
    cubeX.in1 <== squareX.mod;
    cubeX.in2 <== r;
    cubeX.modulus <== P;
    
    component coefMult = BigMultOverflow(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER);
    coefMult.in1 <== r;
    coefMult.in2 <== A;
    
    component getYSquare = BigMod(CHUNK_SIZE, CHUNK_NUMBER + 1, CHUNK_NUMBER);
    for (var i = 0; i < CHUNK_NUMBER; i++){
        getYSquare.base[i] <== cubeX.mod[i] + coefMult.out[i] + B[i];
    }
    getYSquare.base[CHUNK_NUMBER] <== 0;
    getYSquare.modulus <== P;
    
    // TODO: CHANGE FOR OTHER CHUNKING!!!!!
    // p + 1 // 4 in [64bit * 4] chunking; p - secp256k1 field
    var exp[4] = [18446744072635809548, 18446744073709551615, 18446744073709551615, 4611686018427387903];
    var var_y[200] = mod_exp(CHUNK_SIZE, CHUNK_NUMBER, getYSquare.mod, P, exp);
    
    signal y[CHUNK_NUMBER];
    
    for (var i = 0; i < CHUNK_NUMBER; i++){
        y[i] <-- var_y[i];
    }

    component yVerify = BigMultModP(CHUNK_SIZE, CHUNK_NUMBER, CHUNK_NUMBER, CHUNK_NUMBER);
    yVerify.in1 <== y;
    yVerify.in2 <== y;
    yVerify.modulus <== P;
    
    for (var i = 0; i < CHUNK_NUMBER; i++){
        yVerify.mod === getYSquare.mod;
    }

    component checkYParity = Num2Bits(CHUNK_SIZE);
    checkYParity.in <== y[0];
    
    component isEqualParity = IsEqual();
    isEqualParity.in[0] <== checkYParity.out[0];
    isEqualParity.in[1] <== v;

    component negateY = BigSub(CHUNK_SIZE, CHUNK_NUMBER);
    negateY.in[0] <== P;
    negateY.in[1] <== y;

    component switcher[CHUNK_NUMBER];
    for (var i = 0; i < CHUNK_NUMBER; i++){
        switcher[i] = Switcher();
        switcher[i].in[0] <== negateY.out[i];
        switcher[i].in[1] <== y[i];
        switcher[i].bool <== isEqualParity.out;
    }  
    
    
    component modInv = BigModInv(CHUNK_SIZE, CHUNK_NUMBER);
    
    modInv.in <== r;
    modInv.modulus <== order;
    
    component negateS = BigSub(CHUNK_SIZE, CHUNK_NUMBER);
    negateS.in[0] <== order;
    negateS.in[1] <== s;

    component genMult = EllipicCurveScalarGeneratorMult(CHUNK_SIZE, CHUNK_NUMBER, A, B, P);
    genMult.scalar <== hashed;
    
    component scalarMult = EllipticCurveScalarMult(CHUNK_SIZE, CHUNK_NUMBER, A, B, P, 4);
    scalarMult.scalar <== negateS.out;
    scalarMult.in[0] <== r;
    for (var i = 0; i < CHUNK_NUMBER; i++){
        scalarMult.in[1][i] <== switcher[i].out[0];
    }
    
    component negateY2 = BigSub(CHUNK_SIZE, CHUNK_NUMBER);
    negateY2.in[0] <== P;
    negateY2.in[1] <== genMult.out[1];

    component pointAdd = EllipticCurveAdd(CHUNK_SIZE, CHUNK_NUMBER, A, B, P);
    pointAdd.in1[0] <== genMult.out[0];
    pointAdd.in1[1] <== negateY2.out;
    pointAdd.in2 <== scalarMult.out;

    component scalarMult2 = EllipticCurveScalarMult(CHUNK_SIZE, CHUNK_NUMBER, A, B, P, 4);
    scalarMult2.scalar <== modInv.out;
    scalarMult2.in <== pointAdd.out;

    out <== scalarMult2.out;    
}
