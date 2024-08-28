pragma circom  2.1.6;

include "../../passportVerification/passportVerificationBuilder.circom";

// HASH_TYPE: 
//   - 160: SHA1 (160 bits)
//   - 256: SHA2-256 (256 bits)
//   - 384: SHA2-384 (384 bits)
//   - 512: SHA2-512 (512 bits)

// SIGNATURE_TYPE:
//   - 1: RSA 2048 bits + SHA2-256
//   - 2: RSA 4096 bits + SHA2-256
//   - 3: RSASSA-PSS 2048 bits MGF1 (SHA2-256) + SHA2-256
//   - 3: RSASSA-PSS 4096 bits MGF1 (SHA2-256) + SHA2-256
//   - 3: RSASSA-PSS 2048 bits MGF1 (SHA2-384) + SHA2-384


template RegisterIdentityBuilder (
    DG1_SIZE,                       // size in hash blocks
    DG15_SIZE,                      // size in hash blocks
    ENCAPSULATED_CONTENT_SIZE,      // size in hash blocks
    SIGNED_ATTRIBUTES_SIZE,         // size in hash blocks
    HASH_BLOCK_SIZE,                // size in bits
    HASH_TYPE,                      // 160, 256, 384, 512 (list above)^^^
    SIGNATURE_TYPE,                 // 1, 2..  (list above) ^^^
    CHUNK_SIZE,
    CHUNK_NUMBER,
    DOCUMENT_TYPE,                  // 1: TD1; 3: TD3
    TREE_DEPTH,
    AA_FLOWS_NUMBER,               // activated Active Auth flows umber
    AA_FLOWS_BITMASK,              // bitmask of which Active Auth flows are active
    NoAA_FLOWS_NUMBER,              // activated NoAA (no active auth) flows
    NoAA_FLOWS_BITMASK              // bitmask of which NoAA (no active auth) flows are active
) {
    // OUTPUT SIGNALS:
    signal output dg15PubKeyHash;
    
    // Poseidon(Hash(signedAttributes)[252:])
    signal output passportHash;

    signal output dg1Commitment;

    // Poseidon2(PubKey.X, PubKey.Y)
    signal output pkIdentityHash;

    // INPUT SIGNALS:
    signal input encapsulatedContent[ENCAPSULATED_CONTENT_SIZE * HASH_BLOCK_SIZE];
    signal input dg1[DG1_SIZE * HASH_BLOCK_SIZE];
    signal input dg15[DG15_SIZE * HASH_BLOCK_SIZE];
    signal input signedAttributes[SIGNED_ATTRIBUTES_SIZE * HASH_BLOCK_SIZE];
    signal input signature[CHUNK_NUMBER];
    signal input publicKey[CHUNK_NUMBER];
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
        CHUNK_SIZE,
        CHUNK_NUMBER,
        TREE_DEPTH,
        AA_FLOWS_NUMBER,
        AA_FLOWS_BITMASK,
        NoAA_FLOWS_NUMBER,
        NoAA_FLOWS_BITMASK
    );
}

