pragma circom 2.1.6;

include "../bigInt/bigInt.circom";
include "../bitify/bitify.circom";
include "../int/arithmetic.circom";


// Verification for RSA signature with Pkcs v15 padding
// Hashed is hashed message of hash_type algo
// signature and pubkey - chunked numbers (CHUNK_SIZE, CHUNK_NUMBER)
// e_bits - Len of bit representation of exponent with 1 highest and lowest bits, other are 0 (2^(e_bits - 1) + 1)
// default exp = 65537
// use this for CHUNK_NUMBER == 2**n, otherwise error will occure
// CHUNK_SIZE == 64 cause we hardcode some constants, which will be another for other chunking,
// so u should understand that in case of changing chunking
template RsaVerifyPkcs1v15(CHUNK_SIZE, CHUNK_NUMBER, EXP, HASH_TYPE) {
    
    assert(CHUNK_SIZE == 64);
    assert(HASH_TYPE == 256 || HASH_TYPE == 160);
    
    signal input signature[CHUNK_NUMBER];
    signal input pubkey[CHUNK_NUMBER]; 
    signal input hashed[HASH_TYPE];
    
    
    

    if (HASH_TYPE == 256){
        // signature ** exp mod modulus
        component pm = PowerMod(CHUNK_SIZE, CHUNK_NUMBER, EXP);
        for (var i = 0; i < CHUNK_NUMBER; i++) {
            pm.base[i] <== signature[i];
            pm.modulus[i] <== pubkey[i];
        }
        
        signal hashed_chunks[4];
        
        component bits2num[4];
        for (var i = 0; i < 4; i++){
            bits2num[3 - i] = Bits2Num(64);
            for (var j = 0; j < 64; j++){
                bits2num[3 - i].in[j] <== hashed[i * 64 + 63 - j];
            }
            bits2num[3 - i].out ==> hashed_chunks[3 - i];
        }
        
        // 1. Check hashed data
        for (var i = 0; i < 4; i++) {
            hashed_chunks[i] === pm.out[i];
        }
        
        // 2. Check hash prefix and 1 byte 0x00
        pm.out[4] === 217300885422736416;
        pm.out[5] === 938447882527703397;
        
        // remain 24 bit
        component num2bits_6 = Num2Bits(CHUNK_SIZE);
        num2bits_6.in <== pm.out[6];
        var remainsBits[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0];
        for (var i = 0; i < 32; i++) {
            num2bits_6.out[i] === remainsBits[31 - i];
        }
        
        // 3. Check PS and em[1] = 1
        for (var i = 32; i < CHUNK_SIZE; i++) {
            num2bits_6.out[i] === 1;
        }
        
        for (var i = 7; i < CHUNK_NUMBER - 1; i++) {
            pm.out[i] === 18446744073709551615; 
        }
    }
    if (HASH_TYPE == 160) {
        component pm = PowerMod(CHUNK_SIZE, CHUNK_NUMBER, EXP);
        for (var i  = 0; i < CHUNK_NUMBER; i++) {
            pm.base[i] <== signature[i];
            pm.modulus[i] <== pubkey[i];
        }

        signal hashed_chunks[2];

        component bits2num[2];
        for (var i = 0; i < 2; i++){
            bits2num[i] = Bits2Num(64);
            for (var j = 0; j < 64; j++){
                bits2num[i].in[j] <== hashed[159 - j - i * 64];
            }
        }

        component getBits = Num2Bits(CHUNK_SIZE);
        component getDiv = Bits2Num(CHUNK_SIZE - 32);
        getBits.in <== pm.out[2];

        for (var i = 0; i < 32; i++){
            getBits.out[i] === hashed[31 - i];
        }

        for (var i = 32; i < CHUNK_SIZE; i++){
            getDiv.in[i - 32] <== getBits.out[i];
        }
        getDiv.out === 83887124;
        //0x5000414

        pm.out[3] === 650212878678426138;
        pm.out[4] === 18446744069417738544;
        for (var i = 5; i < CHUNK_NUMBER - 1; i++) {
            pm.out[i] === 18446744073709551615; 
            // 0b1111111111111111111111111111111111111111111111111111111111111111
        }
        pm.out[CHUNK_NUMBER - 1] === 562949953421311;
    }
    
   
}
