pragma circom 2.0.0;

//------------------------------------------------------------------------------
// decompose a 2-bit number into a high and a low bit

template Bits2() {
  signal input  xy;
  signal output lo;
  signal output hi;

  lo <--  xy     & 1;
  hi <-- (xy>>1) & 1;

  lo*(1-lo) === 0;
  hi*(1-hi) === 0;

  xy === 2*hi + lo;
}

//------------------------------------------------------------------------------
// XOR 3 bits together

template XOR3_v1() {
  signal input  x;
  signal input  y;
  signal input  z;
  signal output out;

  component bs = Bits2();
  bs.xy <== x + y + z;
  bs.lo ==> out;
}

//------------------
// same number of constraints (that is, 2), in the general case
// however circom can optimize y=0 or z=0, unlike with the above
// and hopefully also x=0.

template XOR3_v2() {
  signal input  x;
  signal input  y;
  signal input  z;
  signal output out;

  signal tmp <== y*z;
  out <== x * (1 - 2*y - 2*z + 4*tmp) + y + z - 2*tmp;
}

//------------------------------------------------------------------------------
// decompose an n-bit number into bits

template ToBits(n) {
  signal input  inp;
  signal output out[n];

  var sum = 0;
  for(var i=0; i<n; i++) {
    out[i] <-- (inp >> i) & 1;
    out[i] * (1-out[i]) === 0;
    sum += (1<<i) * out[i];
  }

  inp === sum;
}

//------------------------------------------------------------------------------
// decompose a 33-bit number into the low 32 bits and the remaining 1 bit

template Bits33() {
  signal input  inp;
  signal output outBits[32];
  signal output outWord;
  signal u;

  var sum = 0;
  for(var i=0; i<32; i++) {
    outBits[i] <-- (inp >> i) & 1;
    outBits[i] * (1-outBits[i]) === 0;
    sum += (1<<i) * outBits[i];
  }

  u <-- (inp >> 32) & 1;
  u*(1-u) === 0;

  inp === sum + (1<<32)*u;
  outWord <== sum;
}

//------------------------------------------------------------------------------
// decompose a 34-bit number into the low 32 bits and the remaining 2 bits

template Bits34() {
  signal input  inp;
  signal output outBits[32];
  signal output outWord;
  signal u,v;

  var sum = 0;
  for(var i=0; i<32; i++) {
    outBits[i] <-- (inp >> i) & 1;
    outBits[i] * (1-outBits[i]) === 0;
    sum += (1<<i) * outBits[i];
  }

  u <-- (inp >> 32) & 1;
  v <-- (inp >> 33) & 1;
  u*(1-u) === 0;
  v*(1-v) === 0;

  inp === sum + (1<<32)*u + (1<<33)*v;
  outWord <== sum;
}

//------------------------------------------------------------------------------
// decompose a 35-bit number into the low 32 bits and the remaining 3 bits

template Bits35() {
  signal input  inp;
  signal output outBits[32];
  signal output outWord;
  signal u,v,w;

  var sum = 0;
  for(var i=0; i<32; i++) {
    outBits[i] <-- (inp >> i) & 1;
    outBits[i] * (1-outBits[i]) === 0;
    sum += (1<<i) * outBits[i];
  }

  u <-- (inp >> 32) & 1;
  v <-- (inp >> 33) & 1;
  w <-- (inp >> 34) & 1;
  u*(1-u) === 0;
  v*(1-v) === 0;
  w*(1-w) === 0;

  inp === sum + (1<<32)*u + (1<<33)*v + (1<<34)*w;
  outWord <== sum;
}

//------------------------------------------------------------------------------
// decompose a 65-bit number into the low 64 bits and the remaining 1 bit

template Bits65() {
  signal input  inp;
  signal output outBits[64];
  signal output outWord;
  signal u;

  var sum = 0;
  for(var i=0; i<64; i++) {
    outBits[i] <-- (inp >> i) & 1;
    outBits[i] * (1-outBits[i]) === 0;
    sum += (1<<i) * outBits[i];
  }

  u <-- (inp >> 64) & 1;
  u*(1-u) === 0;

  inp === sum + (1<<64)*u;
  outWord <== sum;
}

//------------------------------------------------------------------------------
// decompose a 66-bit number into the low 64 bits and the remaining 2 bit

