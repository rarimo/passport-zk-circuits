pragma circom 2.1.5;

include "../brainpoolP256r1/circomPairing/curve.circom";
include "p256Func.circom";
include "p256Pows.circom";
include "circomlib/circuits/multiplexer.circom";
include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/comparators.circom";
include "../utils/func.circom";

template P256AddUnequal(CHUNK_SIZE, CHUNK_NUMBER) {
    signal input point1[2][CHUNK_NUMBER];
    signal input point2[2][CHUNK_NUMBER];
    signal output out[2][CHUNK_NUMBER];

    var PARAMS[3][CHUNK_NUMBER] = get_p256_params(CHUNK_SIZE,CHUNK_NUMBER);

    component add = EllipticCurveAddUnequal(CHUNK_SIZE, CHUNK_NUMBER, PARAMS[2]);   
    add.a <== point1;
    add.b <== point2;
    add.out ==> out;
}

template P256Double(CHUNK_SIZE, CHUNK_NUMBER) {
    signal input in[2][CHUNK_NUMBER];
    signal output out[2][CHUNK_NUMBER];

    var PARAMS[3][CHUNK_NUMBER] = get_p256_params(CHUNK_SIZE,CHUNK_NUMBER);

    component doubling = EllipticCurveDouble(CHUNK_SIZE,CHUNK_NUMBER, PARAMS[0], PARAMS[1], PARAMS[2]);
    doubling.in <== in;
    doubling.out ==> out;
}

