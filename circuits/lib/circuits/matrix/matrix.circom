pragma circom 2.1.6;

include "../int/arithmetic.circom";
include "./matrixFunc.circom";
include "../bigInt/bigIntFunc.circom";
include "../float/float.circom";


// Here are templates for matrix operations
// Use them only if u know what are u doing!!!
// To help with debug u can use this:
// var print = log_matrix(out, x1, x2);
// This will log your matrix out with dimmesions x1 x x2
// x2 < 40; can be changed in "./matrixFunc.circom"
//----------------------------------------------------------------------------------------------------------------------------
// Computes in1(n1xm1) X in2(n2xm2);
// There is check for m1 == n2, otherwise matrixes are unable to multiply
// Use the same template for matrix vector multiplication (n1, m1, m1, 1)
template MatrixMultiply(n1, m1, n2, m2){
    assert(m1 == n2);
    signal input in1[n1][m1];
    signal input in2[n2][m2];
    
    
    signal output out[n1][m2];
    
    component getSum[n1][m2];
    for (var i = 0; i < n1; i++){
        for (var j = 0; j < m2; j++){
            getSum[i][j] = GetSumOfNElements(m1);
            for (var k = 0; k < m1; k++){
                getSum[i][j].in[k] <== in1[i][k] * in2[k][j];
            }
            out[i][j] <== getSum[i][j].out;
        }
    }
    
    // var print = log_matrix(out, n1, m2);
}

// Computes matrix * scalar multiplication
// in is matrix nxm
// scalar is scalar to multiply 
// out is matrix nxm
template MatrixScalarMult(n, m){
    signal input in[n][m];
    signal input scalar;
    
    
    
    signal output out[n][m];
    
    for (var i = 0; i < n; i++){
        for (var j = 0; j < m; j++){
            out[i][j] <== in[i][j] * scalar;
        }
    }
    
    // var print = log_matrix(out, n, m);
}

// Computes Hadamard Product for 2 matrix in1 and in2 with n x m size
// out is matrix with each element is multiplication of elements from input matrices on the same poosition
template MatrixHadamardProduct(n, m){
    signal input in1[n][m];
    signal input in2[n][m];
    signal output out[n][m];
    
    for (var i = 0; i < n; i++){
        for (var j = 0; j < m; j++){
            out[i][j] <== in1[i][j] * in2[i][j];
        }
    }
    
    // var print = log_matrix(out, n, m);
}

// Computes addition for 2 matrix in1 and in2 with n x m size
// out is matrix with each element is sum of elements from input matrices on the same poosition
template MatrixAddition(n, m){
    signal input in1[n][m];
    signal input in2[n][m];
    
    signal output out[n][m];
    
    for (var i = 0; i < n; i++){
        for (var j = 0; j < m; j++){
            out[i][j] <== in1[i][j] + in2[i][j];
        }
    }
    
    // var print = log_matrix(out, n, m);
}

// return transpositioned matrix
// 0 quadratic constraints, just copy constraints
// in is matrix n x m
// out is matrix m x n
template MatrixTransposition(n, m){
    signal input in[n][m];
    signal output out[m][n];
    
    for (var i = 0; i < n; i++){
        for (var j = 0; j < m; j++){
            out[j][i] <== in[i][j];
        }
    }
    
    // var print = log_matrix(out, m, n);
}

// Compute matrix determinant of square matrix with size n
// out is determinant
// U should understand, that determinant can be negative, so out can be very big (we work in field)
// for example, -1 == 21888242871839275222246405745257275088548364400416034343698204186575808495616
template MatrixDeterminant(n){
    assert(n >= 2);
    
    signal input in[n][n];
    
    
    signal output out;
    
    if (n == 2){
        signal ad <== in[0][0] * in[1][1];
        signal db <== in[0][1] * in[1][0];
        out <== ad - db;
    } else {
        component sum = GetSumOfNElements(n);
        component matrixDeterminant[n];
        for (var i = 0; i < n; i++){
            matrixDeterminant[i] = MatrixDeterminant(n - 1);
            for (var n_idx = 1; n_idx < n; n_idx++){
                for (var m_idx = 0; m_idx < n; m_idx++){
                    if (m_idx != i){
                        matrixDeterminant[i].in[n_idx - 1][m_idx - (m_idx > i)] <== in[n_idx][m_idx];
                    }
                }
            }
            if (i % 2 == 0){
                sum.in[i] <== in[0][i] * matrixDeterminant[i].out;
            } else {
                sum.in[i] <== 0 - in[0][i] * matrixDeterminant[i].out;
            }
        }
        out <== sum.out;
        
    }
    
    // var print = log_matrix(in, n, n);
    // log(out);
    // log("-", 0 - out);
    // log("=========");
    
}

// Computes input matrix in ^ EXP
// EXP >= 2;
// in is square matrix n x n 
template MatrixPower(n, EXP){
    assert(EXP >= 2);
    
    signal input in[n][n];
    signal output out[n][n];
    
    
    var exp_process[256] = exp_to_bits(EXP);
    
    component muls[exp_process[0]];
    component resultMuls[exp_process[1] - 1];
    
    for (var i = 0; i < exp_process[0]; i++){
        muls[i] = MatrixMultiply(n, n, n, n);
    }
    
    for (var i = 0; i < exp_process[1] - 1; i++){
        resultMuls[i] = MatrixMultiply(n, n, n, n);
    }
    
    muls[0].in1 <== in;
    muls[0].in2 <== in;
    
    for (var i = 1; i < exp_process[0]; i++){
        muls[i].in1 <== muls[i - 1].out;
        muls[i].in2 <== muls[i - 1].out;
    }
    
    for (var i = 0; i < exp_process[1] - 1; i++){
        if (i == 0){
            if (exp_process[i + 2] == 0){
                resultMuls[i].in1 <== in;
            } else {
                resultMuls[i].in1 <== muls[exp_process[i + 2] - 1].out;
            }
            resultMuls[i].in2 <== muls[exp_process[i + 3] - 1].out;
        }
        else {
            resultMuls[i].in1 <== resultMuls[i - 1].out;
            resultMuls[i].in2 <== muls[exp_process[i + 3] - 1].out;
        }
    }
    
    if (exp_process[1] == 1){
        out <== muls[exp_process[0] - 1].out;
    } else {
        out <== resultMuls[exp_process[1] - 2].out;
    }

    // var print = log_matrix(out, n, n);
}

template FloatMatrixCutPrecision(n1, m1, precOld, precNew) {
    assert(precOld > precNew);
    signal input in[n1][m1];
    component remPrec[n1][m1];
    signal output out[n1][m1];
    for(var i = 0; i < n1; i++) {
        for (var j = 0; j < m1; j++) {
            remPrec[i][j] = CutPrecision(precNew, precOld);
            remPrec[i][j].in <== in[i][j];
            out[i][j] <== remPrec[i][j].out;
        }
    }
}