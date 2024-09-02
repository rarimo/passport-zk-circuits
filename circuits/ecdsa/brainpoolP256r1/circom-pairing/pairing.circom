pragma circom 2.0.3;

include "curve.circom";
include "curve_fp2.circom";
include "fp12.circom";
include "final_exp.circom";
include "bls12_381_func.circom";

// Inputs:
//  P is 2 x 2 x k array where P0 = (x_1, y_1) and P1 = (x_2, y_2) are points in E(Fp)
//  Q is 2 x 6 x 2 x k array representing point (X, Y) in E(Fp12)
// Assuming (x_1, y_1) != (x_2, y_2)
// Output:
//  out is 6 x 2 x (2k-1) array representing element of Fp12 equal to:
//  (y_1 - y_2) X + (x_2 - x_1) Y + (x_1 y_2 - x_2 y_1)
// We evaluate out without carries
// If all registers of P, Q are in [0, 2^n),
// Then all registers of out have abs val < 3k * 2^{2n} )
// m_out is the expected max number of bits in the output registers
template SignedLineFunctionUnequalNoCarry(n, k, m_out){
    signal input P[2][2][k];
    signal input Q[2][6][2][k];
    signal output out[6][2][2*k-1];

    // (y_1 - y_2) X
    var LOGK = log_ceil(k);
    component Xmult = SignedFp12ScalarMultiplyNoCarry(n, k, 2*n + LOGK); // registers in [0, k*2^{2n} )
    // (x_2 - x_1) Y
    component Ymult = SignedFp12ScalarMultiplyNoCarry(n, k, 2*n + LOGK);
    for(var i=0; i<k; i++){
        Xmult.a[i] <== P[0][1][i] - P[1][1][i];
        
        Ymult.a[i] <== P[1][0][i] - P[0][0][i];
    }
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
        Xmult.b[i][j][idx] <== Q[0][i][j][idx];

        Ymult.b[i][j][idx] <== Q[1][i][j][idx]; 
    } 
    
    component x1y2 = BigMultShortLong(n, k, 2*n + LOGK); // registers in [0, k*2^{2n}) 
    component x2y1 = BigMultShortLong(n, k, 2*n + LOGK);
    for(var i=0; i<k; i++){
        x1y2.a[i] <== P[0][0][i]; 
        x1y2.b[i] <== P[1][1][i];
        
        x2y1.a[i] <== P[1][0][i]; 
        x2y1.b[i] <== P[0][1][i];
    }
    
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<2*k-1; idx++){
        if( i==0 && j==0 ){
            out[i][j][idx] <== Xmult.out[i][j][idx] + Ymult.out[i][j][idx] + x1y2.out[idx] - x2y1.out[idx]; // register < 3k*2^{2n} 
        }else 
            out[i][j][idx] <== Xmult.out[i][j][idx] + Ymult.out[i][j][idx]; // register in [0, 2k*2^{2n} )
    }
}

// Assuming curve is of form Y^2 = X^3 + b for now (a = 0) for better register bounds 
// Inputs:
//  P is 2 x k array where P = (x, y) is a point in E(Fp) 
//  Q is 2 x 6 x 2 x k array representing point (X, Y) in E(Fp12) 
// Output: 
//  out is 6 x 2 x (3k-2) array representing element of Fp12 equal to:
//  3 x^2 (-X + x) + 2 y (Y - y)
// We evaluate out without carries, with signs
// If P, Q have registers in [0, B) 
// Then out has registers with abs val < 3k^2*B^3 + 2k*B^2 < (3k^2 + 2k/B)*B^3)
// m_out is the expected max number of bits in the output registers
template SignedLineFunctionEqualNoCarry(n, k, m_out){
    signal input P[2][k]; 
    signal input Q[2][6][2][k];
    signal output out[6][2][3*k-2];
    var LOGK = log_ceil(k);

    component x_sq3 = BigMultShortLong(n, k, 2*n + 2 + LOGK); // 2k-1 registers in [0, 3*k*2^{2n} )
    for(var i=0; i<k; i++){
        x_sq3.a[i] <== 3*P[0][i];
        x_sq3.b[i] <== P[0][i];
    } 
    
    // 3 x^2 (-X + x)
    component Xmult = SignedFp12ScalarMultiplyNoCarryUnequal(n, 2*k-1, k, 3*n + 2*LOGK + 2); // 3k-2 registers < 3 * k^2 * 2^{3n})
    for(var idx=0; idx<2*k-1; idx++){
        Xmult.a[idx] <== x_sq3.out[idx];
    }
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
        if(i==0 && j==0)
            Xmult.b[i][j][idx] <== P[0][idx] - Q[0][i][j][idx];
        else
            Xmult.b[i][j][idx] <== -Q[0][i][j][idx];
    }

    // 2 y (Y-y)
    component Ymult = SignedFp12ScalarMultiplyNoCarry(n, k, 2*n + LOGK + 1); // 2k-1 registers < 2k*2^{2n} 
    for(var idx=0; idx < k; idx++){
        Ymult.a[idx] <== 2*P[1][idx];
    }
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
        if(i==0 && j==0)
            Ymult.b[i][j][idx] <== Q[1][i][j][idx] - P[1][idx];
        else
            Ymult.b[i][j][idx] <== Q[1][i][j][idx];
    }
    
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<3*k-2; idx++){
        if(idx < 2*k-1)
            out[i][j][idx] <== Xmult.out[i][j][idx] + Ymult.out[i][j][idx];
        else
            out[i][j][idx] <== Xmult.out[i][j][idx];
    }
}

// Inputs:
//  P is 2 x 2 x k array where P0 = (x_1, y_1) and P1 = (x_2, y_2) are points in E(Fp)
//  Q is 2 x 6 x 2 x k array representing point (X, Y) in E(Fp12)
// Assuming (x_1, y_1) != (x_2, y_2)
// Output:
//  Q is 6 x 2 x k array representing element of Fp12 equal to:
//  (y_1 - y_2) X + (x_2 - x_1) Y + (x_1 y_2 - x_2 y_1)
template LineFunctionUnequal(n, k, q) {
    signal input P[2][2][k];
    signal input Q[2][6][2][k];

    signal output out[6][2][k];
    var LOGK1 = log_ceil(3*k);
    var LOGK2 = log_ceil(3*k*k);

    component noCarry = SignedLineFunctionUnequalNoCarry(n, k, 2 * n + LOGK1);
    for (var i = 0; i < 2; i++)for(var j = 0; j < 2; j++) {
	    for (var idx = 0; idx < k; idx++) {
            noCarry.P[i][j][idx] <== P[i][j][idx];
	    }
    }

    for (var i = 0; i < 2; i++)for(var j = 0; j < 6; j++) {
	    for (var l = 0; l < 2; l++) {
		for (var idx = 0; idx < k; idx++) {
		    noCarry.Q[i][j][l][idx] <== Q[i][j][l][idx];
		}
	    }
    }
    component reduce[6][2];
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 2; j++) {
            reduce[i][j] = PrimeReduce(n, k, k - 1, q, 3 * n + LOGK2);
        }

        for (var j = 0; j < 2; j++) {
            for (var idx = 0; idx < 2 * k - 1; idx++) {
                reduce[i][j].in[idx] <== noCarry.out[i][j][idx];
            }
        }	
    }

    // max overflow register size is 3 * k^2 * 2^{3n}
    component carry = SignedFp12CarryModP(n, k, 3 * n + LOGK2, q);
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 2; j++) {
            for (var idx = 0; idx < k; idx++) {
                carry.in[i][j][idx] <== reduce[i][j].out[idx];
            }
        }
    }
    
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 2; j++) {
            for (var idx = 0; idx < k; idx++) {
            out[i][j][idx] <== carry.out[i][j][idx];
            }
        }
    }    
}