template P256ScalarMult(CHUNK_SIZE, CHUNK_NUMBER) {
    signal input scalar[CHUNK_NUMBER];
    signal input point[2][CHUNK_NUMBER];

    signal output out[2][CHUNK_NUMBER];

    component n2b[CHUNK_NUMBER];
    for (var i = 0; i < CHUNK_NUMBER; i++) {
        n2b[i] = Num2Bits(CHUNK_SIZE);
        n2b[i].in <== scalar[i];
    }

    // has_prev_non_zero[CHUNK_SIZE * i + j] == 1 if there is a nonzero bit in location [i][j] or higher order bit
    component has_prev_non_zero[CHUNK_NUMBER * CHUNK_SIZE];
    for (var i = CHUNK_NUMBER - 1; i >= 0; i--) {
        for (var j = CHUNK_SIZE - 1; j >= 0; j--) {
            has_prev_non_zero[CHUNK_SIZE * i + j] = OR();
            if (i == CHUNK_NUMBER - 1 && j == CHUNK_SIZE - 1) {
                has_prev_non_zero[CHUNK_SIZE * i + j].a <== 0;
                has_prev_non_zero[CHUNK_SIZE * i + j].b <== n2b[i].out[j];
            } else {
                has_prev_non_zero[CHUNK_SIZE * i + j].a <== has_prev_non_zero[CHUNK_SIZE * i + j + 1].out;
                has_prev_non_zero[CHUNK_SIZE * i + j].b <== n2b[i].out[j];
            }
        }
    }

    signal partial[CHUNK_SIZE * CHUNK_NUMBER][2][CHUNK_NUMBER];
    signal intermed[CHUNK_SIZE * CHUNK_NUMBER - 1][2][CHUNK_NUMBER];
    component adders[CHUNK_SIZE * CHUNK_NUMBER - 1];
    component doublers[CHUNK_SIZE * CHUNK_NUMBER - 1];
    for (var i = CHUNK_NUMBER - 1; i >= 0; i--) {
        for (var j = CHUNK_SIZE - 1; j >= 0; j--) {
            if (i == CHUNK_NUMBER - 1 && j == CHUNK_SIZE - 1) {
                for (var idx = 0; idx < CHUNK_NUMBER; idx++) {
                    partial[CHUNK_SIZE * i + j][0][idx] <== point[0][idx];
                    partial[CHUNK_SIZE * i + j][1][idx] <== point[1][idx];
                }
            }
            if (i < CHUNK_NUMBER - 1 || j < CHUNK_SIZE - 1) {
                adders[CHUNK_SIZE * i + j] = P256AddUnequal(CHUNK_SIZE, CHUNK_NUMBER);
                doublers[CHUNK_SIZE * i + j] = P256Double(CHUNK_SIZE, CHUNK_NUMBER);
                for (var idx = 0; idx < CHUNK_NUMBER; idx++) {
                    doublers[CHUNK_SIZE * i + j].in[0][idx] <== partial[CHUNK_SIZE * i + j + 1][0][idx];
                    doublers[CHUNK_SIZE * i + j].in[1][idx] <== partial[CHUNK_SIZE * i + j + 1][1][idx];
                }
                for (var idx = 0; idx < CHUNK_NUMBER; idx++) {
                    adders[CHUNK_SIZE * i + j].point1[0][idx] <== doublers[CHUNK_SIZE * i + j].out[0][idx];
                    adders[CHUNK_SIZE * i + j].point1[1][idx] <== doublers[CHUNK_SIZE * i + j].out[1][idx];
                    adders[CHUNK_SIZE * i + j].point2[0][idx] <== point[0][idx];
                    adders[CHUNK_SIZE * i + j].point2[1][idx] <== point[1][idx];
                }
                // partial[CHUNK_SIZE * i + j]
                // = has_prev_non_zero[CHUNK_SIZE * i + j + 1] * ((1 - n2b[i].out[j]) * doublers[CHUNK_SIZE * i + j] + n2b[i].out[j] * adders[CHUNK_SIZE * i + j])
                //   + (1 - has_prev_non_zero[CHUNK_SIZE * i + j + 1]) * point
                for (var idx = 0; idx < CHUNK_NUMBER; idx++) {
                    intermed[CHUNK_SIZE * i + j][0][idx] <== n2b[i].out[j] * (adders[CHUNK_SIZE * i + j].out[0][idx] - doublers[CHUNK_SIZE * i + j].out[0][idx]) + doublers[CHUNK_SIZE * i + j].out[0][idx];
                    intermed[CHUNK_SIZE * i + j][1][idx] <== n2b[i].out[j] * (adders[CHUNK_SIZE * i + j].out[1][idx] - doublers[CHUNK_SIZE * i + j].out[1][idx]) + doublers[CHUNK_SIZE * i + j].out[1][idx];
                    partial[CHUNK_SIZE * i + j][0][idx] <== has_prev_non_zero[CHUNK_SIZE * i + j + 1].out * (intermed[CHUNK_SIZE * i + j][0][idx] - point[0][idx]) + point[0][idx];
                    partial[CHUNK_SIZE * i + j][1][idx] <== has_prev_non_zero[CHUNK_SIZE * i + j + 1].out * (intermed[CHUNK_SIZE * i + j][1][idx] - point[1][idx]) + point[1][idx];
                }
            }
        }
    }

    for (var idx = 0; idx < CHUNK_NUMBER; idx++) {
        out[0][idx] <== partial[0][0][idx];
        out[1][idx] <== partial[0][1][idx];
    }
}

template GetP256Order(CHUNK_SIZE, CHUNK_NUMBER){
    assert((CHUNK_SIZE == 43) && (CHUNK_NUMBER == 6));
    signal output order[6];
    order[0] <== 3036481267025;
    order[1] <== 3246200354617;
    order[2] <== 7643362670236;
    order[3] <== 8796093022207;
    order[4] <== 1048575;
    order[5] <== 2199023255040;
}

template GetP256Generator(CHUNK_SIZE,CHUNK_NUMBER){
    assert((CHUNK_SIZE == 43) && (CHUNK_NUMBER == 6));

    signal x[CHUNK_NUMBER];
    signal y[CHUNK_NUMBER];
    signal output generator[2][CHUNK_NUMBER];
    x[0] <== 1399498261142;
    x[1] <== 5937592964135;
    x[2] <== 2044638659767;
    x[3] <== 3791144493177;
    x[4] <== 3041449184206;
    x[5] <== 919922271682;

    y[0] <== 447611884021;
    y[1] <== 6785408267976;
    y[2] <== 752572259756;
    y[3] <== 6207268441867;
    y[4] <== 1820960812670;
    y[5] <== 686230455804;

    generator[0] <== x;
    generator[1] <== y;

}

