pragma circom 2.1.6;


include "../lib/circuits/signatures/rsa.circom";
include "../lib/circuits/signatures/rsaPss.circom";
include "../lib/circuits/signatures/ecdsa.circom";


template VerifySignature(SIG_ALGO){

    assert(((SIG_ALGO >= 1)&&(SIG_ALGO <= 4))||((SIG_ALGO >= 10)&&(SIG_ALGO <= 14))||((SIG_ALGO >= 20)&&(SIG_ALGO <= 25)));
    
    var CHUNK_SIZE = 64;
    var CHUNK_NUMBER = 32;
    var HASH_LEN;
    var PUBKEY_LEN;
    var SIGNATURE_LEN;
    var SALT_LEN = 32;
    var EXP = 65537;

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
     if (SIG_ALGO == 4){
        CHUNK_NUMBER = 48;
        PUBKEY_LEN = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
        HASH_LEN = 160;
        EXP = 37187;
    }


    if (SIG_ALGO == 10){
        PUBKEY_LEN = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
        HASH_LEN = 256;
        EXP = 3;
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
        PUBKEY_LEN = 2 * CHUNK_NUMBER;
        SIGNATURE_LEN = 2 * CHUNK_NUMBER;
    }
    if (SIG_ALGO == 21){
        CHUNK_NUMBER = 4;
        HASH_LEN = 256;
        PUBKEY_LEN = 2 * CHUNK_NUMBER;
        SIGNATURE_LEN = 2 * CHUNK_NUMBER;
    }
    if (SIG_ALGO == 22){
        CHUNK_NUMBER = 5;
        HASH_LEN = 256;
        PUBKEY_LEN = 2 * CHUNK_NUMBER;
        SIGNATURE_LEN = 2 * CHUNK_NUMBER;
    }
    if (SIG_ALGO == 23){
        CHUNK_NUMBER = 3;
        HASH_LEN = 160;
        PUBKEY_LEN = 2 * CHUNK_NUMBER;
        SIGNATURE_LEN = 2 * CHUNK_NUMBER;
    }

    if (SIG_ALGO == 24){
        CHUNK_NUMBER = 7;
        CHUNK_SIZE = 32;
        PUBKEY_LEN = 2 * CHUNK_NUMBER;
        SIGNATURE_LEN = 2 * CHUNK_NUMBER;
        HASH_LEN = 224;
    }

    if (SIG_ALGO == 25){
        CHUNK_NUMBER = 6;
        CHUNK_SIZE = 64;
        PUBKEY_LEN = 2 * CHUNK_NUMBER;
        SIGNATURE_LEN = 2 * CHUNK_NUMBER;
        HASH_LEN = 384;
    }

    signal input pubkey[PUBKEY_LEN];
    signal input signature[SIGNATURE_LEN];
    signal input hashed[HASH_LEN];

    if (SIG_ALGO == 1){
        component rsa2048Sha256Verification = RsaVerifyPkcs1v15(CHUNK_SIZE, CHUNK_NUMBER, EXP, HASH_LEN);
        rsa2048Sha256Verification.pubkey <== pubkey;
        rsa2048Sha256Verification.signature <== signature;
        rsa2048Sha256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 2){
        component rsa4096Sha256Verification = RsaVerifyPkcs1v15(CHUNK_SIZE, CHUNK_NUMBER, EXP, HASH_LEN);
        rsa4096Sha256Verification.pubkey <== pubkey;
        rsa4096Sha256Verification.signature <== signature;
        rsa4096Sha256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 3){
        component rsa2048Sha160Verification = RsaVerifyPkcs1v15(CHUNK_SIZE, CHUNK_NUMBER, EXP, HASH_LEN);
        rsa2048Sha160Verification.pubkey <== pubkey;
        rsa2048Sha160Verification.signature <== signature;
        rsa2048Sha160Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 4){
        component verifyRsa3072Sha1E37817 = RsaVerifyPkcs1v15(CHUNK_SIZE, CHUNK_NUMBER, EXP, HASH_LEN);
        verifyRsa3072Sha1E37817.pubkey <== pubkey;
        verifyRsa3072Sha1E37817.signature <== signature;
        verifyRsa3072Sha1E37817.hashed <== hashed;
    }
    if (SIG_ALGO == 10){
        component rsa2048PssSha256Verification = VerifyRsaPssSig(CHUNK_SIZE, CHUNK_NUMBER, SALT_LEN, EXP, HASH_LEN);
        rsa2048PssSha256Verification.pubkey <== pubkey;
        rsa2048PssSha256Verification.signature <== signature;
        rsa2048PssSha256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 11){
        component rsa4096PssSha256Verification = VerifyRsaPssSig(CHUNK_SIZE, CHUNK_NUMBER, SALT_LEN, EXP, HASH_LEN);
        rsa4096PssSha256Verification.pubkey <== pubkey;
        rsa4096PssSha256Verification.signature <== signature;
        rsa4096PssSha256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 12){
        component rsaPssSha384Verification = VerifyRsaPssSig(CHUNK_SIZE, CHUNK_NUMBER, SALT_LEN, EXP, HASH_LEN);
        rsaPssSha384Verification.pubkey <== pubkey;
        rsaPssSha384Verification.signature <== signature;
        rsaPssSha384Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 13){
        component rsaPssSha384Verification = VerifyRsaPssSig(CHUNK_SIZE, CHUNK_NUMBER, SALT_LEN, EXP, HASH_LEN);
        rsaPssSha384Verification.pubkey <== pubkey;
        rsaPssSha384Verification.signature <== signature;
        rsaPssSha384Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 14){
        component rsaPssSha384Verification = VerifyRsaPssSig(CHUNK_SIZE, CHUNK_NUMBER, SALT_LEN, EXP, HASH_LEN);
        rsaPssSha384Verification.pubkey <== pubkey;
        rsaPssSha384Verification.signature <== signature;
        rsaPssSha384Verification.hashed <== hashed;
    }

    if (SIG_ALGO == 20){
        component p256Verification = verifyECDSABits(CHUNK_SIZE, CHUNK_NUMBER, 
            [18446744073709551612, 4294967295, 0, 18446744069414584321], 
            [4309448131093880907, 7285987128567378166, 12964664127075681980, 6540974713487397863], 
            [18446744073709551615, 4294967295, 0, 18446744069414584321], 
            HASH_LEN);
        for (var i = 0; i < CHUNK_NUMBER; i++){
            p256Verification.pubkey[0][i] <== pubkey[i];
            p256Verification.pubkey[1][i] <== pubkey[i + CHUNK_NUMBER];
            p256Verification.signature[0][i] <== signature[i];
            p256Verification.signature[1][i] <== signature[i + CHUNK_NUMBER];
        }
        
        p256Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 21){
        component brainpoolVerification = verifyECDSABits(CHUNK_SIZE, CHUNK_NUMBER,
            [16810331318623712729, 18122579188607900780, 17219079075415130087, 9032542404991529047],
            [7767825457231955894, 10773760575486288334, 17523706096862592191, 2800214691157789508],
            [2311270323689771895, 7943213001558335528, 4496292894210231666, 12248480212390422972],
            HASH_LEN);
       for (var i = 0; i < CHUNK_NUMBER; i++){
            brainpoolVerification.pubkey[0][i] <== pubkey[i];
            brainpoolVerification.pubkey[1][i] <== pubkey[i + CHUNK_NUMBER];
            brainpoolVerification.signature[0][i] <== signature[i];
            brainpoolVerification.signature[1][i] <== signature[i + CHUNK_NUMBER];
        }
        brainpoolVerification.hashed <== hashed;
    }
    if (SIG_ALGO == 22){
        component brainpool320Verification = verifyECDSABits(CHUNK_SIZE, CHUNK_NUMBER, 
            [10588936519694028468, 7356927617611573748, 11720394915101506010, 9497225011815988152, 4531478116471320824],
            [8025050239258980774, 14713784232908765569, 16230763276166018202, 15252875577370643055, 5911119185252826178],
            [18218206948094062119, 5733849700882443304, 17982820153128390127, 16229979505782022245, 15230689193496432567],
            HASH_LEN);
       for (var i = 0; i < CHUNK_NUMBER; i++){
            brainpool320Verification.pubkey[0][i] <== pubkey[i];
            brainpool320Verification.pubkey[1][i] <== pubkey[i + CHUNK_NUMBER];
            brainpool320Verification.signature[0][i] <== signature[i];
            brainpool320Verification.signature[1][i] <== signature[i + CHUNK_NUMBER];
        }
        brainpool320Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 23){
        component secp192Verification = verifyECDSABits(CHUNK_SIZE, CHUNK_NUMBER, 
            [18446744073709551612, 18446744073709551614, 18446744073709551615],
            [18354665389784742321, 1128127154243252297, 7215053686808805607],
            [18446744073709551615, 18446744073709551614, 18446744073709551615],
            HASH_LEN);
        for (var i = 0; i < CHUNK_NUMBER; i++){
            secp192Verification.pubkey[0][i] <== pubkey[i];
            secp192Verification.pubkey[1][i] <== pubkey[i + CHUNK_NUMBER];
            secp192Verification.signature[0][i] <== signature[i];
            secp192Verification.signature[1][i] <== signature[i + CHUNK_NUMBER];
        }
        secp192Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 24){
        component p224Verification = verifyECDSABits(CHUNK_SIZE, CHUNK_NUMBER, 
            [4294967294, 4294967295, 4294967295, 4294967294, 4294967295, 4294967295, 4294967295],
            [592838580, 655046979, 3619674298, 1346678967, 4114690646, 201634731, 3020229253],
            [1, 0, 0, 4294967295, 4294967295, 4294967295, 4294967295],
            HASH_LEN);
        for (var i = 0; i < CHUNK_NUMBER; i++){
            p224Verification.pubkey[0][i] <== pubkey[i];
            p224Verification.pubkey[1][i] <== pubkey[i + CHUNK_NUMBER];
            p224Verification.signature[0][i] <== signature[i];
            p224Verification.signature[1][i] <== signature[i + CHUNK_NUMBER];
        }
        p224Verification.hashed <== hashed;
    }
    if (SIG_ALGO == 25){
        component brainpool384Verification = verifyECDSABits(CHUNK_SIZE, CHUNK_NUMBER, 
            [335737924824737830, 9990533504564909291, 1410020238645393679, 14032832221039175559, 4355552632119865248, 8918115475071440140],
            [4230998357940653073, 8985869839777909140, 3352946025465340629, 3438355245973688998, 10032249017711215740, 335737924824737830],
            [9747760000893709395, 12453481191562877553, 1347097566612230435, 1526563086152259252, 1107163671716839903, 10140169582434348328],
            HASH_LEN);
        for (var i = 0; i < CHUNK_NUMBER; i++){
            brainpool384Verification.pubkey[0][i] <== pubkey[i];
            brainpool384Verification.pubkey[1][i] <== pubkey[i + CHUNK_NUMBER];
            brainpool384Verification.signature[0][i] <== signature[i];
            brainpool384Verification.signature[1][i] <== signature[i + CHUNK_NUMBER];
        }
        brainpool384Verification.hashed <== hashed;
    }
    
}