// Assuming curve is of form Y^2 = X^3 + b for now (a = 0) for better register bounds 
// Inputs:
//  P is 2 x k array where P = (x, y) is a point in E(Fp) 
//  Q is 2 x 6 x 2 x k array representing point (X, Y) in E(Fp12) 
// Output: 
//  out is 6 x 2 x k array representing element of Fp12 equal to:
//  3 x^2 (-X + x) + 2 y (Y - y)
template LineFunctionEqual(n, k, q) {
    signal input P[2][k];
    signal input Q[2][6][2][k];

    signal output out[6][2][k];

    var LOGK2 = log_ceil((3*k+1)*k);
    component noCarry = SignedLineFunctionEqualNoCarry(n, k, 3*n + LOGK2);
    for (var i = 0; i < 2; i++) {
        for (var idx = 0; idx < k; idx++) {
            noCarry.P[i][idx] <== P[i][idx];
        }
    }

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 6; j++) {
            for (var l = 0; l < 2; l++) {
                for (var idx = 0; idx < k; idx++) {
                    noCarry.Q[i][j][l][idx] <== Q[i][j][l][idx];
                }
            }
        }
    }
    
    var LOGK3 = log_ceil((2*k-1)*(3*k*k) + 1);
    component reduce[6][4]; 
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 2; j++) {
            reduce[i][j] = PrimeReduce(n, k, 2 * k - 2, q, 4 * n + LOGK3);
        }

        for (var j = 0; j < 2; j++) {
            for (var idx = 0; idx < 3 * k - 2; idx++) {
                reduce[i][j].in[idx] <== noCarry.out[i][j][idx];
            }
        }	
    }

    // max overflow register size is (2k - 1) * (3k^2+1) * 2^{4n} assuming 2k<=2^n
    component carry = SignedFp12CarryModP(n, k, 4 * n + LOGK3, q);
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 2; j++) {
            for (var idx = 0; idx < k; idx++) {
                carry.in[i][j][idx] <== reduce[i][j].out[idx];
            }
        }
    }
    
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 2; j++) {
            for (var idx = 0; idx < k; idx++) {
            out[i][j][idx] <== carry.out[i][j][idx];
            }
        }
    }    
}


// Input:
//  g is 6 x 2 x kg array representing element of Fp12, allowing overflow and negative
//  P0, P1, Q are as in inputs of SignedLineFunctionUnequalNoCarry
// Assume:
//  all registers of g are in [0, 2^{overflowg}) 
//  all registers of P, Q are in [0, 2^n) 
// Output:
//  out = g * l_{P0, P1}(Q) as element of Fp12 with carry 
//  out is 6 x 2 x k
template Fp12MultiplyWithLineUnequal(n, k, kg, overflowg, q){
    signal input g[6][2][kg];
    signal input P[2][2][k];
    signal input Q[2][6][2][k];
    signal output out[6][2][k];

    var XI0 = 1;
    var LOGK1 = log_ceil(6*k);
    var LOGK2 = log_ceil(6*k * min(kg, 2*k-1) * 6 * (2+XI0) );
    var LOGK3 = log_ceil( 6*k * min(kg, 2*k-1) * 6 * (2+XI0) * (k + kg - 1) );
    assert( overflowg + 3*n + LOGK3 < 251 );

    component line = SignedLineFunctionUnequalNoCarry(n, k, 2*n + LOGK1); // 6 x 2 x 2k - 1 registers abs val < 3k 2^{2n}
    for(var l=0; l<2; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        line.P[l][j][idx] <== P[l][j][idx];
    for(var l=0; l<2; l++)for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        line.Q[l][i][j][idx] <== Q[l][i][j][idx];
    
    component mult = SignedFp12MultiplyNoCarryUnequal(n, kg, 2*k - 1, overflowg + 2*n + LOGK2); // 6 x 2 x (2k + kg - 2) registers < 3k * min(kg, 2k - 1) * 6 * (2+XI0)* 2^{overflowg + 2n} )
    
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<kg; idx++)
        mult.a[i][j][idx] <== g[i][j][idx];
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<2*k-1; idx++)
        mult.b[i][j][idx] <== line.out[i][j][idx];


    component reduce = Fp12Compress(n, k, k + kg - 2, q, overflowg + 3*n + LOGK3); // 6 x 2 x k registers in [0, 3 k * min(kg, 2k - 1) * 6*(2+XI0) * (k + kg - 1) *  2^{overflowg + 3n} )
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<2*k + kg - 2; idx++)
        reduce.in[i][j][idx] <== mult.out[i][j][idx];
    
    component carry = SignedFp12CarryModP(n, k, overflowg + 3*n + LOGK3, q);

    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        carry.in[i][j][idx] <== reduce.out[i][j][idx];

    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        out[i][j][idx] <== carry.out[i][j][idx];
}

