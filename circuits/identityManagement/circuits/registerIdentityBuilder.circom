pragma circom  2.1.6;

include "../../passportVerification/passportVerificationBuilder.circom";
include "./identity.circom";
include "circomlib/circuits/poseidon.circom";
include "../../merkleTree/SMTVerifier.circom";

// HASH_TYPE: 
//   - 160: SHA1 (160 bits)
//   - 224: SHA2-224 (224 bits)
//   - 256: SHA2-256 (256 bits)
//   - 384: SHA2-384 (384 bits)
//   - 512: SHA2-512 (512 bits)

// SIGNATURE_TYPE:
//   - 1: RSA 2048 bits + SHA2-256
//   - 2: RSA 4096 bits + SHA2-256
//   - 3: RSASSA-PSS 2048 bits MGF1 (SHA2-256) + SHA2-256
//   - 4: RSASSA-PSS 4096 bits MGF1 (SHA2-256) + SHA2-256
//   - 5: RSASSA-PSS 2048 bits MGF1 (SHA2-384) +Ку SHA2-384
//   - 6: ECDSA secp256r1 + SHA256
//   - 7: ECDSA brainpoolP256r1 + SHA256

template RegisterIdentityBuilder (
    DG1_SIZE,                       // size in hash blocks
    DG15_SIZE,                      // size in hash blocks
    ENCAPSULATED_CONTENT_SIZE,      // size in hash blocks
    SIGNED_ATTRIBUTES_SIZE,         // size in hash blocks
    HASH_BLOCK_SIZE,                // size in bits
    HASH_TYPE,                      // 160, 224, 256, 384, 512 (list above)^^^
    SIGNATURE_TYPE,                 // 1, 2..  (list above) ^^^
    SALT_LEN,
    E_BITS,                         // 2, 17 
    CHUNK_SIZE,
    CHUNK_NUMBER,
    DG_HASH_TYPE,                   // 160, 224, 256, 384, 512 (list above)^^^
    DOCUMENT_TYPE,                  // 1: TD1; 3: TD3
    TREE_DEPTH,
    FLOW_MATRIX,
    FLOW_MATRIX_HEIGHT,
    HASH_BLOCK_MATRIX
) {
    // OUTPUT SIGNALS:
    signal output dg15PubKeyHash;
    
    // Poseidon(Hash(signedAttributes)[252:])
    signal output passportHash;

    signal output dg1Commitment;

    // Poseidon2(PubKey.X, PubKey.Y)
    signal output pkIdentityHash;

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


    // INPUT SIGNALS:
    signal input encapsulatedContent[ENCAPSULATED_CONTENT_SIZE * HASH_BLOCK_SIZE];
    signal input dg1[DG1_SIZE * HASH_BLOCK_SIZE];
    signal input dg15[DG15_SIZE * HASH_BLOCK_SIZE];
    signal input signedAttributes[SIGNED_ATTRIBUTES_SIZE * HASH_BLOCK_SIZE];
    signal input signature[SIGNATURE_LEN];
    signal input pubkey[PUBKEY_LEN];
    signal input slaveMerkleRoot;
    signal input slaveMerkleInclusionBranches[TREE_DEPTH];
    signal input skIdentity;  // identity secret key

    // -------
    // PASSPORT VERIFICATION
    // -------
    component passportVerifier = PassportVerificationBuilder(
        DG1_SIZE,
        DG15_SIZE,
        ENCAPSULATED_CONTENT_SIZE,
        SIGNED_ATTRIBUTES_SIZE,
        HASH_BLOCK_SIZE,
        HASH_TYPE,
        SIGNATURE_TYPE,
        SALT_LEN,
        E_BITS,
        CHUNK_SIZE,
        CHUNK_NUMBER,
        DG_HASH_TYPE,
        TREE_DEPTH,
        FLOW_MATRIX,
        FLOW_MATRIX_HEIGHT,
        HASH_BLOCK_MATRIX
    );

    passportVerifier.encapsulatedContent <== encapsulatedContent;
    passportVerifier.dg1                 <== dg1;
    passportVerifier.dg15                <== dg15;
    passportVerifier.signedAttributes    <== signedAttributes;
    passportVerifier.signature           <== signature;
    passportVerifier.pubkey              <== pubkey;
    passportVerifier.passportHash        ==> passportHash; 

    component registerIdentity = RegisterIdentity(
        DG1_SIZE,                       
        DG15_SIZE,                      
        HASH_BLOCK_SIZE,                
        SIGNATURE_TYPE,                 
        DOCUMENT_TYPE
    );

    registerIdentity.dg1            <== dg1;
    registerIdentity.dg15           <== dg15;
    registerIdentity.skIdentity     <== skIdentity;
    registerIdentity.dg15PubKeyHash ==> dg15PubKeyHash;
    registerIdentity.dg1Commitment  ==> dg1Commitment;
    registerIdentity.pkIdentityHash ==> pkIdentityHash;

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

}

