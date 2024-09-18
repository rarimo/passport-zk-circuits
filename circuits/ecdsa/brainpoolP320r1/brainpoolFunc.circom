pragma circom 2.1.6;

function get_order(CHUNK_SIZE,CHUNK_NUMBER){

    assert ((CHUNK_SIZE == 32) && (CHUNK_NUMBER == 10));

    var ORDER[10];

    ORDER[0] = 1153798929;
    ORDER[1] = 2257671515;
    ORDER[2] = 4001781993;
    ORDER[3] = 759705287;
    ORDER[4] = 3062829731;
    ORDER[5] = 4186951589;
    ORDER[6] = 3523338341;
    ORDER[7] = 3778836574;
    ORDER[8] = 918310839;
    ORDER[9] = 3546171168;

    return ORDER;
}

function get_params(CHUNK_SIZE,CHUNK_NUMBER){
    
    assert ((CHUNK_SIZE == 32) && (CHUNK_NUMBER == 10));

    var A[10];
    var P[10];
    var B[10];

    var PARAMS[3][10];

    A[0] = 2105937588;
    A[1] = 2465428905;
    A[2] = 2248124916;
    A[3] = 1712918192;
    A[4] = 4125850074;
    A[5] = 2728867091;
    A[6] = 1832860600;
    A[7] = 2211245012;
    A[8] = 2411376888;
    A[9] = 1055066966;
    B[0] = 2410803622;
    B[1] = 1868477612;
    B[2] = 2286238081;
    B[3] = 3425819853;
    B[4] = 2505356442;
    B[5] = 3779019060;
    B[6] = 1080593007;
    B[7] = 3551336838;
    B[8] = 2650651714;
    B[9] = 1376289684;
    P[0] = 4055051815;
    P[1] = 4241756849;
    P[2] = 2022960168;
    P[3] = 1335015916;
    P[4] = 4143189487;
    P[5] = 4186951590;
    P[6] = 3523338341;
    P[7] = 3778836574;
    P[8] = 918310839;
    P[9] = 3546171168;

    PARAMS[0] = A;
    PARAMS[1] = B;
    PARAMS[2] = P;
    
    return PARAMS;
}

function get_dummy_point(CHUNK_SIZE,CHUNK_NUMBER){

    assert ((CHUNK_SIZE == 32) && (CHUNK_NUMBER == 10)); 

    var DUMMY[2][10];

    DUMMY[0][0] = 3618987067;
    DUMMY[0][1] = 1246284267;
    DUMMY[0][2] = 1443155418;
    DUMMY[0][3] = 814100841;
    DUMMY[0][4] = 2623697010;
    DUMMY[0][5] = 4004732673;
    DUMMY[0][6] = 3535093894;
    DUMMY[0][7] = 2197257376;
    DUMMY[0][8] = 2043287943;
    DUMMY[0][9] = 2382825036;
    DUMMY[1][0] = 2499851110;
    DUMMY[1][1] = 822647969;
    DUMMY[1][2] = 2980671764;
    DUMMY[1][3] = 1347766415;
    DUMMY[1][4] = 2998204557;
    DUMMY[1][5] = 510652630;
    DUMMY[1][6] = 2505684036;
    DUMMY[1][7] = 3635842112;
    DUMMY[1][8] = 4197847501;
    DUMMY[1][9] = 833113252;


    return DUMMY;
}


