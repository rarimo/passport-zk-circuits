pragma circom  2.1.6;

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

    // INPUT SIGNALS:
    signal input encapsulatedContent[EC_BLOCK_NUMBER * 512];
    signal input dg1[1024];
    signal input dg15[DG15_BLOCK_NUMBER * 512];
    signal input signedAttributes[1024];
    signal input signature[32];
    signal input pubkey[32];
    signal input slaveMerkleRoot;
    signal input slaveMerkleInclusionBranches[80];
    signal input skIdentity; 


    signal output dg15PubKeyHash;
    signal output passportHash;
    signal output dg1Commitment;
    signal output pkIdentityHash;

    dg15PubKeyHash <== dg1[0] * dg1[1];
    passportHash <== dg1[0] * dg1[1];
    dg1Commitment <== dg1[0] * dg1[1];
    pkIdentityHash <== dg1[0] * dg1[1];
    

}

