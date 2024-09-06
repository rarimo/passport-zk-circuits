pragma circom  2.1.6;

include "../signatureVerifier/signatureVerification.circom";

//I hope this will work
template ActiveAuthenticationBuilder(
    CHUNK_SIZE,
    CHUNK_NUMBER,
    SALT_LEN, 
    E_BITS,
    SIGNATURE_TYPE,
    CHALLENGE_HASH_TYPE
){
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


    signal input pubkey[PUBKEY_LEN];
    signal input signature[SIGNATURE_LEN];
    signal input challenge[CHALLENGE_HASH_TYPE];

    component checkChallenge = VerifySignature(
        CHUNK_SIZE,
        CHUNK_NUMBER, 
        SALT_LEN, 
        E_BITS, 
        SIGNATURE_TYPE
    );

    checkChallenge.pubkey    <== pubkey;
    checkChallenge.signature <== signature;
    checkChallenge.hashed    <== challenge;

}