// Assuming curve is of form Y^2 = X^3 + b for now (a = 0) for better register bounds 
// Inputs:
//  in is 6 x 2 x k array representing element in Fq12
//  P is 2 x k array where P = (x, y) is a point in E[r](Fq) 
//  Q is 2 x 6 x 2 x k array representing point (X, Y) in E(Fq12) 
// Output:
//  out = f_x(P,Q) is 6 x 2 x k, where we start with f_0(P,Q) = in and use Miller's algorithm f_{i+j} = f_i * f_j * l_{i,j}(P,Q)
//  xP = [x]P is 2 x k array
// Assume:
//  r is prime (not a parameter in this template)
//  x in [0, 2^250) and x < r  (we will use this template when x has few significant bits in base 2)
//  q has k registers in [0, 2^n)
//  P != O so the order of P in E(Fq) is r, so [i]P != [j]P for i != j in Z/r 
template MillerLoop(n, k, b, x, q){
    signal input in[6][2][k];
    signal input P[2][k]; 
    signal input Q[2][6][2][k];

    signal output out[6][2][k];
    signal output xP[2][k];

    var LOGK = log_ceil(k);
    var XI0 = 1;
    var LOGK2 = log_ceil(36*(2+XI0)*(2+XI0) * k*k);
    var LOGK3 = log_ceil(36*(2+XI0)*(2+XI0) * k*k*(2*k-1));
    assert( 4*n + LOGK3 < 251 );
    

    var BITS[250]; // length is k * n
    var BIT_LENGTH;
    var SIG_BITS=0;
    for (var i = 0; i < 250; i++) {
        BITS[i] = (x >> i) & 1;
        if(BITS[i] == 1){
            SIG_BITS++;
            BIT_LENGTH = i + 1;
        }
    }

    signal pInterMed[BIT_LENGTH][2][k]; 
    signal f[BIT_LENGTH][6][2][k];

    component pDouble[BIT_LENGTH];
    component fDouble[BIT_LENGTH];
    component square[BIT_LENGTH];
    component line[BIT_LENGTH];
    component compress[BIT_LENGTH];
    component noCarry[BIT_LENGTH];
    component pAdd[SIG_BITS];
    component fAdd[SIG_BITS]; 
    component fAddPre[SIG_BITS]; 
    var CUR_ID=0;

    for(var i=BIT_LENGTH - 1; i>=0; i--){
        if( i == BIT_LENGTH - 1 ){
            // f = 1 
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
                f[i][l][j][idx] <== in[l][j][idx];
            }
            for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                pInterMed[i][j][idx] <== P[j][idx];
        }else{
            // compute fDouble[i] = f[i+1]^2 * l_{pInterMed[i+1], pInterMed[i+1]}(Q) 
            square[i] = SignedFp12MultiplyNoCarry(n, k, 2*n + 4 + LOGK); // 6 x 2 x 2k-1 registers in [0, 6 * k * (2+XI0) * 2^{2n} )
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
                square[i].a[l][j][idx] <== f[i+1][l][j][idx];
                square[i].b[l][j][idx] <== f[i+1][l][j][idx];
            }

            line[i] = LineFunctionEqual(n, k, q); // 6 x 2 x k registers in [0, 2^n) 
            for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                line[i].P[j][idx] <== pInterMed[i+1][j][idx];            
            for(var eps=0; eps<2; eps++)
                for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    line[i].Q[eps][l][j][idx] <== Q[eps][l][j][idx];

            noCarry[i] = SignedFp12MultiplyNoCarryUnequal(n, 2*k-1, k, 3*n + LOGK2); // 6 x 2 x 3k-2 registers < (6 * (2+XI0))^2 * k^2 * 2^{3n} ) 
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<2*k-1; idx++)
                noCarry[i].a[l][j][idx] <== square[i].out[l][j][idx];
            
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                noCarry[i].b[l][j][idx] <== line[i].out[l][j][idx];
            
            compress[i] = Fp12Compress(n, k, 2*k-2, q, 4*n + LOGK3); // 6 x 2 x k registers < (6 * (2+ XI0))^2 * k^2 * (2k-1) * 2^{4n} )
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<3*k-2; idx++)
                compress[i].in[l][j][idx] <== noCarry[i].out[l][j][idx];

            fDouble[i] = SignedFp12CarryModP(n, k, 4*n + LOGK3, q);
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                fDouble[i].in[l][j][idx] <== compress[i].out[l][j][idx]; 

            pDouble[i] = EllipticCurveDouble(n, k, 0, b, q);  
            for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                pDouble[i].in[j][idx] <== pInterMed[i+1][j][idx]; 
            
            if(BITS[i] == 0){
                for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    f[i][l][j][idx] <== fDouble[i].out[l][j][idx]; 
                for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    pInterMed[i][j][idx] <== pDouble[i].out[j][idx];
            }else{
                // fAdd[CUR_ID] = fDouble * in * l_{pDouble[i], P}(Q) 
                fAddPre[CUR_ID] = Fp12Multiply(n, k, q); 
                for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
                    fAddPre[CUR_ID].a[l][j][idx] <== fDouble[i].out[l][j][idx];
                    fAddPre[CUR_ID].b[l][j][idx] <== in[l][j][idx]; 
                }

                fAdd[CUR_ID] = Fp12MultiplyWithLineUnequal(n, k, k, n, q); 
                for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    fAdd[CUR_ID].g[l][j][idx] <== fAddPre[CUR_ID].out[l][j][idx];
                
                for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
                    fAdd[CUR_ID].P[0][j][idx] <== pDouble[i].out[j][idx];            
                    fAdd[CUR_ID].P[1][j][idx] <== P[j][idx];            
                }
                for(var eps=0; eps<2; eps++)for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    fAdd[CUR_ID].Q[eps][l][j][idx] <== Q[eps][l][j][idx];

                for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    f[i][l][j][idx] <== fAdd[CUR_ID].out[l][j][idx]; 

                // pAdd[CUR_ID] = pDouble[i] + P 
                pAdd[CUR_ID] = EllipticCurveAddUnequal(n, k, q); 
                for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
                    pAdd[CUR_ID].a[j][idx] <== pDouble[i].out[j][idx];
                    pAdd[CUR_ID].b[j][idx] <== P[j][idx];
                }

                for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    pInterMed[i][j][idx] <== pAdd[CUR_ID].out[j][idx];
                
                CUR_ID++;
            }
        }
    }
    for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        out[l][j][idx] <== f[0][l][j][idx];
    for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        xP[j][idx] <== pInterMed[0][j][idx]; 
    
}