template P256GeneratorMultiplication(CHUNK_SIZE,CHUNK_NUMBER){
    var STRIDE = 8;
    signal input scalar[CHUNK_NUMBER];
    signal output out[2][CHUNK_NUMBER];

    component n2b[CHUNK_NUMBER];
    for (var i = 0; i < CHUNK_NUMBER; i++) {
        n2b[i] = Num2Bits(CHUNK_SIZE);
        n2b[i].in <== scalar[i];
    }

    var NUM_STRIDES = div_ceil(CHUNK_SIZE * CHUNK_NUMBER, STRIDE);
    // power[i][j] contains: [j * (1 << STRIDE * i) * G] for 1 <= j < (1 << STRIDE)
    var POWERS[NUM_STRIDES][2 ** STRIDE][2][CHUNK_NUMBER];
    POWERS = get_g_pow_stride8_table_p256(CHUNK_SIZE, CHUNK_NUMBER);

    var dummyHolder[2][CHUNK_NUMBER] = get_p256_dummy_point(CHUNK_SIZE, CHUNK_NUMBER);
    var dummy[2][CHUNK_NUMBER];
    for (var i = 0; i < CHUNK_NUMBER; i++) dummy[0][i] = dummyHolder[0][i];
    for (var i = 0; i < CHUNK_NUMBER; i++) dummy[1][i] = dummyHolder[1][i];

    component selectors[NUM_STRIDES];
    for (var i = 0; i < NUM_STRIDES; i++) {
        selectors[i] = Bits2Num(STRIDE);
        for (var j = 0; j < STRIDE; j++) {
            var bit_idx1 = (i * STRIDE + j) \ CHUNK_SIZE;
            var bit_idx2 = (i * STRIDE + j) % CHUNK_SIZE;
            if (bit_idx1 < CHUNK_NUMBER) {
                selectors[i].in[j] <== n2b[bit_idx1].out[bit_idx2];
            } else {
                selectors[i].in[j] <== 0;
            }
        }
    }

    // multiplexers[i][l].out will be the coordinates of:
    // selectors[i].out * (2 ** (i * STRIDE)) * G    if selectors[i].out is non-zero
    // (2 ** 255) * G                                if selectors[i].out is zero
    component multiplexers[NUM_STRIDES][2];
    // select from CHUNK_NUMBER-register outputs using a 2 ** STRIDE bit selector
    for (var i = 0; i < NUM_STRIDES; i++) {
        for (var l = 0; l < 2; l++) {
            multiplexers[i][l] = Multiplexer(CHUNK_NUMBER, (1 << STRIDE));
            multiplexers[i][l].sel <== selectors[i].out;
            for (var idx = 0; idx < CHUNK_NUMBER; idx++) {
                multiplexers[i][l].inp[0][idx] <== dummy[l][idx];
                for (var j = 1; j < (1 << STRIDE); j++) {
                    multiplexers[i][l].inp[j][idx] <== POWERS[i][j][l][idx];
                }
            }
        }
    }

    component isZero[NUM_STRIDES];
    for (var i = 0; i < NUM_STRIDES; i++) {
        isZero[i] = IsZero();
        isZero[i].in <== selectors[i].out;
    }

    // hasPrevNonZero[i] = 1 if at least one of the selections in privkey up to STRIDE i is non-zero
    component hasPrevNonZero[NUM_STRIDES];
    hasPrevNonZero[0] = OR();
    hasPrevNonZero[0].a <== 0;
    hasPrevNonZero[0].b <== 1 - isZero[0].out;
    for (var i = 1; i < NUM_STRIDES; i++) {
        hasPrevNonZero[i] = OR();
        hasPrevNonZero[i].a <== hasPrevNonZero[i - 1].out;
        hasPrevNonZero[i].b <== 1 - isZero[i].out;
    }

    signal partial[NUM_STRIDES][2][CHUNK_NUMBER];
    for (var idx = 0; idx < CHUNK_NUMBER; idx++) {
        for (var l = 0; l < 2; l++) {
            partial[0][l][idx] <== multiplexers[0][l].out[idx];
        }
    }

    component adders[NUM_STRIDES - 1];
    signal intermed1[NUM_STRIDES - 1][2][CHUNK_NUMBER];
    signal intermed2[NUM_STRIDES - 1][2][CHUNK_NUMBER];
    for (var i = 1; i < NUM_STRIDES; i++) {
        adders[i - 1] = P256AddUnequal(CHUNK_SIZE, CHUNK_NUMBER);
        for (var idx = 0; idx < CHUNK_NUMBER; idx++) {
            for (var l = 0; l < 2; l++) {
                adders[i - 1].point1[l][idx] <== partial[i - 1][l][idx];
                adders[i - 1].point2[l][idx] <== multiplexers[i][l].out[idx];
            }
        }

        // partial[i] = hasPrevNonZero[i - 1] * ((1 - isZero[i]) * adders[i - 1].out + isZero[i] * partial[i - 1][0][idx])
        //              + (1 - hasPrevNonZero[i - 1]) * (1 - isZero[i]) * multiplexers[i]
        for (var idx = 0; idx < CHUNK_NUMBER; idx++) {
            for (var l = 0; l < 2; l++) {
                intermed1[i - 1][l][idx] <== isZero[i].out * (partial[i - 1][l][idx] - adders[i - 1].out[l][idx]) + adders[i - 1].out[l][idx];
                intermed2[i - 1][l][idx] <== multiplexers[i][l].out[idx] - isZero[i].out * multiplexers[i][l].out[idx];
                partial[i][l][idx] <== hasPrevNonZero[i - 1].out * (intermed1[i - 1][l][idx] - intermed2[i - 1][l][idx]) + intermed2[i - 1][l][idx];
            }
        }
    }

    for (var i = 0; i < CHUNK_NUMBER; i++) {
        for (var l = 0; l < 2; l++) {
            out[l][i] <== partial[NUM_STRIDES - 1][l][i];
        }
    }
}

