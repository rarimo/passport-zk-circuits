pragma circom  2.1.6;

include "../rsa/powMod.circom";
include "./mgf1.circom";
include "./xor2.circom";

template VerifyRSASig (n, k, messageLen){
    signal input pubkey[k];
    signal input signature[k];
    signal input message[messageLen];

    var emLen = (n*k)\8;
    var hLen = 48; //sha384
    var sLen = 48;
    var hLenBits = 48*8; //*8
    var sLenBits = 48*8; //*8
    var emLenBits = n * k;


    signal eM[emLen]; 
    signal eMsgInBits[emLenBits];
    
    component powmod = PowerMod(n, k, 17);
    powmod.base <== signature;
    powmod.modulus <== pubkey;

    signal encoded[k];
    encoded <== powmod.out;

    component num2Bits[k];
    for (var i = 0; i < k; i++) {
        num2Bits[i] = Num2Bits(n);
        num2Bits[i].in <== encoded[k-1-i];
        
        for (var j = 0; j < n; j++) {
            eMsgInBits[i * n + j] <== num2Bits[i].out[n-j-1];
        }
    }

    
    signal m_hash[hLenBits];
    component hasher = Sha384_hash_bits(messageLen);
    
    hasher.inp_bits <== message;
    m_hash <== hasher.out;


    component bits2Num[emLen];
    for (var i = 0; i < emLen; i++) {
        bits2Num[i] = Bits2Num(8);
        for (var j = 0; j < 8; j++) {
            bits2Num[i].in[7-j] <== eMsgInBits[i*8 + j];
        }
        eM[emLen - i - 1] <== bits2Num[i].out;
    }

    //should be more than HLEN + SLEN + 2
    assert(emLen >= hLen + sLen + 2);

    //should end with 0xBC (188 in decimal)
    assert(eM[0] == 188); //inconsistent

    var dbMaskLen = emLen - hLen - 1;
    signal dbMask[dbMaskLen * 8];
    signal DB[dbMaskLen * 8];
    signal salt[sLen * 8];
    signal maskedDB[(emLen - hLen - 1) * 8];

    for (var i=0; i< (emLen - hLen -1) * 8; i++) {
        maskedDB[i] <== eMsgInBits[i];
    }
    
    signal hash[hLen * 8];


    for (var i=0; i<hLenBits; i++) {
        hash[i] <== eMsgInBits[(emLenBits) - hLenBits-8 +i];
    }


    component MGF1 = Mgf1Sha384(hLen, dbMaskLen);
    for (var i = 0; i < (hLenBits); i++) {
        MGF1.seed[i] <== hash[i];
    }
    for (var i = 0; i < dbMaskLen * 8; i++) {
        dbMask[i] <== MGF1.out[i];
    }
    

    component xor = Xor2(dbMaskLen * 8);
    for (var i = 0; i < dbMaskLen * 8; i++) {
        xor.a[i] <== maskedDB[i];
        xor.b[i] <== dbMask[i];
    }
    for (var i = 0; i < dbMaskLen * 8; i++) {
        //setting the first leftmost byte to 0
        if (i==0) {
            DB[i] <== 0;
        } else {
            DB[i] <== xor.out[i];
        }
    }

    for (var i = 0; i < sLenBits; i++) {
        salt[sLenBits - 1 - i] <== DB[(dbMaskLen * 8) -1 - i];
    }

    var mDashLen = (8 + hLen + sLen) * 8;
    signal mDash[mDashLen]; 
    for (var i = 0; i < 64; i++) {
        mDash[i] <== 0;
    }
    for (var i = 0 ; i < hLen*8; i++) {
        mDash[64 + i] <== m_hash[i];
    }
    for (var i = 0; i < sLen*8; i++) {
        mDash[64 + hLen * 8 + i] <== salt[i];
    }

    component hDash = Sha384_hash_bits(mDashLen);
    hDash.inp_bits <== mDash;

    hDash.out === hash;
}