// Assuming curve is of form Y^2 = X^3 + b for now (a = 0) for better register bounds 
// Inputs:
//  P is 2 x k array where P = (x, y) is a point in E[r](Fq) 
//  Q is 2 x 6 x 2 x k array representing point (X, Y) in E(Fq12) 
// Output:
// f_r(Q) where <f_r> = [r]P - [r]O is computed using Miller's algorithm
// Assume:
//  r  = x^4 - x^2 + 1 where x is the parameter of the curve
//  q has k registers in [0, 2^n)
//  r is prime
//  P != O so the order of P in E(Fq) is r, so [i]P != [j]P for i != j in Z/r 
template BLSMillerLoop(n, k, q){
    signal input P[2][k]; 
    signal input Q[2][6][2][k];
    signal output out[6][2][k];

    var XI0 = 1;
    var b = 4; // Y^2 = X^3 + 4
    var x = get_BLS12_381_parameter();

    // fx[i] = f_{x^{i+1}} 
    component fx[4]; 
    for(var e=0; e<4; e++){
        fx[e] = MillerLoop(n, k, b, x, q);
        if( e == 0 ){
            for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
                if(i == 0 && j == 0 && idx == 0)
                    fx[e].in[i][j][idx] <== 1;
                else    
                    fx[e].in[i][j][idx] <== 0;
            }
            for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                fx[e].P[j][idx] <== P[j][idx];
        }else{
            for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                fx[e].in[i][j][idx] <== fx[e - 1].out[i][j][idx];
            for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                fx[e].P[j][idx] <== fx[e - 1].xP[j][idx];            
        }
        for(var l=0; l<2; l++)for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
            fx[e].Q[l][i][j][idx] <== Q[l][i][j][idx];
    }
    
    // f_{x^4} * l_{x^4, 1}(P,Q) 
    component fx4l = Fp12MultiplyWithLineUnequal(n, k, k, n, q); 
    // assert( 4*n + log_ceil(12 * (2*k-1) *k * k) + 2 < 252 );  // need this to run MillerLoop anyways
    for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
        fx4l.g[l][j][idx] <== fx[3].out[l][j][idx];
    }
    for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
        fx4l.P[0][j][idx] <== fx[3].xP[j][idx];            
        fx4l.P[1][j][idx] <== P[j][idx];            
    }
    for(var l=0; l<2; l++)for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        fx4l.Q[l][i][j][idx] <== Q[l][i][j][idx];
    
    /* Don't need this, vertical lines can be omitted due to final exponentiation:
    // f_{x^2} * l_{r,x^2}(P,Q) where l_{r,x^2}(P,Q) = Q.x - ([x^2]P).x 
    var LOGK2 = log_ceil(6*(2+XI0)*k*k);
    component fx2l = SignedFp12MultiplyNoCarryCompress(n, k, q, n, 3*n + LOGK2); // registers in [0, 6*(2+XI0)*k^2*2^{3n} )
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
        fx2l.a[i][j][idx] <== fx[1].out[i][j][idx];
        
        if(i == 0 && j == 0)
            fx2l.b[i][j][idx] <== Q[0][i][j][idx] - fx[1].xP[0][idx];
        else
            fx2l.b[i][j][idx] <== Q[0][i][j][idx];
    }

    component carry = SignedFp12CarryModP(n, k, 3*n + LOGK2, q);
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        carry.in[i][j][idx] <== fx2l.out[i][j][idx];
    */

    // find fx2^{-1}. Not going to optimize this for now since it's just one call
    component inv = Fp12Invert(n, k, q);
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        inv.in[i][j][idx] <== fx[1].out[i][j][idx];

    component fr = Fp12Multiply(n, k, q);
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
        fr.a[i][j][idx] <== fx4l.out[i][j][idx];
        fr.b[i][j][idx] <== inv.out[i][j][idx];
    }
    
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        out[i][j][idx] <== fr.out[i][j][idx];
}

template TatePairing(n, k, q){
    signal input P[2][k]; 
    signal input Q[2][6][2][k];
    signal output out[6][2][k];

    component miller = BLSMillerLoop(n, k, q);
    for(var i=0; i<2; i++)for(var idx=0; idx<k; idx++)
        miller.P[i][idx] <== P[i][idx];
    for(var i=0; i<2; i++)for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        miller.Q[i][l][j][idx] <== Q[i][l][j][idx];
    
    component finalexp = FinalExponentiate(n, k, q);
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        finalexp.in[i][j][idx] <== miller.out[i][j][idx];

    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        out[i][j][idx] <== finalexp.out[i][j][idx]; 

    /*
    // check out[i][j] < p since we never did that previously
    component lt[6][2];
    for(var i=0; i<6; i++)for(var j=0; j<2; j++){
        lt[i][j] = BigLessThan(n, k);
        for(var idx=0; idx<k; idx++){
            lt[i][j].a[idx] <== out[i][j][idx];
            lt[i][j].b[idx] <== q[idx];
        }
        lt[i][j].out === 1;
    }*/
}

// Inputs:
//  P is 2 x 2 x 2 x k array where P0 = (x_1, y_1) and P1 = (x_2, y_2) are points in E(Fp2)
//  Q is 2 x k array representing point (X, Y) in E(Fp)
// Assuming (x_1, y_1) != (x_2, y_2)
// Output:
//  out is 6 x 2 x (2k-1) array representing element of Fp12 equal to:
//  w^3 (y_1 - y_2) X + w^4 (x_2 - x_1) Y + w (x_1 y_2 - x_2 y_1)
// We evaluate out without carries
// If all registers of P, Q are in [0, B),
// Then all registers of out have abs val < 2k * B^2 )
// m_out is the expected max number of bits in the output registers
template SignedLineFunctionUnequalNoCarryFp2(n, k, m_out){
    signal input P[2][2][2][k];
    signal input Q[2][k];
    signal output out[6][2][2*k-1];

    // (y_1 - y_2) X
    var LOGK = log_ceil(k);
    component Xmult = SignedFp2MultiplyNoCarry(n, k, 2*n + LOGK+1); // registers abs val < 2k*B^2
    // (x_2 - x_1) Y
    component Ymult = SignedFp2MultiplyNoCarry(n, k, 2*n + LOGK+1);
    for(var i = 0; i < 2; i ++) {
        for(var j=0; j<k; j++){
            Xmult.a[i][j] <== P[0][1][i][j] - P[1][1][i][j];
            
            Ymult.a[i][j] <== P[1][0][i][j] - P[0][0][i][j];
        }
    }
    for(var idx=0; idx<k; idx++){
        Xmult.b[0][idx] <== Q[0][idx];
        Xmult.b[1][idx] <== 0;

        Ymult.b[0][idx] <== Q[1][idx]; 
        Ymult.b[1][idx] <== 0;
    } 
    
    component x1y2 = BigMultShortLong2D(n, k, 2); // 2k-1 registers in [0, 2k*B^2) 
    component x2y1 = BigMultShortLong2D(n, k, 2);
    for(var i = 0; i < 2; i ++) {
        for(var j=0; j<k; j++){
            x1y2.a[i][j] <== P[0][0][i][j]; 
            x1y2.b[i][j] <== P[1][1][i][j];
            
            x2y1.a[i][j] <== P[1][0][i][j]; 
            x2y1.b[i][j] <== P[0][1][i][j];
        }
    }
    
    for(var idx=0; idx<2*k-1; idx++){
        out[0][0][idx] <== 0;
        out[0][1][idx] <== 0;
        out[2][0][idx] <== 0;
        out[2][1][idx] <== 0;
        out[5][0][idx] <== 0;
        out[5][1][idx] <== 0;

        out[1][0][idx] <== x1y2.out[0][idx] - x2y1.out[0][idx] - x1y2.out[2][idx] + x2y1.out[2][idx];
        out[1][1][idx] <== x1y2.out[1][idx] - x2y1.out[1][idx];
        out[3][0][idx] <== Xmult.out[0][idx];
        out[3][1][idx] <== Xmult.out[1][idx];
        out[4][0][idx] <== Ymult.out[0][idx];
        out[4][1][idx] <== Ymult.out[1][idx];
    }
}


