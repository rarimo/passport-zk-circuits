pragma circom  2.1.6;

include "../signatureVerifier/signatureVerification.circom";
include "./passportVerificationFlow.circom";
include "../hasher/passportHash.circom";

template PassportVerificationBuilder(
    DG1_SIZE,
    DG15_SIZE,
    ENCAPSULATED_CONTENT_SIZE,
    SIGNED_ATTRIBUTES_SIZE,
    HASH_BLOCK_SIZE,
    HASH_TYPE,
    SIGNATURE_TYPE,
    E_BITS,
    CHUNK_SIZE,
    CHUNK_NUMBER,
    TREE_DEPTH,
    AA_FLOWS_NUMBER,
    AA_FLOWS_BITMASK,
    NoAA_FLOWS_NUMBER,
    NoAA_FLOWS_BITMASK
) {

    var DG1_LEN                  = DG1_SIZE                  * HASH_BLOCK_SIZE;
    var DG15_LEN                 = DG15_SIZE                 * HASH_BLOCK_SIZE;
    var ENCAPSULATED_CONTENT_LEN = ENCAPSULATED_CONTENT_SIZE * HASH_BLOCK_SIZE;
    var SIGNED_ATTRIBUTES_LEN    = SIGNED_ATTRIBUTES_SIZE    * HASH_BLOCK_SIZE;

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
    signal input dg1                         [DG1_LEN                 ];
    signal input dg15                        [DG15_LEN                ];
    signal input signedAttributes            [SIGNED_ATTRIBUTES_LEN   ];
    signal input signature                   [SIGNATURE_LEN           ];
    signal input pubkey                      [PUBKEY_LEN              ];
    // signal input slaveMerkleInclusionBranches[TREE_DEPTH              ];
    // signal input slaveMerkleRoot;

    component dg1PassportHasher  = PassportHash(HASH_BLOCK_SIZE, DG1_SIZE,                  HASH_TYPE);
    component dg15PassportHasher = PassportHash(HASH_BLOCK_SIZE, DG15_SIZE,                 HASH_TYPE);
    component ecPassportHasher   = PassportHash(HASH_BLOCK_SIZE, ENCAPSULATED_CONTENT_SIZE, HASH_TYPE);
    component saPassportHasher   = PassportHash(HASH_BLOCK_SIZE, SIGNED_ATTRIBUTES_SIZE,    HASH_TYPE);

    signal                 dg1Hash[HASH_TYPE];
    signal                dg15Hash[HASH_TYPE];
    signal encapsulatedContentHash[HASH_TYPE];
    signal    signedAttributesHash[HASH_TYPE];

    dg1PassportHasher.in   <== dg1;
    dg1PassportHasher.out  ==> dg1Hash;
    dg15PassportHasher.in  <== dg15;
    dg15PassportHasher.out ==> dg15Hash;
    ecPassportHasher.in    <== encapsulatedContent;
    ecPassportHasher.out   ==> encapsulatedContentHash;
    saPassportHasher.in    <== signedAttributes;
    saPassportHasher.out   ==> signedAttributesHash;


    var  FIRST_SHIFT;
    var SECOND_SHIFT;
    var  THRID_SHIFT;

    signal dg15Verification;

    if (AA_FLOWS_BITMASK == 1){
        FIRST_SHIFT = 248;
        SECOND_SHIFT = 3056;
        THRID_SHIFT = 576;
        dg15Verification <== 1;
    }

    component passportVerificationFlow = PassportVerificationFlow(
        ENCAPSULATED_CONTENT_LEN, 
        HASH_TYPE,
        SIGNED_ATTRIBUTES_LEN,
        FIRST_SHIFT,
        SECOND_SHIFT,
        THRID_SHIFT 
    );
    
    passportVerificationFlow.dg1Hash                 <== dg1Hash;
    passportVerificationFlow.dg15Hash                <== dg15Hash;
    passportVerificationFlow.encapsulatedContent     <== encapsulatedContent;
    passportVerificationFlow.encapsulatedContentHash <== encapsulatedContentHash;
    passportVerificationFlow.signedAttributes        <== signedAttributes;
    passportVerificationFlow.dg15Verification        <== dg15Verification;
    
    component signatureVerification = VerifySignature(CHUNK_SIZE, CHUNK_NUMBER, E_BITS, SIGNATURE_TYPE);

    signatureVerification.signature <== signature;
    signatureVerification.pubkey    <== pubkey;
    signatureVerification.hashed    <== signedAttributesHash;

}