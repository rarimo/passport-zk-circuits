pragma circom 2.1.6;

include "../ecdsa/secp256r1/signature_verification.circom";
include "../ecdsa/brainpoolP256r1/signature_verification.circom";
include "../rsa/rsa.circom";
include "../rsaPss/rsaPss.circom";

template VerifySignature(n, k, SALT_LEN, E_BITS, SIG_ALGO){

    assert((SIG_ALGO >= 1)&&(SIG_ALGO <= 7));

    var hashLen;
    var pubkeyLen;
    var signatureLen;

    if (SIG_ALGO == 1){
        pubkeyLen = k;
        signatureLen = k;
        hashLen = 256;
    }
    if (SIG_ALGO == 2){
        pubkeyLen = k;
        signatureLen = k;
        hashLen = 256;
    }
    if (SIG_ALGO == 3){
        pubkeyLen = k;
        signatureLen = k;
        hashLen = 256;
    }
    if (SIG_ALGO == 4){
        pubkeyLen = k;
        signatureLen = k;
        hashLen = 256;
    }
    if (SIG_ALGO == 5){
        pubkeyLen = k;
        signatureLen = k;
        hashLen = 384;
    }
    if (SIG_ALGO == 6){
        hashLen = 256;
        pubkeyLen = 2 * n * k;
        signatureLen = 2 * n * k;
    }
    if (SIG_ALGO == 7){
        hashLen = 256;
        pubkeyLen = 2 * n * k;
        signatureLen = 2 * n * k;
    }

    signal input pubkey[pubkeyLen];
    signal input signature[signatureLen];
    signal input hashed[hashLen];

    if (SIG_ALGO == 1){
        component rsa2048Sha256Verification = RsaVerifyPkcs1v15(n, k, E_BITS, hashLen);
        rsa2048Sha256Verification.pubkey <== pubkey;
        rsa2048Sha256Verification.signature <== signature;
        rsa2048Sha256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 2){
        component rsa4096Sha256Verification = RsaVerifyPkcs1v15(n, k, E_BITS, hashLen);
        rsa4096Sha256Verification.pubkey <== pubkey;
        rsa4096Sha256Verification.signature <== signature;
        rsa4096Sha256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 3){
        component rsa2048PssSha256Verification = VerifyRsaSig(n, k, SALT_LEN, E_BITS, hashLen);
        rsa2048PssSha256Verification.pubkey <== pubkey;
        rsa2048PssSha256Verification.signature <== signature;
        rsa2048PssSha256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 4){
        component rsa4096PssSha256Verification = VerifyRsaSig(n, k, SALT_LEN, E_BITS, hashLen);
        rsa4096PssSha256Verification.pubkey <== pubkey;
        rsa4096PssSha256Verification.signature <== signature;
        rsa4096PssSha256Verification.hashed <== hashed;
    }
     if (SIG_ALGO == 5){
        component rsaPssSha384Verification = VerifyRsaSig(n, k, SALT_LEN, E_BITS, hashLen);
        rsaPssSha384Verification.pubkey <== pubkey;
        rsaPssSha384Verification.signature <== signature;
        rsaPssSha384Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 6){
        component p256Verification = verifyP256(n, k, hashLen);
        p256Verification.pubkey <== pubkey;
        p256Verification.signature <== signature;
        p256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 7){
        component brainpoolVerification = verifyBrainpool(n, k, hashLen);
        brainpoolVerification.pubkey <== pubkey;
        brainpoolVerification.signature <== signature;
        brainpoolVerification.hashed <== hashed;
    }

    
}