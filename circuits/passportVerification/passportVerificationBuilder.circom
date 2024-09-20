pragma circom  2.1.6;

include "../signatureVerifier/signatureVerification.circom";
include "./passportVerificationFlow.circom";
include "../hasher/passportHash.circom";
include "circomlib/circuits/bitify.circom";
include "circomlib/circuits/poseidon.circom";
include "../merkleTree/SMTVerifier.circom";

template PassportVerificationBuilder(
    // DG1_SIZE,
    DG15_SIZE,
    ENCAPSULATED_CONTENT_SIZE,
    // SIGNED_ATTRIBUTES_SIZE,
    HASH_BLOCK_SIZE,
    HASH_TYPE,
    SIGNATURE_TYPE,
    SALT_LEN,
    E_BITS,
    CHUNK_SIZE,
    CHUNK_NUMBER,
    DG_HASH_BLOCK_SIZE,
    DG_HASH_TYPE,
    TREE_DEPTH,
    FLOW_MATRIX,
    FLOW_MATRIX_HEIGHT,
    HASH_BLOCK_MATRIX //[3][8]
) {

    // var DG1_LEN                  = DG1_SIZE                  * HASH_BLOCK_SIZE;
    var DG15_LEN                 = DG15_SIZE                 * HASH_BLOCK_SIZE;
    var ENCAPSULATED_CONTENT_LEN = ENCAPSULATED_CONTENT_SIZE * HASH_BLOCK_SIZE;
    // var SIGNED_ATTRIBUTES_LEN    = SIGNED_ATTRIBUTES_SIZE    * HASH_BLOCK_SIZE;

    var PUBKEY_LEN;
    var SIGNATURE_LEN;

    //ECDSA
    if (SIGNATURE_TYPE > 5){
        PUBKEY_LEN    = 2 * CHUNK_NUMBER * CHUNK_SIZE;
        SIGNATURE_LEN = 2 * CHUNK_NUMBER * CHUNK_SIZE;
    }
    //RSA
    if (SIGNATURE_TYPE <= 5){
        PUBKEY_LEN    = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
    }


    signal input encapsulatedContent         [ENCAPSULATED_CONTENT_LEN];
    signal input dg1                         [1024];
    signal input dg15                        [DG15_LEN];
    signal input signedAttributes            [1024];
    signal input signature                   [SIGNATURE_LEN];
    signal input pubkey                      [PUBKEY_LEN];
    signal input slaveMerkleInclusionBranches[TREE_DEPTH];
    signal input slaveMerkleRoot;

    signal output passportHash;
    
    signal dg1Hash[DG_HASH_TYPE];
    component dg1PassportHasher = PassportHash(HASH_BLOCK_SIZE, 1024\DG_HASH_BLOCK_SIZE, DG_HASH_TYPE);
    dg1PassportHasher.in   <== dg1;
    dg1PassportHasher.out  ==> dg1Hash;

    var HASHES_COUNT[2];

    for (var i = 0; i < 2; i++){
        HASHES_COUNT[i] = 0;
        for (var j = 0; j < 8; j++){
            HASHES_COUNT[i] = HASHES_COUNT[i] + HASH_BLOCK_MATRIX[i][j];
        }
    }

    signal dg15Hash               [8][DG_HASH_TYPE];
    signal encapsulatedContentHash[8][HASH_TYPE];
    signal signedAttributesHash   [HASH_TYPE];

    component dg15PassportHasher[HASHES_COUNT[0]];
    component ecPassportHasher  [HASHES_COUNT[1]];
    component saPassportHasher;

    var hashCounter = 0;
    
    for (var i = 1; i <= 8; i++){
        if (HASH_BLOCK_MATRIX[0][i-1] == 1){
            dg15PassportHasher[hashCounter] = PassportHash(DG_HASH_BLOCK_SIZE, i, DG_HASH_TYPE);
            for (var j = 0; j < DG_HASH_BLOCK_SIZE*i; j++){
                dg15PassportHasher[hashCounter].in[j] <== dg15[j];
            }
            dg15PassportHasher[hashCounter].out ==> dg15Hash[i-1];
            hashCounter += 1;
        } else {
            for (var j = 0; j < DG_HASH_TYPE; j++){
                dg15Hash[i-1][j] <== 0;
            }
        }
    }
    
    hashCounter = 0;
    

    for (var i = 1; i <= 8; i++){
        if (HASH_BLOCK_MATRIX[1][i-1] == 1){
            ecPassportHasher[hashCounter] = PassportHash(HASH_BLOCK_SIZE, i, HASH_TYPE);
            for (var j = 0; j < HASH_BLOCK_SIZE*i; j++){
                ecPassportHasher[hashCounter].in[j] <== encapsulatedContent[j];
            }
            ecPassportHasher[hashCounter].out ==> encapsulatedContentHash[i-1];
            hashCounter += 1;
        } else {
            for (var j = 0; j < HASH_TYPE; j++){
                encapsulatedContentHash[i-1][j] <== 0;
            }
        }
    }

    saPassportHasher = PassportHash(HASH_BLOCK_SIZE, 1024\HASH_BLOCK_SIZE, HASH_TYPE);
    saPassportHasher.in <== signedAttributes;
    saPassportHasher.out ==> signedAttributesHash;
   

    component passportVerificationFlow[FLOW_MATRIX_HEIGHT];
    signal flowResultArray[FLOW_MATRIX_HEIGHT];
    for (var i = 0; i < FLOW_MATRIX_HEIGHT; i++){
        passportVerificationFlow[i] = PassportVerificationFlow(
            ENCAPSULATED_CONTENT_LEN, 
            DG_HASH_TYPE,
            HASH_TYPE,
            // 1024,
            FLOW_MATRIX[i][0], //dg1 shift
            FLOW_MATRIX[i][1], //dg15 shift
            FLOW_MATRIX[i][2], //encapsulated content shift
            FLOW_MATRIX[i][5]  //dg15present
        );

        passportVerificationFlow[i].dg1Hash                 <== dg1Hash;
        passportVerificationFlow[i].dg15Hash                <== dg15Hash[FLOW_MATRIX[i][3]-1];          //dg15 block num (-1 because of starting from 1 block hash)
        passportVerificationFlow[i].encapsulatedContent     <== encapsulatedContent;       
        passportVerificationFlow[i].encapsulatedContentHash <== encapsulatedContentHash[FLOW_MATRIX[i][4]-1];     //ec block num (-1 the same)
        passportVerificationFlow[i].signedAttributes        <== signedAttributes;

        // log("Flow result:", passportVerificationFlow[i].flowResult);
        if (i == 0) {
            flowResultArray[i] <== passportVerificationFlow[i].flowResult;
        } else {
            flowResultArray[i] <== passportVerificationFlow[i].flowResult + flowResultArray[i-1];
        }
    }

    assert(flowResultArray[FLOW_MATRIX_HEIGHT-1] >= 1);
        
    component signatureVerification = VerifySignature(CHUNK_SIZE, CHUNK_NUMBER, SALT_LEN, E_BITS, SIGNATURE_TYPE);

    signatureVerification.signature <== signature;
    signatureVerification.pubkey    <== pubkey;
    signatureVerification.hashed    <== signedAttributesHash;

    // Calculating passportHash = Poseidon(HASH_TYPE(signedAttributes)[252bit])

    component signedAttributesNum = Bits2Num(252);
    if (HASH_TYPE >= 252){
        for (var i = 0; i < 252; i++) {
            signedAttributesNum.in[i] <== signedAttributesHash[i];
        }
    } else {
        for (var i = 0 ; i < 252 - HASH_TYPE; i++){
            signedAttributesNum.in[i] <== 0;
        }
        for (var i = 0; i < HASH_TYPE; i++){
            signedAttributesNum.in[i + 252 - HASH_TYPE] <== signedAttributesHash[i];
        }
    }
    signal pubkeyHash;
    
    //RSA || RSAPSS SIG

    if (SIGNATURE_TYPE <= 5){
        component pubkeyHasherRsa = Poseidon(5);
        signal tempModulus[5];
        for (var i = 0; i < 5; i++) {
            var currIndex = i * 3;
            tempModulus[i] <== pubkey[currIndex] * 2**128 + pubkey[currIndex + 1] * 2**64;
            pubkeyHasherRsa.inputs[i] <== tempModulus[i] + pubkey[currIndex + 2];
        }
        pubkeyHash <== pubkeyHasherRsa.out;
    }
    //ECDSA SIG
    else {
        component xToNum = Bits2Num(248);
        component yToNum = Bits2Num(248);
        
        var EC_FIELD_SIZE = 256;

        for (var i = 0; i < 248; i++) {
            xToNum.in[247-i] <== pubkey[i + 8];
            yToNum.in[247-i] <== pubkey[EC_FIELD_SIZE + i + 8];
        }

        component pubkeyHasher = Poseidon(2);
        
        pubkeyHasher.inputs[0] <== xToNum.out;
        pubkeyHasher.inputs[1] <== yToNum.out;
        
        pubkeyHash <== pubkeyHasher.out;
    }
     // Verifying that public key inclusion into the Slave Certificates Merkle Tree
    component smtVerifier = SMTVerifier(TREE_DEPTH);
    smtVerifier.root     <== slaveMerkleRoot;
    smtVerifier.leaf     <== pubkeyHash;
    smtVerifier.key      <== pubkeyHash;
    smtVerifier.siblings <== slaveMerkleInclusionBranches;

    smtVerifier.isVerified === 1; 
    // log("SMT: ", smtVerifier.isVerified);

    component signedAttributesHashHasher = Poseidon(1);
    signedAttributesHashHasher.inputs[0] <== signedAttributesNum.out;
    passportHash <== signedAttributesHashHasher.out;

}