template P256PrecomputePipinger(CHUNK_SIZE, CHUNK_NUMBER, WINDOW_SIZE){
    signal input in[2][CHUNK_NUMBER];

    var PRECOMPUTE_NUMBER = 2 ** WINDOW_SIZE; 

    signal output out[PRECOMPUTE_NUMBER][2][CHUNK_NUMBER];
    
    for (var i = 0; i < 2; i++){
        for (var j = 0; j < CHUNK_NUMBER; j++){
            out[0][i][j] <== 0;
        }
    }

    out[1] <== in;

    component doublers[PRECOMPUTE_NUMBER\2 - 1];
    component adders  [PRECOMPUTE_NUMBER\2 - 1];

    for (var i = 2; i < PRECOMPUTE_NUMBER; i++){
        if (i % 2 == 0){
            doublers[i\2 - 1]     = P256Double(CHUNK_SIZE, CHUNK_NUMBER);
            doublers[i\2 - 1].in  <== out[i\2];
            doublers[i\2 - 1].out ==> out[i];
        }
        else
        {
            adders[i\2 - 1]          = P256AddUnequal(CHUNK_SIZE, CHUNK_NUMBER);
            adders[i\2 - 1].point1   <== out[1];
            adders[i\2 - 1].point2   <== out[i - 1];
            adders[i\2 - 1].out      ==> out[i]; 
        }
    }
}