// Assuming curve is of form Y^2 = X^3 + b for now (a = 0) for better register bounds 
// Inputs:
//  P is 2 x 2 x k array where P = (x, y) is a point in E(Fp2) 
//  Q is 2 x 6 x 2 x k array representing point (X, Y) in E(Fp12) 
// Output: 
//  out is 6 x 2 x (3k-2) array representing element of Fp12 equal to:
//  (3x^3 - 2y^2) + w^2 (-3 x^2 X) + w^3 (2 y Y)
// We evaluate out without carries, with signs
// If P, Q have registers in [0, B) 
// Then out has registers abs val < 12k^2*B^3
// m_out is the expected max number of bits in the output registers
template SignedLineFunctionEqualNoCarryFp2(n, k, m_out){
    signal input P[2][2][k]; 
    signal input Q[2][k];
    signal output out[6][2][3*k-2];
    var LOGK = log_ceil(k);

    component x_sq3 = BigMultShortLong2D(n, k, 2); // 2k-1 registers in [0, 6*k*2^{2n} )
    for(var i=0; i<2; i++){
        for(var j = 0; j < k; j ++) {
            x_sq3.a[i][j] <== 3*P[0][i][j];
            x_sq3.b[i][j] <== P[0][i][j];
        }
    }

    component x_cu3 = BigMultShortLong2DUnequal(n, 2*k-1, k, 2, 2);
    for (var i = 0; i < 2*k-1; i ++) {
        if (i < k) {
            x_cu3.b[0][i] <== P[0][0][i];
            x_cu3.b[1][i] <== P[0][1][i];
        }
        x_cu3.a[0][i] <== x_sq3.out[0][i] - x_sq3.out[2][i];
        x_cu3.a[1][i] <== x_sq3.out[1][i];
    }

    component y_sq2 = BigMultShortLong2D(n, k, 2); // 2k-1 registers in [0, 6*k*2^{2n} )
    for(var i=0; i<2; i++){
        for(var j = 0; j < k; j ++) {
            y_sq2.a[i][j] <== 2*P[1][i][j];
            y_sq2.b[i][j] <== P[1][i][j];
        }
    } 
    
    component Xmult = SignedFp2MultiplyNoCarryUnequal(n, 2*k-1, k, 3*n + 2*LOGK + 3); // 3k-2 registers abs val < 12 * k^2 * 2^{3n})
    for(var idx=0; idx<2*k-1; idx++){
        Xmult.a[0][idx] <== x_sq3.out[0][idx] - x_sq3.out[2][idx];
        Xmult.a[1][idx] <== x_sq3.out[1][idx];
    }
    for(var idx=0; idx<k; idx++){
        Xmult.b[0][idx] <== - Q[0][idx];
        Xmult.b[1][idx] <== 0;
    }

    component Ymult = SignedFp2MultiplyNoCarryUnequal(n, k, k, 2*n + LOGK + 2); // 2k-1 registers abs val < 4k*2^{2n} 
    for(var idx=0; idx < k; idx++){
        Ymult.a[0][idx] <== 2*P[1][0][idx];
        Ymult.a[1][idx] <== 2*P[1][1][idx];
    }
    for(var idx=0; idx<k; idx++){
        Ymult.b[0][idx] <== Q[1][idx];
        Ymult.b[1][idx] <== 0;
    }
    
    for(var idx=0; idx<3*k-2; idx++){
        out[1][0][idx] <== 0;
        out[1][1][idx] <== 0;
        out[4][0][idx] <== 0;
        out[4][1][idx] <== 0;
        out[5][0][idx] <== 0;
        out[5][1][idx] <== 0;

        if (idx < 2*k-1) {
            out[0][0][idx] <== x_cu3.out[0][idx] - x_cu3.out[2][idx] - y_sq2.out[0][idx] + y_sq2.out[2][idx];
            out[0][1][idx] <== x_cu3.out[1][idx] - y_sq2.out[1][idx];
            out[3][0][idx] <== Ymult.out[0][idx];
            out[3][1][idx] <== Ymult.out[1][idx];
        }
        else {
            out[0][0][idx] <== x_cu3.out[0][idx] - x_cu3.out[2][idx];
            out[0][1][idx] <== x_cu3.out[1][idx];
            out[3][0][idx] <== 0;
            out[3][1][idx] <== 0;
        }
        out[2][0][idx] <== Xmult.out[0][idx];
        out[2][1][idx] <== Xmult.out[1][idx];
    }
}

// Inputs:
//  P is 2 x 2 x k array where P0 = (x_1, y_1) and P1 = (x_2, y_2) are points in E(Fp2)
//  Q is 2 x 6 x 2 x k array representing point (X, Y) in E(Fp12)
// Assuming (x_1, y_1) != (x_2, y_2)
// Output:
//  Q is 6 x 2 x k array representing element of Fp12 equal to:
//  w^3 (y_1 - y_2) X + w^4 (x_2 - x_1) Y + w (x_1 y_2 - x_2 y_1)
template LineFunctionUnequalFp2(n, k, q) {
    signal input P[2][2][2][k];
    signal input Q[2][k];

    signal output out[6][2][k];
    var LOGK1 = log_ceil(2*k);
    var LOGK2 = log_ceil(2*k*k);

    component noCarry = SignedLineFunctionUnequalNoCarryFp2(n, k, 2 * n + LOGK1);
    for (var i = 0; i < 2; i++)for(var j = 0; j < 2; j++) {
	    for (var idx = 0; idx < k; idx++) {
            noCarry.P[i][j][0][idx] <== P[i][j][0][idx];
            noCarry.P[i][j][1][idx] <== P[i][j][1][idx];
	    }
    }

    for (var i = 0; i < 2; i++) {
        for (var idx = 0; idx < k; idx++) {
            noCarry.Q[i][idx] <== Q[i][idx];
        }
    }
    component reduce[6][2];
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 2; j++) {
            reduce[i][j] = PrimeReduce(n, k, k - 1, q, 3 * n + LOGK2);
        }

        for (var j = 0; j < 2; j++) {
            for (var idx = 0; idx < 2 * k - 1; idx++) {
                reduce[i][j].in[idx] <== noCarry.out[i][j][idx];
            }
        }	
    }

    // max overflow register size is 2k^2 * 2^{3n}
    component carry = SignedFp12CarryModP(n, k, 3 * n + LOGK2, q);
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 2; j++) {
            for (var idx = 0; idx < k; idx++) {
                carry.in[i][j][idx] <== reduce[i][j].out[idx];
            }
        }
    }
    
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 2; j++) {
            for (var idx = 0; idx < k; idx++) {
            out[i][j][idx] <== carry.out[i][j][idx];
            }
        }
    }    
}

