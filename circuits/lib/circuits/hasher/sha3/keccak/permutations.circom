pragma circom 2.1.6;

include "./utils.circom";

template D(n, shift_left, shift_right) {
    
    var WORD_SIZE = 64;

    signal input a[n];
    signal input b[n];
    signal output out[n];
    
    component aux0 = ShiftRight(WORD_SIZE, shift_right);
    for (var i = 0; i < WORD_SIZE; i++) {
        aux0.in[i] <== a[i];
    }
    component aux1 = ShiftLeft(WORD_SIZE, shift_left);
    for (var i = 0; i < WORD_SIZE; i++) {
        aux1.in[i] <== a[i];
    }
    component aux2 = OrArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        aux2.a[i] <== aux0.out[i];
        aux2.b[i] <== aux1.out[i];
    }
    component aux3 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        aux3.a[i] <== b[i];
        aux3.b[i] <== aux2.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[i] <== aux3.out[i];
    }
}

template Theta() {

    var WORD_SIZE = 64;
    var STATE_SIZE = WORD_SIZE * 25;

    signal input in[STATE_SIZE];
    signal output out[STATE_SIZE];
    
    component c0 = Xor5(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        c0.a[i] <== in[i];
        c0.b[i] <== in[5 * WORD_SIZE + i];
        c0.c[i] <== in[10 * WORD_SIZE + i];
        c0.d[i] <== in[15 * WORD_SIZE + i];
        c0.e[i] <== in[20 * WORD_SIZE + i];
    }
    
    component c1 = Xor5(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        c1.a[i] <== in[1 * WORD_SIZE + i];
        c1.b[i] <== in[6 * WORD_SIZE + i];
        c1.c[i] <== in[11 * WORD_SIZE + i];
        c1.d[i] <== in[16 * WORD_SIZE + i];
        c1.e[i] <== in[21 * WORD_SIZE + i];
    }
    
    component c2 = Xor5(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        c2.a[i] <== in[2 * WORD_SIZE + i];
        c2.b[i] <== in[7 * WORD_SIZE + i];
        c2.c[i] <== in[12 * WORD_SIZE + i];
        c2.d[i] <== in[17 * WORD_SIZE + i];
        c2.e[i] <== in[22 * WORD_SIZE + i];
    }
    
    component c3 = Xor5(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        c3.a[i] <== in[3 * WORD_SIZE + i];
        c3.b[i] <== in[8 * WORD_SIZE + i];
        c3.c[i] <== in[13 * WORD_SIZE + i];
        c3.d[i] <== in[18 * WORD_SIZE + i];
        c3.e[i] <== in[23 * WORD_SIZE + i];
    }
    
    component c4 = Xor5(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        c4.a[i] <== in[4 * WORD_SIZE + i];
        c4.b[i] <== in[9 * WORD_SIZE + i];
        c4.c[i] <== in[14 * WORD_SIZE + i];
        c4.d[i] <== in[19 * WORD_SIZE + i];
        c4.e[i] <== in[24 * WORD_SIZE + i];
    }
    
    component d0 = D(WORD_SIZE, 1, WORD_SIZE - 1);
    for (var i = 0; i < WORD_SIZE; i++) {
        d0.a[i] <== c1.out[i];
        d0.b[i] <== c4.out[i];
    }
    component r0 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r0.a[i] <== in[i];
        r0.b[i] <== d0.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[i] <== r0.out[i];
    }
    component r5 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r5.a[i] <== in[5 * WORD_SIZE + i];
        r5.b[i] <== d0.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[5 * WORD_SIZE + i] <== r5.out[i];
    }
    component r10 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r10.a[i] <== in[10 * WORD_SIZE + i];
        r10.b[i] <== d0.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[10 * WORD_SIZE + i] <== r10.out[i];
    }
    component r15 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r15.a[i] <== in[15 * WORD_SIZE + i];
        r15.b[i] <== d0.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[15 * WORD_SIZE + i] <== r15.out[i];
    }
    component r20 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r20.a[i] <== in[20 * WORD_SIZE + i];
        r20.b[i] <== d0.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[20 * WORD_SIZE + i] <== r20.out[i];
    }
    
    component d1 = D(WORD_SIZE, 1, WORD_SIZE - 1);
    for (var i = 0; i < WORD_SIZE; i++) {
        d1.a[i] <== c2.out[i];
        d1.b[i] <== c0.out[i];
    }

    component r1 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r1.a[i] <== in[1 * WORD_SIZE + i];
        r1.b[i] <== d1.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[1 * WORD_SIZE + i] <== r1.out[i];
    }

    component r6 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r6.a[i] <== in[6 * WORD_SIZE + i];
        r6.b[i] <== d1.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[6 * WORD_SIZE + i] <== r6.out[i];
    }
    component r11 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r11.a[i] <== in[11 * WORD_SIZE + i];
        r11.b[i] <== d1.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[11 * WORD_SIZE + i] <== r11.out[i];
    }
    component r16 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r16.a[i] <== in[16 * WORD_SIZE + i];
        r16.b[i] <== d1.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[16 * WORD_SIZE + i] <== r16.out[i];
    }
    component r21 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r21.a[i] <== in[21 * WORD_SIZE + i];
        r21.b[i] <== d1.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[21 * WORD_SIZE + i] <== r21.out[i];
    }
    
    component d2 = D(WORD_SIZE, 1, WORD_SIZE - 1);
    for (var i = 0; i < WORD_SIZE; i++) {
        d2.a[i] <== c3.out[i];
        d2.b[i] <== c1.out[i];
    }
    component r2 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r2.a[i] <== in[2 * WORD_SIZE + i];
        r2.b[i] <== d2.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[2 * WORD_SIZE + i] <== r2.out[i];
    }
    component r7 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r7.a[i] <== in[7 * WORD_SIZE + i];
        r7.b[i] <== d2.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[7 * WORD_SIZE + i] <== r7.out[i];
    }
    component r12 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r12.a[i] <== in[12 * WORD_SIZE + i];
        r12.b[i] <== d2.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[12 * WORD_SIZE + i] <== r12.out[i];
    }
    component r17 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r17.a[i] <== in[17 * WORD_SIZE + i];
        r17.b[i] <== d2.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[17 * WORD_SIZE + i] <== r17.out[i];
    }
    component r22 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r22.a[i] <== in[22 * WORD_SIZE + i];
        r22.b[i] <== d2.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[22 * WORD_SIZE + i] <== r22.out[i];
    }
    
    component d3 = D(WORD_SIZE, 1, WORD_SIZE - 1);
    for (var i = 0; i < WORD_SIZE; i++) {
        d3.a[i] <== c4.out[i];
        d3.b[i] <== c2.out[i];
    }
    component r3 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r3.a[i] <== in[3 * WORD_SIZE + i];
        r3.b[i] <== d3.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[3 * WORD_SIZE + i] <== r3.out[i];
    }
    component r8 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r8.a[i] <== in[8 * WORD_SIZE + i];
        r8.b[i] <== d3.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[8 * WORD_SIZE + i] <== r8.out[i];
    }
    component r13 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r13.a[i] <== in[13 * WORD_SIZE + i];
        r13.b[i] <== d3.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[13 * WORD_SIZE + i] <== r13.out[i];
    }
    component r18 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r18.a[i] <== in[18 * WORD_SIZE + i];
        r18.b[i] <== d3.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[18 * WORD_SIZE + i] <== r18.out[i];
    }
    component r23 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r23.a[i] <== in[23 * WORD_SIZE + i];
        r23.b[i] <== d3.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[23 * WORD_SIZE + i] <== r23.out[i];
    }
    
    component d4 = D(WORD_SIZE, 1, WORD_SIZE - 1);
    for (var i = 0; i < WORD_SIZE; i++) {
        d4.a[i] <== c0.out[i];
        d4.b[i] <== c3.out[i];
    }
    component r4 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r4.a[i] <== in[4 * WORD_SIZE + i];
        r4.b[i] <== d4.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[4 * WORD_SIZE + i] <== r4.out[i];
    }
    component r9 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r9.a[i] <== in[9 * WORD_SIZE + i];
        r9.b[i] <== d4.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[9 * WORD_SIZE + i] <== r9.out[i];
    }
    component r14 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r14.a[i] <== in[14 * WORD_SIZE + i];
        r14.b[i] <== d4.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[14 * WORD_SIZE + i] <== r14.out[i];
    }
    component r19 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r19.a[i] <== in[19 * WORD_SIZE + i];
        r19.b[i] <== d4.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[19 * WORD_SIZE + i] <== r19.out[i];
    }
    component r24 = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        r24.a[i] <== in[24 * WORD_SIZE + i];
        r24.b[i] <== d4.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[24 * WORD_SIZE + i] <== r24.out[i];
    }
}


