pragma circom 2.1.6;

include "../ecdsa/secp256r1/signatureVerification.circom";
include "../ecdsa/brainpoolP256r1/signatureVerification.circom";
include "../ecdsa/brainpoolP320r1/signatureVerification.circom";
include "../ecdsa/secp192r1/signatureVerification.circom";
include "../ecdsa/p224/signatureVerification.circom";
include "../rsa/rsa.circom";
include "../rsaPss/rsaPss.circom";

template VerifySignature(SIG_ALGO){

    assert(((SIG_ALGO >= 1)&&(SIG_ALGO <= 3))||((SIG_ALGO >= 10)&&(SIG_ALGO <= 14))||((SIG_ALGO >= 20)&&(SIG_ALGO <= 24)));
    
    var CHUNK_SIZE = 64;
    var CHUNK_NUMBER = 32;
    var HASH_LEN;
    var PUBKEY_LEN;
    var SIGNATURE_LEN;
    var SALT_LEN = 32;
    var E_BITS = 17;

    if (SIG_ALGO == 1){
        PUBKEY_LEN = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
        HASH_LEN = 256;
    }
    if (SIG_ALGO == 2){
        CHUNK_NUMBER = 64;
        PUBKEY_LEN = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
        HASH_LEN = 256;
    }
        if (SIG_ALGO == 3){
        PUBKEY_LEN = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
        HASH_LEN = 160;
    }

    if (SIG_ALGO == 10){
        PUBKEY_LEN = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
        HASH_LEN = 256;
        E_BITS = 2;
    }
    if (SIG_ALGO == 11){
        PUBKEY_LEN = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
        HASH_LEN = 256;
    }
    if (SIG_ALGO == 12){
        PUBKEY_LEN = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
        HASH_LEN = 256;
        SALT_LEN = 64;
    }
    
    if (SIG_ALGO == 13){
        PUBKEY_LEN = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
        HASH_LEN = 384;
        SALT_LEN = 48;
    }
        if (SIG_ALGO == 14){
        CHUNK_NUMBER = 48;
        PUBKEY_LEN = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
        HASH_LEN = 256;
    }

    if (SIG_ALGO == 20){
        CHUNK_NUMBER = 4;
        HASH_LEN = 256;
        PUBKEY_LEN = 2 * CHUNK_SIZE * CHUNK_NUMBER;
        SIGNATURE_LEN = 2 * CHUNK_SIZE * CHUNK_NUMBER;
    }
    if (SIG_ALGO == 21){
        CHUNK_NUMBER = 4;
        HASH_LEN = 256;
        PUBKEY_LEN = 2 * CHUNK_SIZE * CHUNK_NUMBER;
        SIGNATURE_LEN = 2 * CHUNK_SIZE * CHUNK_NUMBER;
    }
    if (SIG_ALGO == 22){
        CHUNK_NUMBER = 5;
        HASH_LEN = 256;
        PUBKEY_LEN = 2 * CHUNK_SIZE * CHUNK_NUMBER;
        SIGNATURE_LEN = 2 * CHUNK_SIZE * CHUNK_NUMBER;
    }
    if (SIG_ALGO == 23){
        CHUNK_NUMBER = 3;
        HASH_LEN = 160;
        PUBKEY_LEN = 2 * CHUNK_SIZE * CHUNK_NUMBER;
        SIGNATURE_LEN = 2 * CHUNK_SIZE * CHUNK_NUMBER;
    }

    if (SIG_ALGO == 24){
        CHUNK_NUMBER = 7;
        CHUNK_SIZE = 32;
        PUBKEY_LEN = 2 * CHUNK_SIZE * CHUNK_NUMBER;
        SIGNATURE_LEN = 2 * CHUNK_SIZE * CHUNK_NUMBER;
        HASH_LEN = 224;
    }

    signal input pubkey[PUBKEY_LEN];
    signal input signature[SIGNATURE_LEN];
    signal input hashed[HASH_LEN];

    if (SIG_ALGO == 1){
        component rsa2048Sha256Verification = RsaVerifyPkcs1v15(CHUNK_SIZE, CHUNK_NUMBER, E_BITS, HASH_LEN);
        rsa2048Sha256Verification.pubkey <== pubkey;
        rsa2048Sha256Verification.signature <== signature;
        rsa2048Sha256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 2){
        component rsa4096Sha256Verification = RsaVerifyPkcs1v15(CHUNK_SIZE, CHUNK_NUMBER, E_BITS, HASH_LEN);
        rsa4096Sha256Verification.pubkey <== pubkey;
        rsa4096Sha256Verification.signature <== signature;
        rsa4096Sha256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 3){
        component rsa2048Sha160Verification = RsaVerifyPkcs1v15Sha1(CHUNK_SIZE, CHUNK_NUMBER, E_BITS, HASH_LEN);
        rsa2048Sha160Verification.pubkey <== pubkey;
        rsa2048Sha160Verification.signature <== signature;
        rsa2048Sha160Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 10){
        component rsa2048PssSha256Verification = VerifyRsaSig(CHUNK_SIZE, CHUNK_NUMBER, SALT_LEN, E_BITS, HASH_LEN);
        rsa2048PssSha256Verification.pubkey <== pubkey;
        rsa2048PssSha256Verification.signature <== signature;
        rsa2048PssSha256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 11){
        component rsa4096PssSha256Verification = VerifyRsaSig(CHUNK_SIZE, CHUNK_NUMBER, SALT_LEN, E_BITS, HASH_LEN);
        rsa4096PssSha256Verification.pubkey <== pubkey;
        rsa4096PssSha256Verification.signature <== signature;
        rsa4096PssSha256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 12){
        component rsaPssSha384Verification = VerifyRsaSig(CHUNK_SIZE, CHUNK_NUMBER, SALT_LEN, E_BITS, HASH_LEN);
        rsaPssSha384Verification.pubkey <== pubkey;
        rsaPssSha384Verification.signature <== signature;
        rsaPssSha384Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 13){
        component rsaPssSha384Verification = VerifyRsaSig(CHUNK_SIZE, CHUNK_NUMBER, SALT_LEN, E_BITS, HASH_LEN);
        rsaPssSha384Verification.pubkey <== pubkey;
        rsaPssSha384Verification.signature <== signature;
        rsaPssSha384Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 14){
        component rsaPssSha384Verification = VerifyRsaSig(CHUNK_SIZE, CHUNK_NUMBER, SALT_LEN, E_BITS, HASH_LEN);
        rsaPssSha384Verification.pubkey <== pubkey;
        rsaPssSha384Verification.signature <== signature;
        rsaPssSha384Verification.hashed <== hashed;
    }

    if (SIG_ALGO == 20){
        component p256Verification = verifyP256(CHUNK_SIZE, CHUNK_NUMBER, HASH_LEN);
        p256Verification.pubkey <== pubkey;
        p256Verification.signature <== signature;
        p256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 21){
        component brainpoolVerification = verifyBrainpool(CHUNK_SIZE, CHUNK_NUMBER, HASH_LEN);
        brainpoolVerification.pubkey <== pubkey;
        brainpoolVerification.signature <== signature;
        brainpoolVerification.hashed <== hashed;
    }
    if (SIG_ALGO == 22){
        component brainpool320Verification = verifyBrainpool320(CHUNK_SIZE, CHUNK_NUMBER, HASH_LEN);
        brainpool320Verification.pubkey <== pubkey;
        brainpool320Verification.signature <== signature;
        brainpool320Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 23){
        component secp192Verification = verifySecp192r1(CHUNK_SIZE, CHUNK_NUMBER, HASH_LEN);
        secp192Verification.pubkey <== pubkey;
        secp192Verification.signature <== signature;
        secp192Verification.hashed <== hashed;
    }
     if (SIG_ALGO == 24){
        component p224Verification = verifyP224(CHUNK_SIZE, CHUNK_NUMBER, HASH_LEN);
        p224Verification.pubkey <== pubkey;
        p224Verification.signature <== signature;
        p224Verification.hashed <== hashed;
    }
    
}