// Assuming curve is of form Y^2 = X^3 + b for now (a = 0) for better register bounds 
// Inputs:
//  P is 2 x 2 x k array where P = (x, y) is a point in E(Fp2) 
//  Q is 2 x 6 x 2 x k array representing point (X, Y) in E(Fp12) 
// Output: 
//  out is 6 x 2 x k array representing element of Fp12 equal to:
//  (3x^3 - 2y^2) + w^2 (-3 x^2 X) + w^3 (2 y Y)
template LineFunctionEqualFp2(n, k, q) {
    signal input P[2][2][k];
    signal input Q[2][k];

    signal output out[6][2][k];

    var LOGK2 = log_ceil(12*k*k + 1);
    component noCarry = SignedLineFunctionEqualNoCarryFp2(n, k, 3*n + LOGK2);
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 2; j ++) {
            for (var idx = 0; idx < k; idx++) {
                noCarry.P[i][j][idx] <== P[i][j][idx];
            }
        }
    }

    for (var i = 0; i < 2; i++) {
        for (var idx = 0; idx < k; idx++) {
            noCarry.Q[i][idx] <== Q[i][idx];
        }
    }
    
    var LOGK3 = log_ceil((2*k-1)*12*k*k + 1);
    component reduce[6][4]; 
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 2; j++) {
            reduce[i][j] = PrimeReduce(n, k, 2 * k - 2, q, 4 * n + LOGK3);
        }

        for (var j = 0; j < 2; j++) {
            for (var idx = 0; idx < 3 * k - 2; idx++) {
                reduce[i][j].in[idx] <== noCarry.out[i][j][idx];
            }
        }	
    }

    // max overflow register size is (2k - 1) * 12k^2 * 2^{4n}
    component carry = SignedFp12CarryModP(n, k, 4 * n + LOGK3, q);
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 2; j++) {
            for (var idx = 0; idx < k; idx++) {
                carry.in[i][j][idx] <== reduce[i][j].out[idx];
            }
        }
    }
    
    for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 2; j++) {
            for (var idx = 0; idx < k; idx++) {
            out[i][j][idx] <== carry.out[i][j][idx];
            }
        }
    }    
}


// Input:
//  g is 6 x 2 x kg array representing element of Fp12, allowing overflow and negative
//  P0, P1, Q are as in inputs of SignedLineFunctionUnequalNoCarryFp2
// Assume:
//  all registers of g are in [0, 2^{overflowg}) 
//  all registers of P, Q are in [0, 2^n) 
// Output:
//  out = g * l_{P0, P1}(Q) as element of Fp12 with carry 
//  out is 6 x 2 x k
template Fp12MultiplyWithLineUnequalFp2(n, k, kg, overflowg, q){
    signal input g[6][2][kg];
    signal input P[2][2][2][k];
    signal input Q[2][k];
    signal output out[6][2][k];

    var XI0 = 1;
    var LOGK1 = log_ceil(12*k);
    var LOGK2 = log_ceil(12*k * min(kg, 2*k-1) * 6 * (2+XI0) );
    var LOGK3 = log_ceil( 12*k * min(kg, 2*k-1) * 6 * (2+XI0) * (k + kg - 1) );
    assert( overflowg + 3*n + LOGK3 < 251 );

    component line = SignedLineFunctionUnequalNoCarryFp2(n, k, 2*n + LOGK1); // 6 x 2 x 2k - 1 registers in [0, 12k 2^{2n})
    for(var i=0; i<2; i++)for(var j=0; j<2; j++)for(var l=0; l<2; l++)for(var idx=0; idx<k; idx++)
        line.P[i][j][l][idx] <== P[i][j][l][idx];
    for(var l=0; l<2; l++)for(var idx=0; idx<k; idx++)
        line.Q[l][idx] <== Q[l][idx];
    
    component mult = SignedFp12MultiplyNoCarryUnequal(n, kg, 2*k - 1, overflowg + 2*n + LOGK2); // 6 x 2 x (2k + kg - 2) registers abs val < 12k * min(kg, 2k - 1) * 6 * (2+XI0)* 2^{overflowg + 2n} 
    
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<kg; idx++)
        mult.a[i][j][idx] <== g[i][j][idx];
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<2*k-1; idx++)
        mult.b[i][j][idx] <== line.out[i][j][idx];


    component reduce = Fp12Compress(n, k, k + kg - 2, q, overflowg + 3*n + LOGK3); // 6 x 2 x k registers abs val < 12 k * min(kg, 2k - 1) * 6*(2+XI0) * (k + kg - 1) *  2^{overflowg + 3n} 
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<2*k + kg - 2; idx++)
        reduce.in[i][j][idx] <== mult.out[i][j][idx];
    
    component carry = SignedFp12CarryModP(n, k, overflowg + 3*n + LOGK3, q);

    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        carry.in[i][j][idx] <== reduce.out[i][j][idx];

    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        out[i][j][idx] <== carry.out[i][j][idx];
}