template Bits66() {
  signal input  inp;
  signal output outBits[64];
  signal output outWord;
  signal u,v;

  var sum = 0;
  for(var i=0; i<64; i++) {
    outBits[i] <-- (inp >> i) & 1;
    outBits[i] * (1-outBits[i]) === 0;
    sum += (1<<i) * outBits[i];
  }

  u <-- (inp >> 64) & 1;
  v <-- (inp >> 65) & 1;
  u*(1-u) === 0;
  v*(1-v) === 0;

  inp === sum + (1<<64)*u + (1<<65)*v;
  outWord <== sum;
}


//------------------------------------------------------------------------------
// decompose a 67-bit number into the low 64 bits and the remaining 3 bit

template Bits67() {
  signal input  inp;
  signal output outBits[64];
  signal output outWord;
  signal u,v,w;

  var sum = 0;
  for(var i=0; i<64; i++) {
    outBits[i] <-- (inp >> i) & 1;
    outBits[i] * (1-outBits[i]) === 0;
    sum += (1<<i) * outBits[i];
  }

  u <-- (inp >> 64) & 1;
  v <-- (inp >> 65) & 1;
  w <-- (inp >> 66) & 1;
  u*(1-u) === 0;
  v*(1-v) === 0;
  w*(1-w) === 0;

  inp === sum + (1<<64)*u + (1<<65)*v + (1<<66)*w;
  outWord <== sum;
}

//------------------------------------------------------------------------------
// converts a sequence of `n` big-endian 32-bit words to `4n` bytes
// (to be compatible with the output hex string of standard SHA2 tools)

template DWordsToByteString(n) { 
  
  signal input  inp[n][32];
  signal output out[4*n];

  for(var k=0; k<n; k++) {
    for(var j=0; j<4; j++) {

      var sum = 0;
      for(var i=0; i<8; i++) {
        sum += inp[k][j*8+i] * (1<<i);
      }

      out[k*4 + (3-j)] <== sum;
    }
  }
}

//------------------------------------------------------------------------------
// converts a sequence of `n` big-endian 64-bit words to `8n` bytes
// (to be compatible with the output hex string of standard SHA2 tools)

template QWordsToByteString(n) { 
  
  signal input  inp[n][64];
  signal output out[8*n];

  for(var k=0; k<n; k++) {
    for(var j=0; j<8; j++) {

      var sum = 0;
      for(var i=0; i<8; i++) {
        sum += inp[k][j*8+i] * (1<<i);
      }

      out[k*8 + (7-j)] <== sum;
    }
  }
}

//------------------------------------------------------------------------------

// ---- ported from lib/circuits/hasher/sha2/sha2Common.circom (SHA padding) ----

function process_padding(LEN, LEN_PADDED){
    
    var tmp_len = LEN;
    var bit_len[128];
    var len_bit_len = 0;
    var is_zero = 0;
    for (var i = 0; i < 128; i++){
        bit_len[i] = tmp_len % 2;
        tmp_len = tmp_len \ 2;
        if (tmp_len == 0 && is_zero == 0){
            len_bit_len = i + 1;
            is_zero = 1;
            
        }
    }
    var padding[1536]; 
   
    padding[0] = 1;
    for (var i = 1; i < LEN_PADDED - LEN - len_bit_len; i++){
        padding[i] = 0;
    }
    for (var i = LEN_PADDED - LEN - 1; i >= LEN_PADDED - LEN - len_bit_len; i--){
        padding[i] = bit_len[LEN_PADDED - LEN - 1 - i];
    }

    return padding;
}

// Universal sha-1 and sha-2 padding.
// HASH_BLOCK_SIZE is 512 for sha-1, sha2-224, sha2-256
// HASH_BLOCK_SIZE is 1024 for sha2-384, sha2-512
// LEN is bit len of message
template ShaPadding(LEN, HASH_BLOCK_SIZE){

    var CHUNK_NUMBER = ((LEN + 1 + 128) + HASH_BLOCK_SIZE - 1) \ HASH_BLOCK_SIZE;

    signal input in[LEN];
    signal output out[CHUNK_NUMBER * HASH_BLOCK_SIZE];

    for (var i = 0; i < LEN; i++){
        out[i] <== in[i];
    }

    var padding[1536] = process_padding(LEN, CHUNK_NUMBER * HASH_BLOCK_SIZE);
    for (var i = LEN; i < CHUNK_NUMBER * HASH_BLOCK_SIZE; i++){
        out[i] <== padding[i - LEN];
    }

}
