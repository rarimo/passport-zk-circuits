pragma circom  2.1.6;

// Templates for montogomery representation of points and curve
//--------------------------------------------------------------------------------------------------------------------------------

// [u, v] = [(1 + y) / (1 - y), (1 + y) / (x * (1 - y))]

template Edwards2Montgomery() {
    signal input in[2];
    signal output out[2];
    
    out[0] <-- (1 + in[1]) / (1 - in[1]);
    out[1] <-- out[0] / in[0];
    
    
    out[0] * (1 - in[1]) === (1 + in[1]);
    out[1] * in[0] === out[0];
}


// [x,y] = [u / v, (u - 1) / (u + 1)]

template Montgomery2Edwards() {
    signal input in[2];
    signal output out[2];
    
    out[0] <-- in[0] / in[1];
    out[1] <-- (in[0] - 1) / (in[0] + 1);
    
    out[0] * in[1] === in[0];
    out[1] * (in[0] + 1) === in[0] - 1;
}

// λ = (y2 - y1) / (x2 - x1)
// x3 = B * λ ** 2 - A - x1 - x2
// y3 = λ * (x1 - x3) - y1

template MontgomeryAdd() {
    signal input in[2][2];
    signal output out[2];
    
    var a = 168700;
    var d = 168696;
    
    var A = (2 * (a + d)) / (a - d);
    var B = 4 / (a - d);
    
    signal lamda;
    
    lamda <-- (in[1][1] - in[0][1]) / (in[1][0] - in[0][0]);
    lamda * (in[1][0] - in[0][0]) === (in[1][1] - in[0][1]);
    
    out[0] <== B * lamda * lamda - A - in[0][0] - in[1][0];
    out[1] <== lamda * (in[0][0] - out[0]) - in[0][1];
}


// λ = (3 * x1 ^ 2 + 2 * A * x1 + 1) / (2 * B * y1)
// x3 = B * λ ^ 2 - A - x1 - x1
// y3 = λ * (x1 - x3) - y1

template MontgomeryDouble() {
    signal input in[2];
    signal output out[2];
    
    var a = 168700;
    var d = 168696;
    
    var A = (2 * (a + d)) / (a - d);
    var B = 4 / (a - d);
    
    signal lamda;
    signal x1_2;
    
    x1_2 <== in[0] * in[0];
    
    lamda <-- (3 * x1_2 + 2 * A * in[0] + 1) / (2 * B * in[1]);
    lamda * (2 * B * in[1]) === (3 * x1_2 + 2 * A * in[0] + 1);
    
    out[0] <== B * lamda * lamda - A - 2 * in[0];
    out[1] <== lamda * (in[0] - out[0]) - in[1];
}


