pragma circom  2.1.6;

include "../signatureVerifier/signatureVerification.circom";
include "./passportVerificationFlow.circom";
include "../lib/circuits/hasher/hash.circom";
include "../lib/circuits/bitify/bitify.circom";
include "../lib/circuits/hasher/hash.circom";
include "../lib/circuits/bitify/comparators.circom";
include "../merkleTree/SMTVerifier.circom";

template PassportVerificationBuilder(SIGNATURE_TYPE,DG_HASH_TYPE,EC_BLOCK_NUMBER,EC_SHIFT,DG1_SHIFT,AA_SIGNATURE_ALGO,DG15_SHIFT,DG15_BLOCK_NUMBER,AA_SHIFT) { // 160, 224, 256, 384, 512 (list above)^^^// 1, 2..  (list above) ^^^
    
    var TREE_DEPTH = 80;
    var CHUNK_SIZE = 64;
    var CHUNK_NUMBER = 32;
    var HASH_TYPE = 256;
    
    if (SIGNATURE_TYPE == 2){
        CHUNK_NUMBER = 64;
    }
    if (SIGNATURE_TYPE == 3){
        HASH_TYPE = 160;
    }
    if (SIGNATURE_TYPE == 4){
        HASH_TYPE = 160;
        CHUNK_NUMBER = 48;
    }
    if (SIGNATURE_TYPE == 13){
        HASH_TYPE = 384;
    }
    if (SIGNATURE_TYPE == 14){
        CHUNK_NUMBER = 48;
    }
    
    if (SIGNATURE_TYPE >= 20){
        CHUNK_NUMBER = 4;
    }
    
    if (SIGNATURE_TYPE == 22){
        CHUNK_NUMBER = 5;
    }
    
    if (SIGNATURE_TYPE == 23){
        CHUNK_NUMBER = 3;
        HASH_TYPE = 160;
    }

    if (SIGNATURE_TYPE == 25){
        CHUNK_NUMBER = 6;
        HASH_TYPE = 384;
    }

    var EC_HASH_TYPE = HASH_TYPE;
    
    if (SIGNATURE_TYPE == 24){
        CHUNK_NUMBER = 7;
        CHUNK_SIZE = 32;
        HASH_TYPE = 224;
    }
            
    var DG_HASH_BLOCK_SIZE = 1024;
    if (DG_HASH_TYPE <= 256){
        DG_HASH_BLOCK_SIZE = 512;
    }
    var HASH_BLOCK_SIZE = 1024;
    if (HASH_TYPE <= 256){
        HASH_BLOCK_SIZE = 512;
    }

    var DG1_LEN = 1024;
    var SIGNED_ATTRIBUTES_LEN = 1024;
    
    var DG15_LEN = DG15_BLOCK_NUMBER * HASH_BLOCK_SIZE;
    var ENCAPSULATED_CONTENT_LEN = EC_BLOCK_NUMBER * HASH_BLOCK_SIZE;
    
    var PUBKEY_LEN;
    var SIGNATURE_LEN;
    
    //ECDSA
    if (SIGNATURE_TYPE >= 20){
        PUBKEY_LEN = 2 * CHUNK_NUMBER;
        SIGNATURE_LEN = 2 * CHUNK_NUMBER;
    }
    //RSA
    if (SIGNATURE_TYPE < 20){
        PUBKEY_LEN = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
    }
    
    
    signal input encapsulatedContent         [ENCAPSULATED_CONTENT_LEN];
    signal input dg1                         [DG1_LEN];
    signal input dg15                        [DG15_LEN];
    signal input signedAttributes            [SIGNED_ATTRIBUTES_LEN];
    signal input signature                   [SIGNATURE_LEN];
    signal input pubkey                      [PUBKEY_LEN];
    signal input slaveMerkleInclusionBranches[TREE_DEPTH];
    signal input slaveMerkleRoot;
    
    signal output passportHash;
    
    signal dg1Hash[DG_HASH_TYPE];
    component dg1PassportHasher = ShaHashChunks(DG1_LEN \ DG_HASH_BLOCK_SIZE, DG_HASH_TYPE);
    dg1PassportHasher.in <== dg1;
    dg1PassportHasher.out ==> dg1Hash;
    
    signal dg15Hash               [DG_HASH_TYPE];
    signal encapsulatedContentHash[EC_HASH_TYPE];
    signal signedAttributesHash   [HASH_TYPE];
    
    component ecPassportHasher;
    component saPassportHasher;
    
    if (AA_SIGNATURE_ALGO != 0){
        
        component dg15PassportHasher;
        dg15PassportHasher = ShaHashChunks(DG15_BLOCK_NUMBER, DG_HASH_TYPE);
        for (var j = 0; j < DG_HASH_BLOCK_SIZE * DG15_BLOCK_NUMBER; j++){
            dg15PassportHasher.in[j] <== dg15[j];
        }
        dg15Hash <== dg15PassportHasher.out;
        
    } else {
        
        for (var j = 0; j < DG_HASH_TYPE; j++){
            dg15Hash[j] <== 0;
        }
    }
    
    ecPassportHasher = ShaHashChunks(EC_BLOCK_NUMBER, EC_HASH_TYPE);
    for (var j = 0; j < HASH_BLOCK_SIZE * EC_BLOCK_NUMBER; j++){
        ecPassportHasher.in[j] <== encapsulatedContent[j];
    }
    encapsulatedContentHash <== ecPassportHasher.out;
    
    saPassportHasher = ShaHashChunks(SIGNED_ATTRIBUTES_LEN \ HASH_BLOCK_SIZE, HASH_TYPE);
    saPassportHasher.in <== signedAttributes;
    saPassportHasher.out ==> signedAttributesHash;
    
    
    component passportVerificationFlow;
    
    var DG15_ACTUAL_SHIFT = DG_HASH_TYPE;
    if (AA_SIGNATURE_ALGO != 0){
        DG15_ACTUAL_SHIFT = DG15_SHIFT;
    }
    passportVerificationFlow = PassportVerificationFlow(ENCAPSULATED_CONTENT_LEN,DG_HASH_TYPE,EC_HASH_TYPE,DG1_SHIFT,DG15_ACTUAL_SHIFT,EC_SHIFT,AA_SIGNATURE_ALGO);
    
    passportVerificationFlow.dg1Hash <== dg1Hash;
    passportVerificationFlow.dg15Hash <== dg15Hash;
    passportVerificationFlow.encapsulatedContent <== encapsulatedContent;
    passportVerificationFlow.encapsulatedContentHash <== encapsulatedContentHash;
    passportVerificationFlow.signedAttributes <== signedAttributes;
    
    passportVerificationFlow.flowResult === 1;
    
    component signatureVerification = VerifySignature(SIGNATURE_TYPE);
    
    signatureVerification.signature <== signature;
    signatureVerification.pubkey <== pubkey;
    signatureVerification.hashed <== signedAttributesHash;
    
    // Calculating passportHash = PoseidonHash(HASH_TYPE(signedAttributes)[first 252bit][::-1])
    
    component signedAttributesNum = Bits2Num(252);
    if (HASH_TYPE >= 252){
        for (var i = 0; i < 252; i++) {
            signedAttributesNum.in[i] <== signedAttributesHash[i];
        }
    } else {
        for (var i = 0; i < 252 - HASH_TYPE; i++){
            signedAttributesNum.in[i] <== 0;
        }
        for (var i = 0; i < HASH_TYPE; i++){
            signedAttributesNum.in[i + 252 - HASH_TYPE] <== signedAttributesHash[i];
        }
    }
    signal pubkeyHash;
    
    //RSA || RSAPSS SIG
    
    if (SIGNATURE_TYPE < 20){
        component pubkeyHasherRsa = PoseidonHash(5);
        signal tempModulus[5];
        for (var i = 0; i < 5; i++) {
            var currIndex = i * 3;
            tempModulus[i] <== pubkey[currIndex] * 2 ** 128 + pubkey[currIndex + 1] * 2 ** 64;
            pubkeyHasherRsa.in[i] <== tempModulus[i] + pubkey[currIndex + 2];
        }
        pubkeyHash <== pubkeyHasherRsa.out;
    }
    //ECDSA SIG
    else {
        

        var EC_FIELD_SIZE = CHUNK_NUMBER * CHUNK_SIZE;

        signal ecBitsX[EC_FIELD_SIZE];
        signal ecBitsY[EC_FIELD_SIZE];
        component num2bitsX[CHUNK_NUMBER];
        component num2bitsY[CHUNK_NUMBER];
        for (var i = 0; i < CHUNK_NUMBER; i++){
            num2bitsX[i] = Num2Bits(CHUNK_SIZE);
            num2bitsY[i] = Num2Bits(CHUNK_SIZE);
            num2bitsX[i].in <== pubkey[i];
            num2bitsY[i].in <== pubkey[i + CHUNK_NUMBER];

            for (var j = 0; j < CHUNK_SIZE; j++){
                ecBitsX[EC_FIELD_SIZE - 1 - j - i *  CHUNK_SIZE] <== num2bitsX[i].out[j];
                ecBitsY[EC_FIELD_SIZE - 1 - j - i *  CHUNK_SIZE] <== num2bitsY[i].out[j];
            }
        }

        var DIFF = 0;
        if (EC_FIELD_SIZE > 248){
            DIFF = EC_FIELD_SIZE - 248;
        }
        component xToNum = Bits2Num(EC_FIELD_SIZE - DIFF);
        component yToNum = Bits2Num(EC_FIELD_SIZE - DIFF);
        
        for (var i = 0; i < EC_FIELD_SIZE - DIFF; i++) {
            xToNum.in[EC_FIELD_SIZE - DIFF - 1 - i] <== ecBitsX[i + DIFF];
            yToNum.in[EC_FIELD_SIZE - DIFF - 1 - i] <== ecBitsY[i + DIFF];
        }
        
        component pubkeyHasher = PoseidonHash(2);
        
        pubkeyHasher.in[0] <== xToNum.out;
        pubkeyHasher.in[1] <== yToNum.out;
        
        pubkeyHash <== pubkeyHasher.out;
    }
    // Verifying that public key inclusion into the Slave Certificates Merkle Tree
    component smtVerifier = SMTVerifier(TREE_DEPTH);
    smtVerifier.root <== slaveMerkleRoot;
    smtVerifier.leaf <== pubkeyHash;
    smtVerifier.key <== pubkeyHash;
    smtVerifier.siblings <== slaveMerkleInclusionBranches;
    
    // smtVerifier.isVerified === 1;
    
    component signedAttributesHashHasher = PoseidonHash(1);
    signedAttributesHashHasher.in[0] <== signedAttributesNum.out;
    passportHash <== signedAttributesHashHasher.out;
    
}