template stepRhoPi(shift_left, shift_right) {

    var WORD_SIZE = 64;

    signal input a[WORD_SIZE];
    signal output out[WORD_SIZE];

    
    component aux0 = ShiftRight(WORD_SIZE, shift_right);
    for (var i = 0; i < WORD_SIZE; i++) {
        aux0.in[i] <== a[i];
    }
    component aux1 = ShiftLeft(WORD_SIZE, shift_left);
    for (var i = 0; i < WORD_SIZE; i++) {
        aux1.in[i] <== a[i];
    }
    component aux2 = OrArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        aux2.a[i] <== aux0.out[i];
        aux2.b[i] <== aux1.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[i] <== aux2.out[i];
    }
}

template RhoPi() {

    var WORD_SIZE = 64;
    var STATE_SIZE = WORD_SIZE * 25;

    signal input in[STATE_SIZE];
    signal output out[STATE_SIZE];
    
    component s10 = stepRhoPi(1, WORD_SIZE - 1);
    for (var i = 0; i < WORD_SIZE; i++) {
        s10.a[i] <== in[1 * WORD_SIZE + i];
    }
    component s7 = stepRhoPi(3, WORD_SIZE - 3);
    for (var i = 0; i < WORD_SIZE; i++) {
        s7.a[i] <== in[10 * WORD_SIZE + i];
    }
    component s11 = stepRhoPi(6, WORD_SIZE - 6);
    for (var i = 0; i < WORD_SIZE; i++) {
        s11.a[i] <== in[7 * WORD_SIZE + i];
    }
    component s17 = stepRhoPi(10, WORD_SIZE - 10);
    for (var i = 0; i < WORD_SIZE; i++) {
        s17.a[i] <== in[11 * WORD_SIZE + i];
    }
    component s18 = stepRhoPi(15, WORD_SIZE - 15);
    for (var i = 0; i < WORD_SIZE; i++) {
        s18.a[i] <== in[17 * WORD_SIZE + i];
    }
    component s3 = stepRhoPi(21, WORD_SIZE - 21);
    for (var i = 0; i < WORD_SIZE; i++) {
        s3.a[i] <== in[18 * WORD_SIZE + i];
    }
    component s5 = stepRhoPi(28, WORD_SIZE - 28);
    for (var i = 0; i < WORD_SIZE; i++) {
        s5.a[i] <== in[3 * WORD_SIZE + i];
    }
    component s16 = stepRhoPi(36, WORD_SIZE - 36);
    for (var i = 0; i < WORD_SIZE; i++) {
        s16.a[i] <== in[5 * WORD_SIZE + i];
    }
    component s8 = stepRhoPi(45, WORD_SIZE - 45);
    for (var i = 0; i < WORD_SIZE; i++) {
        s8.a[i] <== in[16 * WORD_SIZE + i];
    }
    component s21 = stepRhoPi(55, WORD_SIZE - 55);
    for (var i = 0; i < WORD_SIZE; i++) {
        s21.a[i] <== in[8 * WORD_SIZE + i];
    }
    component s24 = stepRhoPi(2, WORD_SIZE - 2);
    for (var i = 0; i < WORD_SIZE; i++) {
        s24.a[i] <== in[21 * WORD_SIZE + i];
    }
    component s4 = stepRhoPi(14, WORD_SIZE - 14);
    for (var i = 0; i < WORD_SIZE; i++) {
        s4.a[i] <== in[24 * WORD_SIZE + i];
    }
    component s15 = stepRhoPi(27, WORD_SIZE - 27);
    for (var i = 0; i < WORD_SIZE; i++) {
        s15.a[i] <== in[4 * WORD_SIZE + i];
    }
    component s23 = stepRhoPi(41, WORD_SIZE - 41);
    for (var i = 0; i < WORD_SIZE; i++) {
        s23.a[i] <== in[15 * WORD_SIZE + i];
    }
    component s19 = stepRhoPi(56, WORD_SIZE - 56);
    for (var i = 0; i < WORD_SIZE; i++) {
        s19.a[i] <== in[23 * WORD_SIZE + i];
    }
    component s13 = stepRhoPi(8, WORD_SIZE - 8);
    for (var i = 0; i < WORD_SIZE; i++) {
        s13.a[i] <== in[19 * WORD_SIZE + i];
    }
    component s12 = stepRhoPi(25, WORD_SIZE - 25);
    for (var i = 0; i < WORD_SIZE; i++) {
        s12.a[i] <== in[13 * WORD_SIZE + i];
    }
    component s2 = stepRhoPi(43, WORD_SIZE - 43);
    for (var i = 0; i < WORD_SIZE; i++) {
        s2.a[i] <== in[12 * WORD_SIZE + i];
    }
    component s20 = stepRhoPi(62, WORD_SIZE - 62);
    for (var i = 0; i < WORD_SIZE; i++) {
        s20.a[i] <== in[2 * WORD_SIZE + i];
    }
    component s14 = stepRhoPi(18, WORD_SIZE - 18);
    for (var i = 0; i < WORD_SIZE; i++) {
        s14.a[i] <== in[20 * WORD_SIZE + i];
    }
    component s22 = stepRhoPi(39, WORD_SIZE - 39);
    for (var i = 0; i < WORD_SIZE; i++) {
        s22.a[i] <== in[14 * WORD_SIZE + i];
    }
    component s9 = stepRhoPi(61, WORD_SIZE - 61);
    for (var i = 0; i < WORD_SIZE; i++) {
        s9.a[i] <== in[22 * WORD_SIZE + i];
    }
    component s6 = stepRhoPi(20, WORD_SIZE - 20);
    for (var i = 0; i < WORD_SIZE; i++) {
        s6.a[i] <== in[9 * WORD_SIZE + i];
    }
    component s1 = stepRhoPi(44, WORD_SIZE - 44);
    for (var i = 0; i < WORD_SIZE; i++) {
        s1.a[i] <== in[6 * WORD_SIZE + i];
    }
    
    for (var i = 0; i < WORD_SIZE; i++) {
        out[i] <== in[i];
        out[10 * WORD_SIZE + i] <== s10.out[i];
        out[7 * WORD_SIZE + i] <== s7.out[i];
        out[11 * WORD_SIZE + i] <== s11.out[i];
        out[17 * WORD_SIZE + i] <== s17.out[i];
        out[18 * WORD_SIZE + i] <== s18.out[i];
        out[3 * WORD_SIZE + i] <== s3.out[i];
        out[5 * WORD_SIZE + i] <== s5.out[i];
        out[16 * WORD_SIZE + i] <== s16.out[i];
        out[8 * WORD_SIZE + i] <== s8.out[i];
        out[21 * WORD_SIZE + i] <== s21.out[i];
        out[24 * WORD_SIZE + i] <== s24.out[i];
        out[4 * WORD_SIZE + i] <== s4.out[i];
        out[15 * WORD_SIZE + i] <== s15.out[i];
        out[23 * WORD_SIZE + i] <== s23.out[i];
        out[19 * WORD_SIZE + i] <== s19.out[i];
        out[13 * WORD_SIZE + i] <== s13.out[i];
        out[12 * WORD_SIZE + i] <== s12.out[i];
        out[2 * WORD_SIZE + i] <== s2.out[i];
        out[20 * WORD_SIZE + i] <== s20.out[i];
        out[14 * WORD_SIZE + i] <== s14.out[i];
        out[22 * WORD_SIZE + i] <== s22.out[i];
        out[9 * WORD_SIZE + i] <== s9.out[i];
        out[6 * WORD_SIZE + i] <== s6.out[i];
        out[1 * WORD_SIZE + i] <== s1.out[i];
    }
}