// Assuming curve is of form Y^2 = X^3 + b for now (a = 0) for better register bounds 
// b is complex
// Inputs:
//  P is 2 x 2 x k array where P = (x, y) is a point in E[r](Fq2) 
//  Q is 2 x k array representing point (X, Y) in E(Fq) 
// Output:
//  out = f_x(P,Q) is 6 x 2 x k, where we start with f_0(P,Q) = in and use Miller's algorithm f_{i+j} = f_i * f_j * l_{i,j}(P,Q)
//  xP = [x]P is 2 x 2 x k array
// Assume:
//  r is prime (not a parameter in this template)
//  x in [0, 2^250) and x < r  (we will use this template when x has few significant bits in base 2)
//  q has k registers in [0, 2^n)
//  P != O so the order of P in E(Fq) is r, so [i]P != [j]P for i != j in Z/r 
//  X^3 + b = 0 has no solution in Fq2, i.e., the y-coordinate of P cannot be 0.
template MillerLoopFp2(n, k, b, x, q){
    signal input P[2][2][k]; 
    signal input Q[2][k];

    signal output out[6][2][k];
    signal output xP[2][2][k];

    var LOGK = log_ceil(k);
    var XI0 = 1;
    var LOGK2 = log_ceil(36*(2+XI0)*(2+XI0) * k*k);
    var LOGK3 = log_ceil(36*(2+XI0)*(2+XI0) * k*k*(2*k-1));
    assert( 4*n + LOGK3 < 251 );
    
    var BITS[250]; 
    var BIT_LENGTH;
    var SIG_BITS=0;
    for (var i = 0; i < 250; i++) {
        BITS[i] = (x >> i) & 1;
        if(BITS[i] == 1){
            SIG_BITS++;
            BIT_LENGTH = i + 1;
        }
    }

    signal R[BIT_LENGTH][2][2][k]; 
    signal f[BIT_LENGTH][6][2][k];

    component pDouble[BIT_LENGTH];
    component fDouble[BIT_LENGTH];
    component square[BIT_LENGTH];
    component line[BIT_LENGTH];
    component compress[BIT_LENGTH];
    component noCarry[BIT_LENGTH];
    component pAdd[SIG_BITS];
    component fAdd[SIG_BITS]; 
    var CUR_ID=0;

    for(var i=BIT_LENGTH - 1; i>=0; i--){
        if( i == BIT_LENGTH - 1 ){
            // f = 1 
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
                if(l==0 && j==0 && idx==0)
                    f[i][l][j][idx] <== 1;
                else    
                    f[i][l][j][idx] <== 0;
            }
            for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++)
                R[i][j][l][idx] <== P[j][l][idx];
        }else{
            // compute fDouble[i] = f[i+1]^2 * l_{R[i+1], R[i+1]}(Q) 
            square[i] = SignedFp12MultiplyNoCarry(n, k, 2*n + 4 + LOGK); // 6 x 2 x 2k-1 registers in [0, 6 * k * (2+XI0) * 2^{2n} )
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
                square[i].a[l][j][idx] <== f[i+1][l][j][idx];
                square[i].b[l][j][idx] <== f[i+1][l][j][idx];
            }
            
            line[i] = LineFunctionEqualFp2(n, k, q); // 6 x 2 x k registers in [0, 2^n) 
            for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++)
                line[i].P[j][l][idx] <== R[i+1][j][l][idx];            
            for(var eps=0; eps<2; eps++)
                for(var idx=0; idx<k; idx++)
                    line[i].Q[eps][idx] <== Q[eps][idx];
            
            noCarry[i] = SignedFp12MultiplyNoCarryUnequal(n, 2*k-1, k, 3*n + LOGK2); // 6 x 2 x 3k-2 registers < (6 * (2+XI0))^2 * k^2 * 2^{3n} ) 
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<2*k-1; idx++)
                noCarry[i].a[l][j][idx] <== square[i].out[l][j][idx];
            
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                noCarry[i].b[l][j][idx] <== line[i].out[l][j][idx];
            
            compress[i] = Fp12Compress(n, k, 2*k-2, q, 4*n + LOGK3); // 6 x 2 x k registers < (6 * (2+ XI0))^2 * k^2 * (2k-1) * 2^{4n} )
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<3*k-2; idx++)
                compress[i].in[l][j][idx] <== noCarry[i].out[l][j][idx];
            
            fDouble[i] = SignedFp12CarryModP(n, k, 4*n + LOGK3, q);
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                fDouble[i].in[l][j][idx] <== compress[i].out[l][j][idx]; 
            
            pDouble[i] = EllipticCurveDoubleFp2(n, k, [0,0], b, q);  
            for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++)
                pDouble[i].in[j][l][idx] <== R[i+1][j][l][idx]; 
            
            if(BITS[i] == 0){
                for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    f[i][l][j][idx] <== fDouble[i].out[l][j][idx]; 
                for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++)
                    R[i][j][l][idx] <== pDouble[i].out[j][l][idx];
            }else{
                fAdd[CUR_ID] = Fp12MultiplyWithLineUnequalFp2(n, k, k, n, q); 
                for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    fAdd[CUR_ID].g[l][j][idx] <== fDouble[i].out[l][j][idx];
                
                for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++){
                    fAdd[CUR_ID].P[0][j][l][idx] <== pDouble[i].out[j][l][idx];            
                    fAdd[CUR_ID].P[1][j][l][idx] <== P[j][l][idx];            
                }
                for(var eps=0; eps<2; eps++)for(var idx=0; idx<k; idx++)
                    fAdd[CUR_ID].Q[eps][idx] <== Q[eps][idx];

                for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    f[i][l][j][idx] <== fAdd[CUR_ID].out[l][j][idx]; 

                // pAdd[CUR_ID] = pDouble[i] + P 
                pAdd[CUR_ID] = EllipticCurveAddUnequalFp2(n, k, q); 
                for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++){
                    pAdd[CUR_ID].a[j][l][idx] <== pDouble[i].out[j][l][idx];
                    pAdd[CUR_ID].b[j][l][idx] <== P[j][l][idx];
                }

                for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++)
                    R[i][j][l][idx] <== pAdd[CUR_ID].out[j][l][idx];
                
                CUR_ID++;
            }
        }
    }
    for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        out[l][j][idx] <== f[0][l][j][idx];
    for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++)
        xP[j][l][idx] <== R[0][j][l][idx]; 
}


