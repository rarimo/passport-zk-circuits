pragma circom  2.1.6;

include "./circuits/registerIdentityBuilder.circom";

// HASH_TYPE: 
//   - 160: SHA1 (160 bits)
//   - 256: SHA2-256 (256 bits)
//   - 384: SHA2-384 (384 bits)
//   - 512: SHA2-512 (512 bits)

// SIGNATURE_TYPE:
//   - 1: RSA 2048 bits + SHA2-256
//   - 2: RSA 4096 bits + SHA2-256

component main = RegisterIdentityBuilder(
    2,         // DG1_SIZE
    6,         // DG15_SIZE
    6,         // ENCAPSULATED_CONTENT_SIZE
    2,         // SIGNED_ATTRIBUTES_SIZE
    512,       // HASH_BLOCK_SIZE
    256,       // HASH_TYPE
    1,         // SIGNATURE_TYPE
    64,        // CHUNK_SIZE
    32,        // CHUNK_NUMBER
    1,         // DOCUMENT_TYPE
    80,        // TREE_DEPTH
    [[]],      // [[DG1_SHIFT, DG15_SHIFT, EC_SHIFT, DG15_BLOCK_NUM, SA_BLOCK_NUM, DG15_CHECK], [...], ... , [...] ]
    1,         // FLOW_MATRIX_HEIGHT
    [[],[],[]] // HASH_MATRIX
);