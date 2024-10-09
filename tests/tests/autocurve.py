import argparse
import sys
from curve_math import A, B, P, N, Gx, Gy, double, get_ecdsa_func_str
from utils import bigint_to_array

def get_func_str(n, k, curve_name):
    res_str = "pragma circom 2.1.6;\n\n"
    res_str +=  "function get_{curve_name}_order(CHUNK_SIZE, CHUNK_NUMBER)".format(curve_name = curve_name)
    res_str += '{'
    res_str += "\n"
    res_str += "\tassert((CHUNK_SIZE == {n}) && (CHUNK_NUMBER == {k}));\n\tvar ORDER[{k}];\n\n".format(n = n, k = k)

    order  = bigint_to_array(n, k, N)
    for i in range(0, k):
        res_str += "\tORDER[{i}] = {chunk};\n".format(i=i, chunk = order[i])
    res_str += "\n\treturn ORDER;\n"
    res_str += '}\n\n'

    res_str += "function get_{curve_name}_params(CHUNK_SIZE, CHUNK_NUMBER)".format(curve_name = curve_name)
    res_str += '{'
    res_str += "\n"
    res_str += "\tassert((CHUNK_SIZE == {n}) && (CHUNK_NUMBER == {k}));\n\tvar PARAMS[3][{k}];\n\n".format(n = n, k = k)
    res_str += "\tvar A[{k}];\n\tvar B[{k}];\n\tvar P[{k}];\n\n".format(k = k)


    a = bigint_to_array(n, k, A)
    b = bigint_to_array(n, k, B)
    p = bigint_to_array(n, k, P)
    for i in range(0, k):
        res_str += "\tA[{i}] = {chunk};\n".format(i=i, chunk = a[i])
    res_str += "\n"
    for i in range(0, k):
        res_str += "\tB[{i}] = {chunk};\n".format(i=i, chunk = b[i])
    res_str += "\n"
    for i in range(0, k):
        res_str += "\tP[{i}] = {chunk};\n".format(i=i, chunk = p[i])
    res_str += "\n"

    res_str += "\n\n\tPARAMS[0] = A;\n\tPARAMS[1] = B;\n\tPARAMS[2] = P;\n\n\treturn PARAMS;\n"
    res_str += '}\n\n'

    dummyx = Gx
    dummyy = Gy

    for _ in range(0, 255):
        dummyx, dummyy = double(dummyx, dummyy)

    dummyx_arr = bigint_to_array(n, k, dummyx)
    dummyy_arr = bigint_to_array(n, k, dummyy)


    res_str += "function get_{curve_name}_dummy_point(CHUNK_SIZE, CHUNK_NUMBER)".format(curve_name = curve_name)
    res_str += '{'
    res_str += "\n"
    res_str += "\tassert((CHUNK_SIZE == {n}) && (CHUNK_NUMBER == {k}));\n\tvar DUMMY[2][{k}];\n\n".format(n = n, k = k)

    for i in range (0, k):
        res_str += "\tDUMMY[0][{i}] = {tmp};\n".format(i=i, tmp = dummyx_arr[i])
    for i in range (0, k):
        res_str += "\tDUMMY[1][{i}] = {tmp};\n".format(i=i, tmp = dummyy_arr[i])
        
    res_str += "\n\n\treturn DUMMY;\n"
    res_str += '}\n\n'

    return res_str