// Assuming curve is of form Y^2 = X^3 + b for now (a = 0) for better register bounds 
// b is complex
// Inputs:
//  P is 2 x 2 x 2 x k array where P[i] = (x_i, y_i) is a point in E[r](Fq2) 
//  Q is 2 x 2 x k array representing point (X_i, Y_i) in E(Fq) 
// Output:
//  out = f_x(P_0,Q_0) f_x(P_1, Q_1) is 6 x 2 x k, where we start with f_0(P,Q) = in and use Miller's algorithm f_{i+j} = f_i * f_j * l_{i,j}(P,Q)
// Assume:
//  r is prime (not a parameter in this template)
//  x in [0, 2^250) and x < r  (we will use this template when x has few significant bits in base 2)
//  q has k registers in [0, 2^n)
//  P != O so the order of P in E(Fq) is r, so [i]P != [j]P for i != j in Z/r 
//  X^3 + b = 0 has no solution in Fq2, i.e., the y-coordinate of P cannot be 0.
template MillerLoopFp2Two(n, k, b, x, q){
    signal input P[2][2][2][k]; 
    signal input Q[2][2][k];

    signal output out[6][2][k];

    var LOGK = log_ceil(k);
    var XI0 = 1;
    var LOGK2 = log_ceil(36*(2+XI0)*(2+XI0) * k*k);
    var LOGK3 = log_ceil(36*(2+XI0)*(2+XI0) * k*k*(2*k-1));
    assert( 4*n + LOGK3 < 251 );
    
    var BITS[250]; // length is k * n
    var BIT_LENGTH;
    var SIG_BITS=0;
    for (var i = 0; i < 250; i++) {
        BITS[i] = (x >> i) & 1;
        if(BITS[i] == 1){
            SIG_BITS++;
            BIT_LENGTH = i + 1;
        }
    }

    signal R[BIT_LENGTH][2][2][2][k]; 
    signal f[BIT_LENGTH][6][2][k];

    component pDouble[BIT_LENGTH][2];
    component fdouble_0[BIT_LENGTH];
    component fDouble[BIT_LENGTH];
    component square[BIT_LENGTH];
    component line[BIT_LENGTH][2];
    component compress[BIT_LENGTH];
    component noCarry[BIT_LENGTH];
    component pAdd[SIG_BITS][2];
    component fAdd[SIG_BITS][2]; 
    var CUR_ID=0;

    for(var i=BIT_LENGTH - 1; i>=0; i--){
        if( i == BIT_LENGTH - 1 ){
            // f = 1 
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
                if(l==0 && j==0 && idx==0)
                    f[i][l][j][idx] <== 1;
                else    
                    f[i][l][j][idx] <== 0;
            }
            for(var idP=0; idP<2; idP++)
                for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++)
                    R[i][idP][j][l][idx] <== P[idP][j][l][idx];
        }else{
            // compute fDouble[i] = (f[i+1]^2 * l_{R[i+1][0], R[i+1][0]}(Q[0])) * l_{R[i+1][1], R[i+1][1]}(Q[1])
            square[i] = SignedFp12MultiplyNoCarry(n, k, 2*n + 4 + LOGK); // 6 x 2 x 2k-1 registers in [0, 6 * k * (2+XI0) * 2^{2n} )
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
                square[i].a[l][j][idx] <== f[i+1][l][j][idx];
                square[i].b[l][j][idx] <== f[i+1][l][j][idx];
            }
            for(var idP=0; idP<2; idP++){
                line[i][idP] = LineFunctionEqualFp2(n, k, q); // 6 x 2 x k registers in [0, 2^n) 
                for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++)
                    line[i][idP].P[j][l][idx] <== R[i+1][idP][j][l][idx];            
                for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    line[i][idP].Q[j][idx] <== Q[idP][j][idx];

                pDouble[i][idP] = EllipticCurveDoubleFp2(n, k, [0,0], b, q);  
                for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++)
                    pDouble[i][idP].in[j][l][idx] <== R[i+1][idP][j][l][idx]; 
            }
            
            noCarry[i] = SignedFp12MultiplyNoCarryUnequal(n, 2*k-1, k, 3*n + LOGK2); // 6 x 2 x 3k-2 registers < (6 * (2+XI0))^2 * k^2 * 2^{3n} ) 
            for(var l=0; l<6; l++)for(var j=0; j<2; j++){
                for(var idx=0; idx<2*k-1; idx++)
                    noCarry[i].a[l][j][idx] <== square[i].out[l][j][idx];
                for(var idx=0; idx<k; idx++)
                    noCarry[i].b[l][j][idx] <== line[i][0].out[l][j][idx];
            }
            
            compress[i] = Fp12Compress(n, k, 2*k-2, q, 4*n + LOGK3); // 6 x 2 x k registers < (6 * (2+ XI0))^2 * k^2 * (2k-1) * 2^{4n} )
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<3*k-2; idx++)
                compress[i].in[l][j][idx] <== noCarry[i].out[l][j][idx];
            
            fdouble_0[i] = SignedFp12CarryModP(n, k, 4*n + LOGK3, q);
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                fdouble_0[i].in[l][j][idx] <== compress[i].out[l][j][idx]; 
            
            fDouble[i] = Fp12Multiply(n, k, q);
            for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
                fDouble[i].a[l][j][idx] <== fdouble_0[i].out[l][j][idx];
                fDouble[i].b[l][j][idx] <== line[i][1].out[l][j][idx];
            }

            if(BITS[i] == 0){
                for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    f[i][l][j][idx] <== fDouble[i].out[l][j][idx]; 
                for(var idP=0; idP<2; idP++)
                    for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++)
                        R[i][idP][j][l][idx] <== pDouble[i][idP].out[j][l][idx];
            }else{
                for(var idP=0; idP<2; idP++){
                    fAdd[CUR_ID][idP] = Fp12MultiplyWithLineUnequalFp2(n, k, k, n, q); 
                    for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++){
                        if(idP == 0)
                            fAdd[CUR_ID][idP].g[l][j][idx] <== fDouble[i].out[l][j][idx];
                        else
                            fAdd[CUR_ID][idP].g[l][j][idx] <== fAdd[CUR_ID][idP-1].out[l][j][idx];
                    }
                
                    for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++){
                        fAdd[CUR_ID][idP].P[0][j][l][idx] <== pDouble[i][idP].out[j][l][idx]; 
                        fAdd[CUR_ID][idP].P[1][j][l][idx] <== P[idP][j][l][idx];            
                    }
                    for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                        fAdd[CUR_ID][idP].Q[j][idx] <== Q[idP][j][idx];

                    // pAdd[CUR_ID][idP] = pDouble[i][idP] + P[idP] 
                    pAdd[CUR_ID][idP] = EllipticCurveAddUnequalFp2(n, k, q); 
                    for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++){
                        pAdd[CUR_ID][idP].a[j][l][idx] <== pDouble[i][idP].out[j][l][idx];
                        pAdd[CUR_ID][idP].b[j][l][idx] <== P[idP][j][l][idx];
                    }

                    for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)for(var l=0; l<2; l++)
                        R[i][idP][j][l][idx] <== pAdd[CUR_ID][idP].out[j][l][idx];
                
                }
                for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
                    f[i][l][j][idx] <== fAdd[CUR_ID][1].out[l][j][idx]; 

                CUR_ID++;
            }
        }
    }
    for(var l=0; l<6; l++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        out[l][j][idx] <== f[0][l][j][idx];
}

template OptimalAtePairing(n, k, q){
    signal input P[2][2][k]; 
    signal input Q[2][k];
    signal output out[6][2][k];

    var x = get_BLS12_381_parameter();

    signal negP[2][2][k]; // (x, -y) mod q
    // currently EllipticCurveDoubleFp2 relies on 0 <= in < p so we cannot pass a negative number for negP
    component neg[2];
    for(var j=0; j<2; j++){
        neg[j] = FpNegate(n, k, q); 
        for(var idx=0; idx<k; idx++)
            neg[j].in[idx] <== P[1][j][idx];
        for(var idx=0; idx<k; idx++){
            negP[0][j][idx] <== P[0][j][idx];
            negP[1][j][idx] <== neg[j].out[idx];
        }
    }
    component miller = MillerLoopFp2(n, k, [4,4], x, q);
    for(var i=0; i<2; i++)for(var j=0; j <2; j++)for(var idx=0; idx<k; idx++)
        miller.P[i][j][idx] <== negP[i][j][idx];
    for(var i=0; i<2; i++)for(var idx=0; idx<k; idx++)
        miller.Q[i][idx] <== Q[i][idx];
    /*for(var i = 0; i <6; i ++)for(var j = 0; j < 2; j++)for(var l = 0; l < k; l++) {
        if (i==0 && j == 0 && l == 0) {
            miller.in[i][j][l] <== 1;
        }
        else {
            miller.in[i][j][l] <== 0;
        }
    }*/
    
    component finalexp = FinalExponentiate(n, k, q);
    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        finalexp.in[i][j][idx] <== miller.out[i][j][idx];

    for(var i=0; i<6; i++)for(var j=0; j<2; j++)for(var idx=0; idx<k; idx++)
        out[i][j][idx] <== finalexp.out[i][j][idx]; 

    /*
    // check out[i][j] < p since we never did that previously
    component lt[6][2];
    for(var i=0; i<6; i++)for(var j=0; j<2; j++){
        lt[i][j] = BigLessThan(n, k);
        for(var idx=0; idx<k; idx++){
            lt[i][j].a[idx] <== out[i][j][idx];
            lt[i][j].b[idx] <== q[idx];
        }
        lt[i][j].out === 1;
    }*/
}

