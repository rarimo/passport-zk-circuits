include "./sha384/sha384_hash_bytes.circom";

template Main(N) {
    signal input in[N]; // assume bytes
    signal output out[48];

    out <== Sha384_hash_bytes_digest(N)(in);
    for(var i = 0; i < 48; i++) {
        log(out[i]);
    }
}

component main = Main(519);