template P256PipingerMult(CHUNK_SIZE, CHUNK_NUMBER, WINDOW_SIZE){

    assert(WINDOW_SIZE == 4);

    signal input  point[2][CHUNK_NUMBER];
    signal input  scalar  [CHUNK_NUMBER];

    signal output out[2][CHUNK_NUMBER];

    var PRECOMPUTE_NUMBER = 2 ** WINDOW_SIZE;

    signal precomputed[PRECOMPUTE_NUMBER][2][CHUNK_NUMBER];

    component precompute = P256PrecomputePipinger(CHUNK_SIZE, CHUNK_NUMBER, WINDOW_SIZE);
    precompute.in  <== point;
    precompute.out ==> precomputed;

    var DOUBLERS_NUMBER = 256 - WINDOW_SIZE;
    var ADDERS_NUMBER   = 256 \ WINDOW_SIZE;

    component doublers[DOUBLERS_NUMBER];
    component adders  [ADDERS_NUMBER];
    component bits2Num[ADDERS_NUMBER];
    component num2Bits[CHUNK_NUMBER];

    signal res [ADDERS_NUMBER + 1][2][CHUNK_NUMBER];

    signal tmp [ADDERS_NUMBER][PRECOMPUTE_NUMBER][2][CHUNK_NUMBER];

    signal tmp2[ADDERS_NUMBER]    [2]   [CHUNK_NUMBER];
    signal tmp3[ADDERS_NUMBER]    [2][2][CHUNK_NUMBER];
    signal tmp4[ADDERS_NUMBER]    [2]   [CHUNK_NUMBER];
    signal tmp5[ADDERS_NUMBER]    [2][2][CHUNK_NUMBER];
    signal tmp6[ADDERS_NUMBER - 1][2][2][CHUNK_NUMBER];
    signal tmp7[ADDERS_NUMBER - 1][2]   [CHUNK_NUMBER];
    
    component equals    [ADDERS_NUMBER][PRECOMPUTE_NUMBER][2][CHUNK_NUMBER];
    component zeroEquals[ADDERS_NUMBER];
    component tmpEquals [ADDERS_NUMBER];

    component g = GetP256Generator(CHUNK_SIZE, CHUNK_NUMBER);
    signal gen[2][CHUNK_NUMBER];
    gen <== g.generator;

    signal scalarBits[256];

    for (var i = 0; i < CHUNK_NUMBER; i++){
        num2Bits[i] = Num2Bits(CHUNK_SIZE);
        num2Bits[i].in <== scalar[i];
        if (i != CHUNK_NUMBER - 1){
            for (var j = 0; j < CHUNK_SIZE; j++){
                scalarBits[256 - CHUNK_SIZE * (i + 1) + j] <== num2Bits[i].out[CHUNK_SIZE - 1 - j];
            }
        } else {
            for (var j = 0; j < CHUNK_SIZE - (CHUNK_SIZE*CHUNK_NUMBER - 256); j++){
                scalarBits[j] <== num2Bits[i].out[CHUNK_SIZE - 1 - (j + (CHUNK_SIZE * CHUNK_NUMBER - 256))];
            }
        }
    }

    res[0] <== precomputed[0];

    for (var i = 0; i < 256; i += WINDOW_SIZE){
        adders[i\WINDOW_SIZE] = P256AddUnequal(CHUNK_SIZE, CHUNK_NUMBER);
        bits2Num[i\WINDOW_SIZE] = Bits2Num(WINDOW_SIZE);
        for (var j = 0; j < WINDOW_SIZE; j++){
            bits2Num[i\WINDOW_SIZE].in[j] <== scalarBits[i + (WINDOW_SIZE - 1) - j];
        }

        tmpEquals[i\WINDOW_SIZE] = IsEqual();
        tmpEquals[i\WINDOW_SIZE].in[0] <== 0;
        tmpEquals[i\WINDOW_SIZE].in[1] <== res[i\WINDOW_SIZE][0][0];

        if (i != 0){
            for (var j = 0; j < WINDOW_SIZE; j++){
                doublers[i + j - WINDOW_SIZE] = P256Double(CHUNK_SIZE, CHUNK_NUMBER);

                if (j == 0){
                    for (var axis_idx = 0; axis_idx < 2; axis_idx++){
                        for (var coor_idx = 0; coor_idx < 6; coor_idx ++){
                            tmp6[i\WINDOW_SIZE - 1][0][axis_idx][coor_idx] <==      tmpEquals[i\WINDOW_SIZE].out  * gen[axis_idx][coor_idx];
                            tmp6[i\WINDOW_SIZE - 1][1][axis_idx][coor_idx] <== (1 - tmpEquals[i\WINDOW_SIZE].out) * res[i\WINDOW_SIZE][axis_idx][coor_idx];
                            tmp7[i\WINDOW_SIZE - 1]   [axis_idx][coor_idx] <== tmp6[i\WINDOW_SIZE - 1][0][axis_idx][coor_idx] 
                                                                             + tmp6[i\WINDOW_SIZE - 1][1][axis_idx][coor_idx];
                        }
                    }

                    doublers[i + j - WINDOW_SIZE].in <== tmp7[i\WINDOW_SIZE - 1];
                }
                else
                {
                    doublers[i + j - WINDOW_SIZE].in <== doublers[i + j - 1 - WINDOW_SIZE].out;
                }
            }
        }

       for (var point_idx = 0; point_idx < PRECOMPUTE_NUMBER; point_idx++){
            for (var axis_idx = 0; axis_idx < 2; axis_idx++){
                for (var coor_idx = 0; coor_idx < CHUNK_NUMBER; coor_idx++){
                    equals[i\WINDOW_SIZE][point_idx][axis_idx][coor_idx]       = IsEqual();
                    equals[i\WINDOW_SIZE][point_idx][axis_idx][coor_idx].in[0] <== point_idx;
                    equals[i\WINDOW_SIZE][point_idx][axis_idx][coor_idx].in[1] <== bits2Num[i\WINDOW_SIZE].out;
                    tmp   [i\WINDOW_SIZE][point_idx][axis_idx][coor_idx]       <== precomputed[point_idx][axis_idx][coor_idx] * 
                                                                         equals[i\WINDOW_SIZE][point_idx][axis_idx][coor_idx].out;
                }
            }
        }

        for (var axis_idx = 0; axis_idx < 2; axis_idx++){
            for (var coor_idx = 0; coor_idx < CHUNK_NUMBER; coor_idx++){
                tmp2[i\WINDOW_SIZE]   [axis_idx][coor_idx] <== 
                tmp[i\WINDOW_SIZE][0] [axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][1] [axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][2] [axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][3] [axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][4] [axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][5] [axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][6] [axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][7] [axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][8] [axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][9] [axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][10][axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][11][axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][12][axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][13][axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][14][axis_idx][coor_idx] + 
                tmp[i\WINDOW_SIZE][15][axis_idx][coor_idx];
            }
        }

        if (i == 0){

            adders[i\WINDOW_SIZE].point1 <== res [i\WINDOW_SIZE];
            adders[i\WINDOW_SIZE].point2 <== tmp2[i\WINDOW_SIZE];
            res[i\WINDOW_SIZE + 1]       <== tmp2[i\WINDOW_SIZE];

        } else {

            adders[i\WINDOW_SIZE].point1 <== doublers[i - 1].out;
            adders[i\WINDOW_SIZE].point2 <== tmp2[i\WINDOW_SIZE];

            zeroEquals[i\WINDOW_SIZE] = IsEqual();

            zeroEquals[i\WINDOW_SIZE].in[0]<== 0;
            zeroEquals[i\WINDOW_SIZE].in[1]<== tmp2[i\WINDOW_SIZE][0][0];

            for (var axis_idx = 0; axis_idx < 2; axis_idx++){
                for(var coor_idx = 0; coor_idx < CHUNK_NUMBER; coor_idx++){

                    tmp3[i\WINDOW_SIZE][0][axis_idx][coor_idx] <== adders    [i\WINDOW_SIZE].out[axis_idx][coor_idx] * (1 - zeroEquals[i\WINDOW_SIZE].out);
                    tmp3[i\WINDOW_SIZE][1][axis_idx][coor_idx] <== zeroEquals[i\WINDOW_SIZE].out                     * doublers[i-1].out[axis_idx][coor_idx];
                    tmp4[i\WINDOW_SIZE]   [axis_idx][coor_idx] <== tmp3[i\WINDOW_SIZE][0][axis_idx][coor_idx]        + tmp3[i\WINDOW_SIZE][1][axis_idx][coor_idx]; 
                    tmp5[i\WINDOW_SIZE][0][axis_idx][coor_idx] <== (1 - tmpEquals[i\WINDOW_SIZE].out)                * tmp4[i\WINDOW_SIZE]   [axis_idx][coor_idx];
                    tmp5[i\WINDOW_SIZE][1][axis_idx][coor_idx] <== tmpEquals[i\WINDOW_SIZE].out                      * tmp2[i\WINDOW_SIZE]   [axis_idx][coor_idx];
                                    
                    res[i\WINDOW_SIZE + 1][axis_idx][coor_idx] <== tmp5[i\WINDOW_SIZE][0][axis_idx][coor_idx] + tmp5[i\WINDOW_SIZE][1][axis_idx][coor_idx];                                 
                }
            }        
        }
    }

    out <== res[ADDERS_NUMBER];
}