template stepChi() {

    var WORD_SIZE = 64;

    signal input a[WORD_SIZE];
    signal input b[WORD_SIZE];
    signal input c[WORD_SIZE];
    signal output out[WORD_SIZE];

    
    component bXor = XorArraySingle(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        bXor.a[i] <== b[i];
    }
    component bc = AndArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        bc.a[i] <== bXor.out[i];
        bc.b[i] <== c[i];
    }
    component abc = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        abc.a[i] <== a[i];
        abc.b[i] <== bc.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[i] <== abc.out[i];
    }
}

template Chi() {

    var WORD_SIZE = 64;
    var STATE_SIZE = WORD_SIZE * 25;

    signal input in[STATE_SIZE];
    signal output out[STATE_SIZE];
    
    component r0 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r0.a[i] <== in[i];
        r0.b[i] <== in[1 * WORD_SIZE + i];
        r0.c[i] <== in[2 * WORD_SIZE + i];
    }
    component r1 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r1.a[i] <== in[1 * WORD_SIZE + i];
        r1.b[i] <== in[2 * WORD_SIZE + i];
        r1.c[i] <== in[3 * WORD_SIZE + i];
    }
    component r2 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r2.a[i] <== in[2 * WORD_SIZE + i];
        r2.b[i] <== in[3 * WORD_SIZE + i];
        r2.c[i] <== in[4 * WORD_SIZE + i];
    }
    component r3 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r3.a[i] <== in[3 * WORD_SIZE + i];
        r3.b[i] <== in[4 * WORD_SIZE + i];
        r3.c[i] <== in[0 * WORD_SIZE + i];
    }
    component r4 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r4.a[i] <== in[4 * WORD_SIZE + i];
        r4.b[i] <== in[i];
        r4.c[i] <== in[1 * WORD_SIZE + i];
    }
    
    component r5 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r5.a[i] <== in[5 * WORD_SIZE + i];
        r5.b[i] <== in[6 * WORD_SIZE + i];
        r5.c[i] <== in[7 * WORD_SIZE + i];
    }
    component r6 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r6.a[i] <== in[6 * WORD_SIZE + i];
        r6.b[i] <== in[7 * WORD_SIZE + i];
        r6.c[i] <== in[8 * WORD_SIZE + i];
    }
    component r7 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r7.a[i] <== in[7 * WORD_SIZE + i];
        r7.b[i] <== in[8 * WORD_SIZE + i];
        r7.c[i] <== in[9 * WORD_SIZE + i];
    }
    component r8 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r8.a[i] <== in[8 * WORD_SIZE + i];
        r8.b[i] <== in[9 * WORD_SIZE + i];
        r8.c[i] <== in[5 * WORD_SIZE + i];
    }
    component r9 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r9.a[i] <== in[9 * WORD_SIZE + i];
        r9.b[i] <== in[5 * WORD_SIZE + i];
        r9.c[i] <== in[6 * WORD_SIZE + i];
    }
    
    component r10 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r10.a[i] <== in[10 * WORD_SIZE + i];
        r10.b[i] <== in[11 * WORD_SIZE + i];
        r10.c[i] <== in[12 * WORD_SIZE + i];
    }
    component r11 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r11.a[i] <== in[11 * WORD_SIZE + i];
        r11.b[i] <== in[12 * WORD_SIZE + i];
        r11.c[i] <== in[13 * WORD_SIZE + i];
    }
    component r12 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r12.a[i] <== in[12 * WORD_SIZE + i];
        r12.b[i] <== in[13 * WORD_SIZE + i];
        r12.c[i] <== in[14 * WORD_SIZE + i];
    }
    component r13 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r13.a[i] <== in[13 * WORD_SIZE + i];
        r13.b[i] <== in[14 * WORD_SIZE + i];
        r13.c[i] <== in[10 * WORD_SIZE + i];
    }
    component r14 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r14.a[i] <== in[14 * WORD_SIZE + i];
        r14.b[i] <== in[10 * WORD_SIZE + i];
        r14.c[i] <== in[11 * WORD_SIZE + i];
    }
    
    component r15 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r15.a[i] <== in[15 * WORD_SIZE + i];
        r15.b[i] <== in[16 * WORD_SIZE + i];
        r15.c[i] <== in[17 * WORD_SIZE + i];
    }
    component r16 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r16.a[i] <== in[16 * WORD_SIZE + i];
        r16.b[i] <== in[17 * WORD_SIZE + i];
        r16.c[i] <== in[18 * WORD_SIZE + i];
    }
    component r17 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r17.a[i] <== in[17 * WORD_SIZE + i];
        r17.b[i] <== in[18 * WORD_SIZE + i];
        r17.c[i] <== in[19 * WORD_SIZE + i];
    }
    component r18 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r18.a[i] <== in[18 * WORD_SIZE + i];
        r18.b[i] <== in[19 * WORD_SIZE + i];
        r18.c[i] <== in[15 * WORD_SIZE + i];
    }
    component r19 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r19.a[i] <== in[19 * WORD_SIZE + i];
        r19.b[i] <== in[15 * WORD_SIZE + i];
        r19.c[i] <== in[16 * WORD_SIZE + i];
    }
    
    component r20 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r20.a[i] <== in[20 * WORD_SIZE + i];
        r20.b[i] <== in[21 * WORD_SIZE + i];
        r20.c[i] <== in[22 * WORD_SIZE + i];
    }
    component r21 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r21.a[i] <== in[21 * WORD_SIZE + i];
        r21.b[i] <== in[22 * WORD_SIZE + i];
        r21.c[i] <== in[23 * WORD_SIZE + i];
    }
    component r22 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r22.a[i] <== in[22 * WORD_SIZE + i];
        r22.b[i] <== in[23 * WORD_SIZE + i];
        r22.c[i] <== in[24 * WORD_SIZE + i];
    }
    component r23 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r23.a[i] <== in[23 * WORD_SIZE + i];
        r23.b[i] <== in[24 * WORD_SIZE + i];
        r23.c[i] <== in[20 * WORD_SIZE + i];
    }
    component r24 = stepChi();
    for (var i = 0; i < WORD_SIZE; i++) {
        r24.a[i] <== in[24 * WORD_SIZE + i];
        r24.b[i] <== in[20 * WORD_SIZE + i];
        r24.c[i] <== in[21 * WORD_SIZE + i];
    }
    
    for (var i = 0; i < WORD_SIZE; i++) {
        out[i] <== r0.out[i];
        out[1 * WORD_SIZE + i] <== r1.out[i];
        out[2 * WORD_SIZE + i] <== r2.out[i];
        out[3 * WORD_SIZE + i] <== r3.out[i];
        out[4 * WORD_SIZE + i] <== r4.out[i];
        
        out[5 * WORD_SIZE + i] <== r5.out[i];
        out[6 * WORD_SIZE + i] <== r6.out[i];
        out[7 * WORD_SIZE + i] <== r7.out[i];
        out[8 * WORD_SIZE + i] <== r8.out[i];
        out[9 * WORD_SIZE + i] <== r9.out[i];
        
        out[10 * WORD_SIZE + i] <== r10.out[i];
        out[11 * WORD_SIZE + i] <== r11.out[i];
        out[12 * WORD_SIZE + i] <== r12.out[i];
        out[13 * WORD_SIZE + i] <== r13.out[i];
        out[14 * WORD_SIZE + i] <== r14.out[i];
        
        out[15 * WORD_SIZE + i] <== r15.out[i];
        out[16 * WORD_SIZE + i] <== r16.out[i];
        out[17 * WORD_SIZE + i] <== r17.out[i];
        out[18 * WORD_SIZE + i] <== r18.out[i];
        out[19 * WORD_SIZE + i] <== r19.out[i];
        
        out[20 * WORD_SIZE + i] <== r20.out[i];
        out[21 * WORD_SIZE + i] <== r21.out[i];
        out[22 * WORD_SIZE + i] <== r22.out[i];
        out[23 * WORD_SIZE + i] <== r23.out[i];
        out[24 * WORD_SIZE + i] <== r24.out[i];
    }
}