def get_curve(n,k,curve_name, curve_field):


    res_str = ""
    res_str += "pragma circom 2.1.6;"
    res_str += "\n"
    res_str += "\n" + "include \"../../../..circuits/ecdsa/{curve_name}/circomPairing/curve.circom\";".format(curve_name = "brainpoolP256r1")
    res_str += "\n" + "include \"{curve_name}Func.circom\";".format(curve_name = curve_name)
    res_str += "\n" + "include \"{curve_name}Pows.circom\";".format(curve_name = curve_name)
    res_str += "\n" + "include \"../../../../node_modules/circomlib/circuits/multiplexer.circom\";"
    res_str += "\n" + "include \"../../../../node_modules/circomlib/circuits/bitify.circom\";"
    res_str += "\n" + "include \"../../../../node_modules/circomlib/circuits/comparators.circom\";"
    res_str += "\n" + "include \"../../../..circuits/ecdsa/utils/func.circom\";"
    res_str += "\n" + "\n"
    res_str += "\n" + "template {curve_name}AddUnequal(CHUNK_SIZE, CHUNK_NUMBER)".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "{"
    res_str += "\n" + "    signal input point1[2][CHUNK_NUMBER];"
    res_str += "\n" + "    signal input point2[2][CHUNK_NUMBER];"
    res_str += "\n" + "    signal output out[2][CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    var PARAMS[3][CHUNK_NUMBER] = get_{curve_name}_params(CHUNK_SIZE,CHUNK_NUMBER);".format(curve_name = curve_name)
    res_str += "\n" + "\n"
    res_str += "\n" + "    component add = EllipticCurveAddUnequal(CHUNK_SIZE, CHUNK_NUMBER, PARAMS[2]);   "
    res_str += "\n" + "    add.a <== point1;"
    res_str += "\n" + "    add.b <== point2;"
    res_str += "\n" + "    add.out ==> out;"
    res_str += "\n" + "}"
    res_str += "\n" + "\n"
    res_str += "\n" + "template {curve_name}Double(CHUNK_SIZE, CHUNK_NUMBER)".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "{"
    res_str += "\n" + "    signal input in[2][CHUNK_NUMBER];"
    res_str += "\n" + "    signal output out[2][CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    var PARAMS[3][CHUNK_NUMBER] = get_{curve_name}_params(CHUNK_SIZE,CHUNK_NUMBER);".format(curve_name = curve_name)
    res_str += "\n" + "\n"
    res_str += "\n" + "    component doubling = EllipticCurveDouble(CHUNK_SIZE,CHUNK_NUMBER, PARAMS[0], PARAMS[1], PARAMS[2]);"
    res_str += "\n" + "    doubling.in <== in;"
    res_str += "\n" + "    doubling.out ==> out;"
    res_str += "\n" + "}"
    res_str += "\n" + "\n"
    res_str += "\n" + "template {curve_name}ScalarMult(CHUNK_SIZE, CHUNK_NUMBER)".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "{"
    res_str += "\n" + "    signal input scalar[CHUNK_NUMBER];"
    res_str += "\n" + "    signal input point[2][CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    signal output out[2][CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    component n2b[CHUNK_NUMBER];"
    res_str += "\n" + "    for (var i = 0; i < CHUNK_NUMBER; i++) {"
    res_str += "\n" + "        n2b[i] = Num2Bits(CHUNK_SIZE);"
    res_str += "\n" + "        n2b[i].in <== scalar[i];"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    // has_prev_non_zero[CHUNK_SIZE * i + j] == 1 if there is a nonzero bit in location [i][j] or higher order bit"
    res_str += "\n" + "    component has_prev_non_zero[CHUNK_NUMBER * CHUNK_SIZE];"
    res_str += "\n" + "    for (var i = CHUNK_NUMBER - 1; i >= 0; i--) {"
    res_str += "\n" + "        for (var j = CHUNK_SIZE - 1; j >= 0; j--) {"
    res_str += "\n" + "            has_prev_non_zero[CHUNK_SIZE * i + j] = OR();"
    res_str += "\n" + "            if (i == CHUNK_NUMBER - 1 && j == CHUNK_SIZE - 1) {"
    res_str += "\n" + "                has_prev_non_zero[CHUNK_SIZE * i + j].a <== 0;"
    res_str += "\n" + "                has_prev_non_zero[CHUNK_SIZE * i + j].b <== n2b[i].out[j];"
    res_str += "\n" + "            } else {"
    res_str += "\n" + "                has_prev_non_zero[CHUNK_SIZE * i + j].a <== has_prev_non_zero[CHUNK_SIZE * i + j + 1].out;"
    res_str += "\n" + "                has_prev_non_zero[CHUNK_SIZE * i + j].b <== n2b[i].out[j];"
    res_str += "\n" + "            }"
    res_str += "\n" + "        }"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    signal partial[CHUNK_SIZE * CHUNK_NUMBER][2][CHUNK_NUMBER];"
    res_str += "\n" + "    signal intermed[CHUNK_SIZE * CHUNK_NUMBER - 1][2][CHUNK_NUMBER];"
    res_str += "\n" + "    component adders[CHUNK_SIZE * CHUNK_NUMBER - 1];"
    res_str += "\n" + "    component doublers[CHUNK_SIZE * CHUNK_NUMBER - 1];"
    res_str += "\n" + "    for (var i = CHUNK_NUMBER - 1; i >= 0; i--) {"
    res_str += "\n" + "        for (var j = CHUNK_SIZE - 1; j >= 0; j--) {"
    res_str += "\n" + "            if (i == CHUNK_NUMBER - 1 && j == CHUNK_SIZE - 1) {"
    res_str += "\n" + "                for (var idx = 0; idx < CHUNK_NUMBER; idx++) {"
    res_str += "\n" + "                    partial[CHUNK_SIZE * i + j][0][idx] <== point[0][idx];"
    res_str += "\n" + "                    partial[CHUNK_SIZE * i + j][1][idx] <== point[1][idx];"
    res_str += "\n" + "                }"
    res_str += "\n" + "            }"
    res_str += "\n" + "            if (i < CHUNK_NUMBER - 1 || j < CHUNK_SIZE - 1) {"
    res_str += "\n" + "                adders[CHUNK_SIZE * i + j] = {curve_name}AddUnequal(CHUNK_SIZE, CHUNK_NUMBER);".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "\n" + "                doublers[CHUNK_SIZE * i + j] = {curve_name}Double(CHUNK_SIZE, CHUNK_NUMBER);".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "\n" + "                for (var idx = 0; idx < CHUNK_NUMBER; idx++) {"
    res_str += "\n" + "                    doublers[CHUNK_SIZE * i + j].in[0][idx] <== partial[CHUNK_SIZE * i + j + 1][0][idx];"
    res_str += "\n" + "                    doublers[CHUNK_SIZE * i + j].in[1][idx] <== partial[CHUNK_SIZE * i + j + 1][1][idx];"
    res_str += "\n" + "                }"
    res_str += "\n" + "                for (var idx = 0; idx < CHUNK_NUMBER; idx++) {"
    res_str += "\n" + "                    adders[CHUNK_SIZE * i + j].point1[0][idx] <== doublers[CHUNK_SIZE * i + j].out[0][idx];"
    res_str += "\n" + "                    adders[CHUNK_SIZE * i + j].point1[1][idx] <== doublers[CHUNK_SIZE * i + j].out[1][idx];"
    res_str += "\n" + "                    adders[CHUNK_SIZE * i + j].point2[0][idx] <== point[0][idx];"
    res_str += "\n" + "                    adders[CHUNK_SIZE * i + j].point2[1][idx] <== point[1][idx];"
    res_str += "\n" + "                }"
    res_str += "\n" + "                // partial[CHUNK_SIZE * i + j]"
    res_str += "\n" + "                // = has_prev_non_zero[CHUNK_SIZE * i + j + 1] * ((1 - n2b[i].out[j]) * doublers[CHUNK_SIZE * i + j] + n2b[i].out[j] * adders[CHUNK_SIZE * i + j])"
    res_str += "\n" + "                //   + (1 - has_prev_non_zero[CHUNK_SIZE * i + j + 1]) * point"
    res_str += "\n" + "                for (var idx = 0; idx < CHUNK_NUMBER; idx++) {"
    res_str += "\n" + "                    intermed[CHUNK_SIZE * i + j][0][idx] <== n2b[i].out[j] * (adders[CHUNK_SIZE * i + j].out[0][idx] - doublers[CHUNK_SIZE * i + j].out[0][idx]) + doublers[CHUNK_SIZE * i + j].out[0][idx];"
    res_str += "\n" + "                    intermed[CHUNK_SIZE * i + j][1][idx] <== n2b[i].out[j] * (adders[CHUNK_SIZE * i + j].out[1][idx] - doublers[CHUNK_SIZE * i + j].out[1][idx]) + doublers[CHUNK_SIZE * i + j].out[1][idx];"
    res_str += "\n" + "                    partial[CHUNK_SIZE * i + j][0][idx] <== has_prev_non_zero[CHUNK_SIZE * i + j + 1].out * (intermed[CHUNK_SIZE * i + j][0][idx] - point[0][idx]) + point[0][idx];"
    res_str += "\n" + "                    partial[CHUNK_SIZE * i + j][1][idx] <== has_prev_non_zero[CHUNK_SIZE * i + j + 1].out * (intermed[CHUNK_SIZE * i + j][1][idx] - point[1][idx]) + point[1][idx];"
    res_str += "\n" + "                }"
    res_str += "\n" + "            }"
    res_str += "\n" + "        }"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    for (var idx = 0; idx < CHUNK_NUMBER; idx++) {"
    res_str += "\n" + "        out[0][idx] <== partial[0][0][idx];"
    res_str += "\n" + "        out[1][idx] <== partial[0][1][idx];"
    res_str += "\n" + "    }"
    res_str += "\n" + "}"
    res_str += "\n" + "\n"
    res_str += "\n" + "template Get{curve_name}Order(CHUNK_SIZE, CHUNK_NUMBER)".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "{"
    res_str += "\n" + "    assert((CHUNK_SIZE == {n}) && (CHUNK_NUMBER == {k}));".format(n=n, k=k)
    res_str += "\n" + "    signal output order[{k}];".format(k=k)

    order = bigint_to_array(n, k, N)

    for i in range(0 , k):
        res_str += "\n" + "    order[{i}] <== {tmp};".format(i=i, tmp = order[i])

    res_str += "\n" + "}"
    res_str += "\n" + "\n"
    res_str += "\n" + "template Get{curve_name}Generator(CHUNK_SIZE,CHUNK_NUMBER)".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "{"
    res_str += "\n" + "    assert((CHUNK_SIZE == {n}) && (CHUNK_NUMBER == {k}));".format(n=n, k=k)
    res_str += "\n" + "    signal output generator[2][{k}];".format(k=k)
    res_str += "\n" + "\n"

    gen_x = bigint_to_array(n,k,Gx)
    gen_y = bigint_to_array(n,k,Gy)
    for i in range(0, k):
        res_str += "\n" + "    generator[0][{i}] <== {tmp};".format(i=i, tmp = gen_x[i])

    for i in range(0, k):
        res_str += "\n" + "    generator[1][{i}] <== {tmp};".format(i=i, tmp = gen_y[i])
        



    res_str += "\n" + "}"
    res_str += "\n" + "\n"
    res_str += "\n" + "template {curve_name}GeneratorMultiplication(CHUNK_SIZE,CHUNK_NUMBER)".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "{"
    res_str += "\n" + "    var STRIDE = 8;"
    res_str += "\n" + "    signal input scalar[CHUNK_NUMBER];"
    res_str += "\n" + "    signal output out[2][CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    component n2b[CHUNK_NUMBER];"
    res_str += "\n" + "    for (var i = 0; i < CHUNK_NUMBER; i++) {"
    res_str += "\n" + "        n2b[i] = Num2Bits(CHUNK_SIZE);"
    res_str += "\n" + "        n2b[i].in <== scalar[i];"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    var NUM_STRIDES = div_ceil(CHUNK_SIZE * CHUNK_NUMBER, STRIDE);"
    res_str += "\n" + "    // power[i][j] contains: [j * (1 << STRIDE * i) * G] for 1 <= j < (1 << STRIDE)"
    res_str += "\n" + "    var POWERS[NUM_STRIDES][2 ** STRIDE][2][CHUNK_NUMBER];"
    res_str += "\n" + "    POWERS = get_g_pow_stride8_table(CHUNK_SIZE, CHUNK_NUMBER);"
    res_str += "\n" + "\n"
    res_str += "\n" + "    var dummyHolder[2][CHUNK_NUMBER] = get_{curve_name}_dummy_point(CHUNK_SIZE, CHUNK_NUMBER);".format(curve_name = curve_name)
    res_str += "\n" + "    var dummy[2][CHUNK_NUMBER];"
    res_str += "\n" + "    for (var i = 0; i < CHUNK_NUMBER; i++) dummy[0][i] = dummyHolder[0][i];"
    res_str += "\n" + "    for (var i = 0; i < CHUNK_NUMBER; i++) dummy[1][i] = dummyHolder[1][i];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    component selectors[NUM_STRIDES];"
    res_str += "\n" + "    for (var i = 0; i < NUM_STRIDES; i++) {"
    res_str += "\n" + "        selectors[i] = Bits2Num(STRIDE);"
    res_str += "\n" + "        for (var j = 0; j < STRIDE; j++) {"
    res_str += "\n" + "            var bit_idx1 = (i * STRIDE + j) \\ CHUNK_SIZE;"
    res_str += "\n" + "            var bit_idx2 = (i * STRIDE + j) % CHUNK_SIZE;"
    res_str += "\n" + "            if (bit_idx1 < CHUNK_NUMBER) {"
    res_str += "\n" + "                selectors[i].in[j] <== n2b[bit_idx1].out[bit_idx2];"
    res_str += "\n" + "            } else {"
    res_str += "\n" + "                selectors[i].in[j] <== 0;"
    res_str += "\n" + "            }"
    res_str += "\n" + "        }"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    // multiplexers[i][l].out will be the coordinates of:"
    res_str += "\n" + "    // selectors[i].out * (2 ** (i * STRIDE)) * G    if selectors[i].out is non-zero"
    res_str += "\n" + "    // (2 ** 255) * G                                if selectors[i].out is zero"
    res_str += "\n" + "    component multiplexers[NUM_STRIDES][2];"
    res_str += "\n" + "    // select from CHUNK_NUMBER-register outputs using a 2 ** STRIDE bit selector"
    res_str += "\n" + "    for (var i = 0; i < NUM_STRIDES; i++) {"
    res_str += "\n" + "        for (var l = 0; l < 2; l++) {"
    res_str += "\n" + "            multiplexers[i][l] = Multiplexer(CHUNK_NUMBER, (1 << STRIDE));"
    res_str += "\n" + "            multiplexers[i][l].sel <== selectors[i].out;"
    res_str += "\n" + "            for (var idx = 0; idx < CHUNK_NUMBER; idx++) {"
    res_str += "\n" + "                multiplexers[i][l].inp[0][idx] <== dummy[l][idx];"
    res_str += "\n" + "                for (var j = 1; j < (1 << STRIDE); j++) {"
    res_str += "\n" + "                    multiplexers[i][l].inp[j][idx] <== POWERS[i][j][l][idx];"
    res_str += "\n" + "                }"
    res_str += "\n" + "            }"
    res_str += "\n" + "        }"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    component isZero[NUM_STRIDES];"
    res_str += "\n" + "    for (var i = 0; i < NUM_STRIDES; i++) {"
    res_str += "\n" + "        isZero[i] = IsZero();"
    res_str += "\n" + "        isZero[i].in <== selectors[i].out;"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    // hasPrevNonZero[i] = 1 if at least one of the selections in privkey up to STRIDE i is non-zero"
    res_str += "\n" + "    component hasPrevNonZero[NUM_STRIDES];"
    res_str += "\n" + "    hasPrevNonZero[0] = OR();"
    res_str += "\n" + "    hasPrevNonZero[0].a <== 0;"
    res_str += "\n" + "    hasPrevNonZero[0].b <== 1 - isZero[0].out;"
    res_str += "\n" + "    for (var i = 1; i < NUM_STRIDES; i++) {"
    res_str += "\n" + "        hasPrevNonZero[i] = OR();"
    res_str += "\n" + "        hasPrevNonZero[i].a <== hasPrevNonZero[i - 1].out;"
    res_str += "\n" + "        hasPrevNonZero[i].b <== 1 - isZero[i].out;"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    signal partial[NUM_STRIDES][2][CHUNK_NUMBER];"
    res_str += "\n" + "    for (var idx = 0; idx < CHUNK_NUMBER; idx++) {"
    res_str += "\n" + "        for (var l = 0; l < 2; l++) {"
    res_str += "\n" + "            partial[0][l][idx] <== multiplexers[0][l].out[idx];"
    res_str += "\n" + "        }"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    component adders[NUM_STRIDES - 1];"
    res_str += "\n" + "    signal intermed1[NUM_STRIDES - 1][2][CHUNK_NUMBER];"
    res_str += "\n" + "    signal intermed2[NUM_STRIDES - 1][2][CHUNK_NUMBER];"
    res_str += "\n" + "    for (var i = 1; i < NUM_STRIDES; i++) {"
    res_str += "\n" + "        adders[i - 1] = {curve_name}AddUnequal(CHUNK_SIZE, CHUNK_NUMBER);".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "\n" + "        for (var idx = 0; idx < CHUNK_NUMBER; idx++) {"
    res_str += "\n" + "            for (var l = 0; l < 2; l++) {"
    res_str += "\n" + "                adders[i - 1].point1[l][idx] <== partial[i - 1][l][idx];"
    res_str += "\n" + "                adders[i - 1].point2[l][idx] <== multiplexers[i][l].out[idx];"
    res_str += "\n" + "            }"
    res_str += "\n" + "        }"
    res_str += "\n" + "\n"
    res_str += "\n" + "        // partial[i] = hasPrevNonZero[i - 1] * ((1 - isZero[i]) * adders[i - 1].out + isZero[i] * partial[i - 1][0][idx])"
    res_str += "\n" + "        //              + (1 - hasPrevNonZero[i - 1]) * (1 - isZero[i]) * multiplexers[i]"
    res_str += "\n" + "        for (var idx = 0; idx < CHUNK_NUMBER; idx++) {"
    res_str += "\n" + "            for (var l = 0; l < 2; l++) {"
    res_str += "\n" + "                intermed1[i - 1][l][idx] <== isZero[i].out * (partial[i - 1][l][idx] - adders[i - 1].out[l][idx]) + adders[i - 1].out[l][idx];"
    res_str += "\n" + "                intermed2[i - 1][l][idx] <== multiplexers[i][l].out[idx] - isZero[i].out * multiplexers[i][l].out[idx];"
    res_str += "\n" + "                partial[i][l][idx] <== hasPrevNonZero[i - 1].out * (intermed1[i - 1][l][idx] - intermed2[i - 1][l][idx]) + intermed2[i - 1][l][idx];"
    res_str += "\n" + "            }"
    res_str += "\n" + "        }"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    for (var i = 0; i < CHUNK_NUMBER; i++) {"
    res_str += "\n" + "        for (var l = 0; l < 2; l++) {"
    res_str += "\n" + "            out[l][i] <== partial[NUM_STRIDES - 1][l][i];"
    res_str += "\n" + "        }"
    res_str += "\n" + "    }"
    res_str += "\n" + "}"
    res_str += "\n" + "\n"
    res_str += "\n" + "template {curve_name}PrecomputePipinger(CHUNK_SIZE, CHUNK_NUMBER, WINDOW_SIZE)".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "{"
    res_str += "\n" + "    signal input in[2][CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    var PRECOMPUTE_NUMBER = 2 ** WINDOW_SIZE; "
    res_str += "\n" + "\n"
    res_str += "\n" + "    signal output out[PRECOMPUTE_NUMBER][2][CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    for (var i = 0; i < 2; i++){"
    res_str += "\n" + "        for (var j = 0; j < CHUNK_NUMBER; j++){"
    res_str += "\n" + "            out[0][i][j] <== 0;"
    res_str += "\n" + "        }"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    out[1] <== in;"
    res_str += "\n" + "\n"
    res_str += "\n" + "    component doublers[PRECOMPUTE_NUMBER\\2 - 1];"
    res_str += "\n" + "    component adders  [PRECOMPUTE_NUMBER\\2 - 1];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    for (var i = 2; i < PRECOMPUTE_NUMBER; i++){"
    res_str += "\n" + "        if (i % 2 == 0){"
    res_str += "\n" + "            doublers[i\\2 - 1]     = {curve_name}Double(CHUNK_SIZE, CHUNK_NUMBER);".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "\n" + "            doublers[i\\2 - 1].in  <== out[i\\2];"
    res_str += "\n" + "            doublers[i\\2 - 1].out ==> out[i];"
    res_str += "\n" + "        }"
    res_str += "\n" + "        else"
    res_str += "\n" + "        {"
    res_str += "\n" + "            adders[i\\2 - 1]          = {curve_name}AddUnequal(CHUNK_SIZE, CHUNK_NUMBER);".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "\n" + "            adders[i\\2 - 1].point1   <== out[1];"
    res_str += "\n" + "            adders[i\\2 - 1].point2   <== out[i - 1];"
    res_str += "\n" + "            adders[i\\2 - 1].out      ==> out[i]; "
    res_str += "\n" + "        }"
    res_str += "\n" + "    }"
    res_str += "\n" + "}"
    res_str += "\n" + "\n"
    res_str += "\n" + "template {curve_name}PipingerMult(CHUNK_SIZE, CHUNK_NUMBER, WINDOW_SIZE)".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "{"
    res_str += "\n" + "\n"
    res_str += "\n" + "    assert(WINDOW_SIZE == 4);"
    res_str += "\n" + "\n"
    res_str += "\n" + "    signal input  point[2][CHUNK_NUMBER];"
    res_str += "\n" + "    signal input  scalar  [CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    signal output out[2][CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    var PRECOMPUTE_NUMBER = 2 ** WINDOW_SIZE;"
    res_str += "\n" + "\n"
    res_str += "\n" + "    signal precomputed[PRECOMPUTE_NUMBER][2][CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    component precompute = {curve_name}PrecomputePipinger(CHUNK_SIZE, CHUNK_NUMBER, WINDOW_SIZE);".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "\n" + "    precompute.in  <== point;"
    res_str += "\n" + "    precompute.out ==> precomputed;"
    res_str += "\n" + "\n"
    res_str += "\n" + "    var DOUBLERS_NUMBER = {curve_field} - WINDOW_SIZE;".format(curve_field = curve_field)
    res_str += "\n" + "    var ADDERS_NUMBER   = {curve_field} \\ WINDOW_SIZE;".format(curve_field = curve_field)
    res_str += "\n" + "\n"
    res_str += "\n" + "    component doublers[DOUBLERS_NUMBER];"
    res_str += "\n" + "    component adders  [ADDERS_NUMBER];"
    res_str += "\n" + "    component bits2Num[ADDERS_NUMBER];"
    res_str += "\n" + "    component num2Bits[CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    signal res [ADDERS_NUMBER + 1][2][CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    signal tmp [ADDERS_NUMBER][PRECOMPUTE_NUMBER][2][CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    signal tmp2[ADDERS_NUMBER]    [2]   [CHUNK_NUMBER];"
    res_str += "\n" + "    signal tmp3[ADDERS_NUMBER]    [2][2][CHUNK_NUMBER];"
    res_str += "\n" + "    signal tmp4[ADDERS_NUMBER]    [2]   [CHUNK_NUMBER];"
    res_str += "\n" + "    signal tmp5[ADDERS_NUMBER]    [2][2][CHUNK_NUMBER];"
    res_str += "\n" + "    signal tmp6[ADDERS_NUMBER - 1][2][2][CHUNK_NUMBER];"
    res_str += "\n" + "    signal tmp7[ADDERS_NUMBER - 1][2]   [CHUNK_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    component equals    [ADDERS_NUMBER][PRECOMPUTE_NUMBER][2][CHUNK_NUMBER];"
    res_str += "\n" + "    component zeroEquals[ADDERS_NUMBER];"
    res_str += "\n" + "    component tmpEquals [ADDERS_NUMBER];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    component g = Get{curve_name}Generator(CHUNK_SIZE, CHUNK_NUMBER);".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "\n" + "    signal gen[2][CHUNK_NUMBER];"
    res_str += "\n" + "    gen <== g.generator;"
    res_str += "\n" + "\n"
    res_str += "\n" + "    signal scalarBits[{curve_field}];".format(curve_field = curve_field)
    res_str += "\n" + "\n"
    res_str += "\n" + "    for (var i = 0; i < CHUNK_NUMBER; i++){"
    res_str += "\n" + "        num2Bits[i] = Num2Bits(CHUNK_SIZE);"
    res_str += "\n" + "        num2Bits[i].in <== scalar[i];"
    res_str += "\n" + "        if (i != CHUNK_NUMBER - 1){"
    res_str += "\n" + "            for (var j = 0; j < CHUNK_SIZE; j++){"
    res_str += "\n" + "                scalarBits[{curve_field} - CHUNK_SIZE * (i + 1) + j] <== num2Bits[i].out[CHUNK_SIZE - 1 - j];".format(curve_field = curve_field)
    res_str += "\n" + "            }"
    res_str += "\n" + "        } else {"
    res_str += "\n" + "            for (var j = 0; j < CHUNK_SIZE - (CHUNK_SIZE*CHUNK_NUMBER - {curve_field}); j++)".format(curve_field = curve_field)
    res_str += "{"
    res_str += "\n" + "                scalarBits[j] <== num2Bits[i].out[CHUNK_SIZE - 1 - (j + (CHUNK_SIZE * CHUNK_NUMBER - {curve_field}))];".format(curve_field = curve_field)
    res_str += "\n" + "            }"
    res_str += "\n" + "        }"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    res[0] <== precomputed[0];"
    res_str += "\n" + "\n"
    res_str += "\n" + "    for (var i = 0; i < {curve_field}; i += WINDOW_SIZE)".format(curve_field = curve_field)
    res_str += "{"
    res_str += "\n" + "        adders[i\\WINDOW_SIZE] = {curve_name}AddUnequal(CHUNK_SIZE, CHUNK_NUMBER);".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "\n" + "        bits2Num[i\\WINDOW_SIZE] = Bits2Num(WINDOW_SIZE);"
    res_str += "\n" + "        for (var j = 0; j < WINDOW_SIZE; j++){"
    res_str += "\n" + "            bits2Num[i\\WINDOW_SIZE].in[j] <== scalarBits[i + (WINDOW_SIZE - 1) - j];"
    res_str += "\n" + "        }"
    res_str += "\n" + "\n"
    res_str += "\n" + "        tmpEquals[i\\WINDOW_SIZE] = IsEqual();"
    res_str += "\n" + "        tmpEquals[i\\WINDOW_SIZE].in[0] <== 0;"
    res_str += "\n" + "        tmpEquals[i\\WINDOW_SIZE].in[1] <== res[i\\WINDOW_SIZE][0][0];"
    res_str += "\n" + "\n"
    res_str += "\n" + "        if (i != 0){"
    res_str += "\n" + "            for (var j = 0; j < WINDOW_SIZE; j++){"
    res_str += "\n" + "                doublers[i + j - WINDOW_SIZE] = {curve_name}Double(CHUNK_SIZE, CHUNK_NUMBER);".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "\n" + "\n"
    res_str += "\n" + "                if (j == 0){"
    res_str += "\n" + "                    for (var axis_idx = 0; axis_idx < 2; axis_idx++){"
    res_str += "\n" + "                        for (var coor_idx = 0; coor_idx < CHUNK_NUMBER; coor_idx ++){"
    res_str += "\n" + "                            tmp6[i\\WINDOW_SIZE - 1][0][axis_idx][coor_idx] <==      tmpEquals[i\\WINDOW_SIZE].out  * gen[axis_idx][coor_idx];"
    res_str += "\n" + "                            tmp6[i\\WINDOW_SIZE - 1][1][axis_idx][coor_idx] <== (1 - tmpEquals[i\\WINDOW_SIZE].out) * res[i\\WINDOW_SIZE][axis_idx][coor_idx];"
    res_str += "\n" + "                            tmp7[i\\WINDOW_SIZE - 1]   [axis_idx][coor_idx] <== tmp6[i\\WINDOW_SIZE - 1][0][axis_idx][coor_idx] "
    res_str += "\n" + "                                                                             + tmp6[i\\WINDOW_SIZE - 1][1][axis_idx][coor_idx];"
    res_str += "\n" + "                        }"
    res_str += "\n" + "                    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "                    doublers[i + j - WINDOW_SIZE].in <== tmp7[i\\WINDOW_SIZE - 1];"
    res_str += "\n" + "                }"
    res_str += "\n" + "                else"
    res_str += "\n" + "                {"
    res_str += "\n" + "                    doublers[i + j - WINDOW_SIZE].in <== doublers[i + j - 1 - WINDOW_SIZE].out;"
    res_str += "\n" + "                }"
    res_str += "\n" + "            }"
    res_str += "\n" + "        }"
    res_str += "\n" + "\n"
    res_str += "\n" + "       for (var point_idx = 0; point_idx < PRECOMPUTE_NUMBER; point_idx++){"
    res_str += "\n" + "            for (var axis_idx = 0; axis_idx < 2; axis_idx++){"
    res_str += "\n" + "                for (var coor_idx = 0; coor_idx < CHUNK_NUMBER; coor_idx++){"
    res_str += "\n" + "                    equals[i\\WINDOW_SIZE][point_idx][axis_idx][coor_idx]       = IsEqual();"
    res_str += "\n" + "                    equals[i\\WINDOW_SIZE][point_idx][axis_idx][coor_idx].in[0] <== point_idx;"
    res_str += "\n" + "                    equals[i\\WINDOW_SIZE][point_idx][axis_idx][coor_idx].in[1] <== bits2Num[i\\WINDOW_SIZE].out;"
    res_str += "\n" + "                    tmp   [i\\WINDOW_SIZE][point_idx][axis_idx][coor_idx]       <== precomputed[point_idx][axis_idx][coor_idx] * "
    res_str += "\n" + "                                                                         equals[i\\WINDOW_SIZE][point_idx][axis_idx][coor_idx].out;"
    res_str += "\n" + "                }"
    res_str += "\n" + "            }"
    res_str += "\n" + "        }"
    res_str += "\n" + "\n"
    res_str += "\n" + "        for (var axis_idx = 0; axis_idx < 2; axis_idx++){"
    res_str += "\n" + "            for (var coor_idx = 0; coor_idx < CHUNK_NUMBER; coor_idx++){"
    res_str += "\n" + "                tmp2[i\\WINDOW_SIZE]   [axis_idx][coor_idx] <== "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][0] [axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][1] [axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][2] [axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][3] [axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][4] [axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][5] [axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][6] [axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][7] [axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][8] [axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][9] [axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][10][axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][11][axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][12][axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][13][axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][14][axis_idx][coor_idx] + "
    res_str += "\n" + "                tmp[i\\WINDOW_SIZE][15][axis_idx][coor_idx];"
    res_str += "\n" + "            }"
    res_str += "\n" + "        }"
    res_str += "\n" + "\n"
    res_str += "\n" + "        if (i == 0){"
    res_str += "\n" + "\n"
    res_str += "\n" + "            adders[i\\WINDOW_SIZE].point1 <== res [i\\WINDOW_SIZE];"
    res_str += "\n" + "            adders[i\\WINDOW_SIZE].point2 <== tmp2[i\\WINDOW_SIZE];"
    res_str += "\n" + "            res[i\\WINDOW_SIZE + 1]       <== tmp2[i\\WINDOW_SIZE];"
    res_str += "\n" + "\n"
    res_str += "\n" + "        } else {"
    res_str += "\n" + "\n"
    res_str += "\n" + "            adders[i\\WINDOW_SIZE].point1 <== doublers[i - 1].out;"
    res_str += "\n" + "            adders[i\\WINDOW_SIZE].point2 <== tmp2[i\\WINDOW_SIZE];"
    res_str += "\n" + "\n"
    res_str += "\n" + "            zeroEquals[i\\WINDOW_SIZE] = IsEqual();"
    res_str += "\n" + "\n"
    res_str += "\n" + "            zeroEquals[i\\WINDOW_SIZE].in[0]<== 0;"
    res_str += "\n" + "            zeroEquals[i\\WINDOW_SIZE].in[1]<== tmp2[i\\WINDOW_SIZE][0][0];"
    res_str += "\n" + "\n"
    res_str += "\n" + "            for (var axis_idx = 0; axis_idx < 2; axis_idx++){"
    res_str += "\n" + "                for(var coor_idx = 0; coor_idx < CHUNK_NUMBER; coor_idx++){"
    res_str += "\n" + "\n"
    res_str += "\n" + "                    tmp3[i\\WINDOW_SIZE][0][axis_idx][coor_idx] <== adders    [i\\WINDOW_SIZE].out[axis_idx][coor_idx] * (1 - zeroEquals[i\\WINDOW_SIZE].out);"
    res_str += "\n" + "                    tmp3[i\\WINDOW_SIZE][1][axis_idx][coor_idx] <== zeroEquals[i\\WINDOW_SIZE].out                     * doublers[i-1].out[axis_idx][coor_idx];"
    res_str += "\n" + "                    tmp4[i\\WINDOW_SIZE]   [axis_idx][coor_idx] <== tmp3[i\\WINDOW_SIZE][0][axis_idx][coor_idx]        + tmp3[i\\WINDOW_SIZE][1][axis_idx][coor_idx]; "
    res_str += "\n" + "                    tmp5[i\\WINDOW_SIZE][0][axis_idx][coor_idx] <== (1 - tmpEquals[i\\WINDOW_SIZE].out)                * tmp4[i\\WINDOW_SIZE]   [axis_idx][coor_idx];"
    res_str += "\n" + "                    tmp5[i\\WINDOW_SIZE][1][axis_idx][coor_idx] <== tmpEquals[i\\WINDOW_SIZE].out                      * tmp2[i\\WINDOW_SIZE]   [axis_idx][coor_idx];"
    res_str += "\n" + "\n"
    res_str += "\n" + "                    res[i\\WINDOW_SIZE + 1][axis_idx][coor_idx] <== tmp5[i\\WINDOW_SIZE][0][axis_idx][coor_idx] + tmp5[i\\WINDOW_SIZE][1][axis_idx][coor_idx];"
    res_str += "\n" + "                }"
    res_str += "\n" + "            }"
    res_str += "\n" + "        }"
    res_str += "\n" + "    }"
    res_str += "\n" + "\n"
    res_str += "\n" + "    out <== res[ADDERS_NUMBER];"
    res_str += "\n" + "}"
    res_str += "\n" + "\n"

    return res_str


def get_signature_str(n,k, curve_name, curve_field):

    delta = n*k - curve_field

    res_str = ""

    res_str += "pragma circom 2.1.6;\n"
    res_str += "\n"
    res_str += "include \"{curve_name}.circom\";\n".format(curve_name = curve_name)
    res_str += "include \"{curve_name}Func.circom\";\n".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "include \"../../../../node_modules/circomlib/circuits/bitify.circom\";\n"
    res_str += "include \"../../../../circuits/ecdsa/utils/func.circom\";\n"
    res_str += "\n"
    res_str += "template verify{curve_name}(CHUNK_SIZE, CHUNK_NUMBER, ALGO)\n".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "{\n"
    res_str += "    signal input pubkey[2 * {curve_field}];\n".format(curve_field = curve_field)
    res_str += "    signal input signature[2 * {curve_field}];\n".format(curve_field = curve_field)
    res_str += "    signal input hashed[ALGO];\n"
    res_str += "\n"
    res_str += "    signal pubkeyChunked[2][CHUNK_NUMBER];\n"
    res_str += "    signal signatureChunked[2][CHUNK_NUMBER];\n"
    res_str += "\n"
    res_str += "    signal pubkeyBits[2][CHUNK_SIZE * CHUNK_NUMBER];\n"
    res_str += "    signal signatureBits[2][CHUNK_SIZE * CHUNK_NUMBER];\n"

    for i in range(0, delta):
        res_str += "    pubkeyBits[0][{i}] <== 0;\n".format(i=i)
        res_str += "    pubkeyBits[1][{i}] <== 0;\n".format(i=i)
        res_str += "    signatureBits[0][{i}] <== 0;\n".format(i=i)
        res_str += "    signatureBits[1][{i}] <== 0;\n".format(i=i)


    res_str += "\n"
    res_str += "    for (var i = 0; i < 2; i++){\n"
    res_str += "        for (var j = 0; j < {curve_field}; j++)".format(curve_field = curve_field)
    res_str += "{\n"
    res_str += "            pubkeyBits[i][j+{delta}] <== pubkey[i*{curve_field} + j];\n".format(curve_field = curve_field, delta = delta)
    res_str += "            signatureBits[i][j+{delta}] <== signature[i*{curve_field} +j];\n".format(curve_field = curve_field, delta = delta)
    res_str += "        }\n"
    res_str += "    }\n"
    res_str += "\n"
    res_str += "    component bits2NumInput[2*2*CHUNK_NUMBER];\n"
    res_str += "\n"
    res_str += "    for (var i = 0; i < 2; i++){\n"
    res_str += "        for (var j = 0; j < CHUNK_NUMBER; j++){\n"
    res_str += "            bits2NumInput[i*CHUNK_NUMBER+j] = Bits2Num(CHUNK_SIZE);\n"
    res_str += "            bits2NumInput[(i+2)*CHUNK_NUMBER+j] = Bits2Num(CHUNK_SIZE);\n"
    res_str += "\n"
    res_str += "            for (var z = 0; z < CHUNK_SIZE; z++){\n"
    res_str += "                bits2NumInput[i*CHUNK_NUMBER+j].in[z] <== pubkeyBits[i][CHUNK_SIZE * j + CHUNK_SIZE - 1  - z];\n"
    res_str += "                bits2NumInput[(i+2)*CHUNK_NUMBER+j].in[z] <== signatureBits[i][CHUNK_SIZE * j + CHUNK_SIZE - 1 - z];\n"
    res_str += "            }\n"
    res_str += "            bits2NumInput[i*CHUNK_NUMBER+j].out ==> pubkeyChunked[i][CHUNK_NUMBER - 1 - j];\n"
    res_str += "            bits2NumInput[(i+2)*CHUNK_NUMBER+j].out ==> signatureChunked[i][CHUNK_NUMBER - 1 - j];\n"
    res_str += "        }\n"
    res_str += "    }\n"
    res_str += "\n"
    res_str += "\n"
    res_str += "    signal hashedMessageBits[CHUNK_SIZE * CHUNK_NUMBER];\n"
    res_str += "    hashedMessageBits[0] <== 0;\n"
    res_str += "    hashedMessageBits[1] <== 0;\n"
    res_str += "    for (var i = 0; i < ALGO; i++){\n"
    res_str += "        hashedMessageBits[i+{delta}] <== hashed[i];\n".format(delta = delta)
    res_str += "    }\n"
    res_str += "\n"
    res_str += "\n"
    res_str += "    signal hashedMessageChunked[CHUNK_NUMBER];\n"
    res_str += "\n"
    res_str += "    component bits2Num[CHUNK_NUMBER];\n"
    res_str += "    for (var i = 0; i < CHUNK_NUMBER; i++) {\n"
    res_str += "        bits2Num[i] = Bits2Num(CHUNK_SIZE);\n"
    res_str += "        for (var j = 0; j < CHUNK_SIZE; j++) {\n"
    res_str += "            bits2Num[i].in[CHUNK_SIZE-1-j] <== hashedMessageBits[i*CHUNK_SIZE+j];\n"
    res_str += "        }\n"
    res_str += "        hashedMessageChunked[CHUNK_NUMBER-1-i] <== bits2Num[i].out;\n"
    res_str += "    }\n"
    res_str += "\n"
    res_str += "    component getOrder = Get{curve_name}Order(CHUNK_SIZE,CHUNK_NUMBER);\n".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "    signal order[CHUNK_NUMBER];\n"
    res_str += "    order <== getOrder.order;\n"
    res_str += "\n"
    res_str += "    signal sinv[CHUNK_NUMBER];\n"
    res_str += "\n"
    res_str += "    component modInv = BigModInv(CHUNK_SIZE,CHUNK_NUMBER);\n"
    res_str += "\n"
    res_str += "    modInv.in <== signatureChunked[1];\n"
    res_str += "    modInv.p <== order;\n"
    res_str += "    modInv.out ==> sinv;\n"
    res_str += "\n"
    res_str += "    signal sh[CHUNK_NUMBER];\n"
    res_str += "\n"
    res_str += "    component mult = BigMultModP(CHUNK_SIZE,CHUNK_NUMBER);\n"
    res_str += "\n"
    res_str += "    mult.a <== sinv;\n"
    res_str += "    mult.b <== hashedMessageChunked;\n"
    res_str += "    mult.p <== order;\n"
    res_str += "    sh <== mult.out;\n"
    res_str += "\n"
    res_str += "\n"
    res_str += "    signal sr[CHUNK_NUMBER];\n"
    res_str += "\n"
    res_str += "    component mult2 = BigMultModP(CHUNK_SIZE,CHUNK_NUMBER);\n"
    res_str += "\n"
    res_str += "    mult2.a <== sinv;\n"
    res_str += "    mult2.b <== signatureChunked[0];\n"
    res_str += "    mult2.p <== order;\n"
    res_str += "    sr <== mult2.out;\n"
    res_str += "\n"
    res_str += "    signal tmpPoint1[2][CHUNK_NUMBER];\n"
    res_str += "    signal tmpPoint2[2][CHUNK_NUMBER];\n"
    res_str += "\n"
    res_str += "    component scalarMult1 = {curve_name}GeneratorMultiplication(CHUNK_SIZE,CHUNK_NUMBER);\n".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "    component scalarMult2 = {curve_name}PipingerMult(CHUNK_SIZE,CHUNK_NUMBER,4);\n".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "\n"
    res_str += "    scalarMult1.scalar <== sh;\n"
    res_str += "\n"
    res_str += "    tmpPoint1 <== scalarMult1.out;\n"
    res_str += "\n"
    res_str += "    scalarMult2.scalar <== sr;\n"
    res_str += "    scalarMult2.point <== pubkeyChunked;\n"
    res_str += "\n"
    res_str += "    tmpPoint2 <== scalarMult2.out;\n"
    res_str += "\n"
    res_str += "    signal verifyX[CHUNK_NUMBER];\n"
    res_str += "\n"
    res_str += "    component sumPoints = {curve_name}AddUnequal(CHUNK_SIZE,CHUNK_NUMBER);\n".format(curve_name = str.upper(curve_name[0]) + curve_name[1:])
    res_str += "\n"
    res_str += "    sumPoints.point1 <== tmpPoint1;\n"
    res_str += "    sumPoints.point2 <== tmpPoint2;\n"
    res_str += "    verifyX <== sumPoints.out[0];\n"
    res_str += "\n"
    res_str += "    verifyX === signatureChunked[0];\n"
    res_str += "}\n"

    return res_str

def write_pows(n, k, curve_name):
    stride_list = [8]
    ecdsa_func_str = get_ecdsa_func_str(n, k, stride_list)
    f = open('tests/tests/circuits/testCurve/{curve_name}Pows.circom'.format(curve_name = curve_name, n = n, k = k), 'w')


    orig_stdout = sys.stdout
    sys.stdout = f

    print(ecdsa_func_str)


def write_func(n, k, curve_name):

    ecdsa_func_str = get_func_str(n, k, curve_name)
    f = open('tests/tests/circuits/testCurve/{curve_name}Func.circom'.format(curve_name = curve_name), 'w')

    orig_stdout = sys.stdout
    sys.stdout = f
    print(ecdsa_func_str)

def write_curve(n,k,curve_name, curve_field):
    ecdsa_str = get_curve(n, k, curve_name, curve_field)
    f = open('tests/tests/circuits/testCurve/{curve_name}.circom'.format(curve_name = curve_name), 'w')

    orig_stdout = sys.stdout
    sys.stdout = f
    print(ecdsa_str)

def write_signature(n,k,curve_name, curve_field):
    ecdsa_str = get_signature_str(n, k, curve_name, curve_field)
    f = open('tests/tests/circuits/testCurve/signatureVerification.circom', 'w')

    orig_stdout = sys.stdout
    sys.stdout = f
    print(ecdsa_str)


def write_main(n,k,curve_name,algo):
    res_str = ""
    res_str += "pragma circom 2.1.6;\n\n"
    res_str += "include \"./signatureVerification.circom\";\n\n"
    res_str += "component main = Verify{curve_name}({n}, {k}, {algo})"
   
    f = open('tests/tests/circuits/testCurve/test_curve.circom', 'w')

    orig_stdout = sys.stdout
    sys.stdout = f
    print(res_str)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Decode a base64 encoded passport file.')
    parser.add_argument('n', type=int, help='n')
    parser.add_argument('k', type=int, help='k')
    parser.add_argument('curve_name', type=str, help='Curve name')
    parser.add_argument('curve_field', type=int, help='Curve field size')
    parser.add_argument('algo', type=int, help='Message hash algo')
    args = parser.parse_args()

    write_pows(args.n, args.k, args.curve_name)
    write_func(args.n,args.k,args.curve_name)
    write_curve(args.n,args.k,args.curve_name, args.curve_field)
    write_signature(args.n,args.k,args.curve_name, args.curve_field)
    write_main(args.n,args.k,args.curve_name, args.algo)
    

   