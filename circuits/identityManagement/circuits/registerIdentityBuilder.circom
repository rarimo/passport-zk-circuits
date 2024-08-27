pragma circom  2.1.6;

// HASH_TYPE: 
//   - 160: SHA1 (160 bits)
//   - 256: SHA2-256 (256 bits)
//   - 384: SHA2-384 (384 bits)
//   - 512: SHA2-512 (512 bits)

// SIGNATURE_TYPE:
//   - 1: RSA 2048 bits + SHA2-256
//   - 2: RSA 4096 bits + SHA2-256

template RegisterIdentityBuilder (
    DG1_SIZE,                       // size in hash blocks
    DG15_SIZE,                      // size in hash blocks
    ENCAPSULATED_CONTENT_SIZE,      // size in hash blocks
    SIGNED_ATTRIBUTES_SIZE,         // size in hash blocks
    HASH_BLOCK_SIZE,                // size in bits
    HASH_TYPE,                      // 160, 256, 384, 512 (list above)^^^
    SIGNATURE_TYPE,                 // 1, 2..  (list above) ^^^
    RSA_FLOWS_NUMBER,               // activated RSA flows umber
    RSA_FLOWS_BITMASK,              // bitmask of which RSA flows are active
    ECDSA_FLOWS_NUMBER,             // activated ECDSA flows
    ECDSA_FLOWS_BITMASK,            // bitmask of which ECDSA flows are active
    NoAA_FLOWS_NUMBER,              // activated NoAA flows
    NoAA_FLOWS_BITMASK              // bitmask of which NoAA flows are active
) {

}

