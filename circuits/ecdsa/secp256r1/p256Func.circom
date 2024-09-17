pragma circom 2.1.5;

function get_p256_order(CHUNK_SIZE, CHUNK_NUMBER) {
    assert((CHUNK_SIZE == 43) && (CHUNK_NUMBER == 6));
    var ORDER[6];

    if (CHUNK_SIZE == 43 && CHUNK_NUMBER == 6) {
        ORDER[0] = 3036481267025;
        ORDER[1] = 3246200354617;
        ORDER[2] = 7643362670236;
        ORDER[3] = 8796093022207;
        ORDER[4] = 1048575;
        ORDER[5] = 2199023255040;
    }
    return ORDER;
}

function get_p256_params(CHUNK_SIZE,CHUNK_NUMBER){
    assert((CHUNK_SIZE == 43) && (CHUNK_NUMBER == 6));
     
    var A[6];
    var P[6];
    var B[6];

    var PARAMS[3][6];

    P[0] = 8796093022207;
    P[1] = 8796093022207;
    P[2] = 1023;
    P[3] = 0;
    P[4] = 1048576;
    P[5] = 2199023255040;
    A[0] = 8796093022204;
    A[1] = 8796093022207;
    A[2] = 1023;
    A[3] = 0;
    A[4] = 1048576;
    A[5] = 2199023255040;
    B[0] = 4665002582091;
    B[1] = 2706345785799;
    B[2] = 1737114698545;
    B[3] = 7330356544350;
    B[4] = 4025432620731;
    B[5] = 779744948564;

    PARAMS[0] = A;
    PARAMS[1] = B;
    PARAMS[2] = P;
    
    return PARAMS;
}

function get_p256_dummy_point(CHUNK_SIZE, CHUNK_NUMBER) {
    assert((CHUNK_SIZE == 43) && (CHUNK_NUMBER == 6));

    var DUMMY[2][6]; 

    DUMMY[0][0] = 5013155818324;
    DUMMY[0][1] = 5653956830653;
    DUMMY[0][2] = 1357089440655;
    DUMMY[0][3] = 4985459479134;
    DUMMY[0][4] = 7362399503982;
    DUMMY[0][5] = 1028176290396;
    DUMMY[1][0] = 2185447106559;
    DUMMY[1][1] = 2319789413632;
    DUMMY[1][2] = 3837703653281;
    DUMMY[1][3] = 6590333830457;
    DUMMY[1][4] = 5404134177552;
    DUMMY[1][5] = 1407546699851;

    return DUMMY;
}

function div_ceil2(m, CHUNK_SIZE) {
    var ret = 0;
    if (m % CHUNK_SIZE == 0) {
        ret = m \ CHUNK_SIZE;
    } else {
        ret = m \ CHUNK_SIZE + 1;
    }
    return ret;
}