template RoundConst(r) {
    var WORD_SIZE = 64;
    signal output out[WORD_SIZE];
    var rc[24] = [
    0x0000000000000001, 0x0000000000008082, 0x800000000000808A,
    0x8000000080008000, 0x000000000000808B, 0x0000000080000001,
    0x8000000080008081, 0x8000000000008009, 0x000000000000008A,
    0x0000000000000088, 0x0000000080008009, 0x000000008000000A,
    0x000000008000808B, 0x800000000000008B, 0x8000000000008089,
    0x8000000000008003, 0x8000000000008002, 0x8000000000000080,
    0x000000000000800A, 0x800000008000000A, 0x8000000080008081,
    0x8000000000008080, 0x0000000080000001, 0x8000000080008008
    ];
    for (var i = 0; i < WORD_SIZE; i++) {
        out[i] <== (rc[r] >> i) & 1;
    }
}

template Iota(r) {
    
    var WORD_SIZE = 64;
    var STATE_SIZE = WORD_SIZE * 25;

    signal input in[STATE_SIZE];
    signal output out[STATE_SIZE];

    
    component rc = RoundConst(r);
    
    component iota = XorArray(WORD_SIZE);
    for (var i = 0; i < WORD_SIZE; i++) {
        iota.a[i] <== in[i];
        iota.b[i] <== rc.out[i];
    }
    for (var i = 0; i < WORD_SIZE; i++) {
        out[i] <== iota.out[i];
    }
    for (var i = WORD_SIZE; i < STATE_SIZE; i++) {
        out[i] <== in[i];
    }
}

