pragma circom  2.1.6;

include "../../passportVerification/passportVerificationBuilder.circom";
include "./identity.circom";
include "circomlib/circuits/poseidon.circom";


// HASH_TYPE: 
//   - 160: SHA1 (160 bits)
//   - 224: SHA2-224 (224 bits)
//   - 256: SHA2-256 (256 bits)
//   - 384: SHA2-384 (384 bits)
//   - 512: SHA2-512 (512 bits)

// SIGNATURE_TYPE:
//   - 1: RSA 2048 bits + SHA2-256 + e = 65537
//   - 2: RSA 4096 bits + SHA2-256 + e = 65537

//   - 10: RSASSA-PSS 2048 bits MGF1 (SHA2-256) + SHA2-256 + e = 3 + salt = 32
//   - 11: RSASSA-PSS 2048 bits MGF1 (SHA2-256) + SHA2-256 + e = 65537 + salt = 32
//   - 12: RSASSA-PSS 2048 bits MGF1 (SHA2-256) + SHA2-256 + e = 65537 + salt = 64
//   - 13: RSASSA-PSS 2048 bits MGF1 (SHA2-384) + SHA2-384 + e = 65537 + salt = 48
//   - 13: RSASSA-PSS 3072 bits MGF1 (SHA2-256) + SHA2-256 + e = 65537 + salt = 32

//   - 20: ECDSA brainpoolP256r1 + SHA256
//   - 21: ECDSA secp256r1 + SHA256
//   - 22: ECDSA brainpoolP320r1 + SHA256
//   - 23: ECDSA secp192r1 + SHA1

// AA_SIGNATURE_TYPE:
//   - 0: NO AA
//   - 1: RSA 1024 bits + SHA2-256 + e = 65537

//   - 20: ECDSA brainpoolP256r1 + SHA256
//   - 21: ECDSA secp256r1 + SHA256
//   - 22: ECDSA brainpoolP320r1 + SHA256
//   - 23: ECDSA secp192r1 + SHA1


template RegisterIdentityBuilder (
    SIGNATURE_TYPE,                 // 1, 2..  (list above) ^^^
    DG_HASH_TYPE,                   // 160, 224, 256, 384, 512 (list above)^^^
    DOCUMENT_TYPE,                  // 1: TD1; 3: TD3
    EC_BLOCK_NUMBER,
    EC_SHIFT,
    DG1_SHIFT,
    AA_SIGNATURE_ALGO,
    DG15_SHIFT,
    DG15_BLOCK_NUMBER,
    AA_SHIFT
) {

    var TREE_DEPTH = 80;
    var CHUNK_SIZE = 64;
    var CHUNK_NUMBER = 32;
    var HASH_TYPE = 256;

    if (SIGNATURE_TYPE == 2){
        CHUNK_NUMBER = 64;
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

    // OUTPUT SIGNALS:
    signal output dg15PubKeyHash;
    
    // Poseidon(Hash(signedAttributes)[252:])
    signal output passportHash;

    signal output dg1Commitment;

    // Poseidon2(PubKey.X, PubKey.Y)
    signal output pkIdentityHash;

    var DG1_LEN = 1024;
    var SIGNED_ATTRIBUTES_LEN = 1024;

    var PUBKEY_LEN;
    var SIGNATURE_LEN;

    //ECDSA
    if (SIGNATURE_TYPE >= 20){
        PUBKEY_LEN    = 2 * CHUNK_NUMBER * CHUNK_SIZE;
        SIGNATURE_LEN = 2 * CHUNK_NUMBER * CHUNK_SIZE;   
    }
    //RSA||RSAPSS
    if (SIGNATURE_TYPE < 20){
        PUBKEY_LEN    = CHUNK_NUMBER;
        SIGNATURE_LEN = CHUNK_NUMBER;
    }


    // INPUT SIGNALS:
    signal input encapsulatedContent[EC_BLOCK_NUMBER * HASH_BLOCK_SIZE];
    signal input dg1[DG1_LEN];
    signal input dg15[DG15_BLOCK_NUMBER * HASH_BLOCK_SIZE];
    signal input signedAttributes[SIGNED_ATTRIBUTES_LEN];
    signal input signature[SIGNATURE_LEN];
    signal input pubkey[PUBKEY_LEN];
    signal input slaveMerkleRoot;
    signal input slaveMerkleInclusionBranches[TREE_DEPTH];
    signal input skIdentity;  // identity secret key

    // -------
    // PASSPORT VERIFICATION
    // -------
    component passportVerifier = PassportVerificationBuilder(
        SIGNATURE_TYPE,                 // 1, 2..  (list above) ^^^
        DG_HASH_TYPE,                   // 160, 224, 256, 384, 512 (list above)^^^
        EC_BLOCK_NUMBER,
        EC_SHIFT,
        DG1_SHIFT,
        AA_SIGNATURE_ALGO,
        DG15_SHIFT,
        DG15_BLOCK_NUMBER,
        AA_SHIFT
    );

    passportVerifier.encapsulatedContent          <== encapsulatedContent;
    passportVerifier.dg1                          <== dg1;
    passportVerifier.dg15                         <== dg15;
    passportVerifier.signedAttributes             <== signedAttributes;
    passportVerifier.signature                    <== signature;
    passportVerifier.pubkey                       <== pubkey;
    passportVerifier.slaveMerkleInclusionBranches <== slaveMerkleInclusionBranches;
    passportVerifier.slaveMerkleRoot              <== slaveMerkleRoot;
    passportVerifier.passportHash                 ==> passportHash; 

    component registerIdentity = RegisterIdentity(
        DG15_BLOCK_NUMBER,                      
        DG_HASH_BLOCK_SIZE,                
        SIGNATURE_TYPE,                 
        DOCUMENT_TYPE,
        AA_SIGNATURE_ALGO,
        AA_SHIFT
    );

    registerIdentity.dg1            <== dg1;
    registerIdentity.dg15           <== dg15;
    registerIdentity.skIdentity     <== skIdentity;
    registerIdentity.dg15PubKeyHash ==> dg15PubKeyHash;
    registerIdentity.dg1Commitment  ==> dg1Commitment;
    registerIdentity.pkIdentityHash ==> pkIdentityHash;

}

