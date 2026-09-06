pragma circom  2.1.6;

function div_ceil(m, CHUNK_SIZE) {
    var ret = 0;
    if (m % CHUNK_SIZE == 0) {
        ret = m \ CHUNK_SIZE;
    } else {
        ret = m \ CHUNK_SIZE + 1;
    }
    return ret;
}