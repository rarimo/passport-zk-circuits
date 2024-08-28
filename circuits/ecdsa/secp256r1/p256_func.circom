pragma circom 2.1.5;

function get_p256_order(n, k) {
    assert((n == 64) && (k == 4));
    var order[6];

    if (n == 43 && k == 6) {
        order[0] = 3036481267025;
        order[1] = 3246200354617;
        order[2] = 7643362670236;
        order[3] = 8796093022207;
        order[4] = 1048575;
        order[5] = 2199023255040;
    }
    return order;
}

function get_p256_params(n,k){
     
    var a[6];
    var p[6];
    var b[6];

    var params[3][6];

    p[0] = 8796093022207;
    p[1] = 8796093022207;
    p[2] = 1023;
    p[3] = 0;
    p[4] = 1048576;
    p[5] = 2199023255040;
    a[0] = 8796093022204;
    a[1] = 8796093022207;
    a[2] = 1023;
    a[3] = 0;
    a[4] = 1048576;
    a[5] = 2199023255040;
    b[0] = 4665002582091;
    b[1] = 2706345785799;
    b[2] = 1737114698545;
    b[3] = 7330356544350;
    b[4] = 4025432620731;
    b[5] = 779744948564;

    params[0] = a;
    params[1] = b;
    params[2] = p;
    
    return params;
}

function get_p256_dummy_point(n, k) {
    var dummy[2][6]; 

    dummy[0][0] = 5013155818324;
    dummy[0][1] = 5653956830653;
    dummy[0][2] = 1357089440655;
    dummy[0][3] = 4985459479134;
    dummy[0][4] = 7362399503982;
    dummy[0][5] = 1028176290396;
    dummy[1][0] = 2185447106559;
    dummy[1][1] = 2319789413632;
    dummy[1][2] = 3837703653281;
    dummy[1][3] = 6590333830457;
    dummy[1][4] = 5404134177552;
    dummy[1][5] = 1407546699851;

    return dummy;
}

function div_ceil(m, n) {
    var ret = 0;
    if (m % n == 0) {
        ret = m \ n;
    } else {
        ret = m \ n + 1;
    }
    return ret;
}