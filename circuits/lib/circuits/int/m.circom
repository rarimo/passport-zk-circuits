template tmpSum(n){
    signal input in[n];
    var res = 0;
    for (var i = 0; i < n; i++){
        res += in[i];
    }
    signal output out <== res;
}

component main{ public [in]} = tmpSum(5);