const { decoded, Base64, Hex } = require("./asn1.js");
const { poseidon } = require("./poseidon.js");
const fs = require("fs");
const { createHash } = require("crypto");

const reHex = /^\s*(?:[0-9A-Fa-f][0-9A-Fa-f]\s*)+$/;
function print(x) {
  console.log(x);
}

function padding(hex, blockSizeBits = 512) {
  if (![512, 1024].includes(blockSizeBits)) {
    throw new Error('Unsupported block size. Use 512 or 1024 bits.');
  }

  const blockSizeBytes = blockSizeBits / 8;
  const lengthSizeBytes = blockSizeBits === 512 ? 8 : 16; // length field size in bytes (64 or 128 bits)
  
  // Convert hex string to bytes
  let bytes = [];
  for (let i = 0; i < hex.length; i += 2) {
    bytes.push(parseInt(hex.slice(i, i + 2), 16));
  }
  bytes = Uint8Array.from(bytes);
  const bytesLen = bytes.length;

  // Calculate padding length:
  // Message + 1 byte (0x80) + padding + lengthSizeBytes must be multiple of blockSizeBytes
  // padding length = (blockSizeBytes - ((bytesLen + 1 + lengthSizeBytes) % blockSizeBytes)) % blockSizeBytes
  const totalLenWith1AndLength = bytesLen + 1 + lengthSizeBytes;
  const paddingLen = (blockSizeBytes - (totalLenWith1AndLength % blockSizeBytes)) % blockSizeBytes;

  const totalLen = bytesLen + 1 + paddingLen + lengthSizeBytes;
  const blockCount = totalLen / blockSizeBytes;

  // Initialize blocks array (blockCount blocks of blockSizeBytes each)
  const blocksBytes = Array(blockCount)
    .fill(null)
    .map(() => Array(blockSizeBytes).fill(0));

  // Copy original bytes
  for (let i = 0; i < bytesLen; i++) {
    blocksBytes[Math.floor(i / blockSizeBytes)][i % blockSizeBytes] = bytes[i];
  }

  // Append 0x80 byte
  blocksBytes[Math.floor(bytesLen / blockSizeBytes)][bytesLen % blockSizeBytes] = 0x80;

  // Padding bytes are already zero initialized, so no need to fill zeros explicitly

  // Append length in bits as big-endian integer
  // For SHA-256 (512-bit blocks), length is 64 bits (8 bytes)
  // For SHA-384/512 (1024-bit blocks), length is 128 bits (16 bytes)
  const bitLen = BigInt(bytesLen) * 8n;

  // Create length buffer with lengthSizeBytes bytes
  const be_len = new Array(lengthSizeBytes).fill(0);

  if (blockSizeBits === 512) {
    // 64-bit length (8 bytes)
    let tmp_len = bitLen;
    for (let i = 0; i < 8; i++) {
      be_len[7 - i] = Number(tmp_len & 0xffn);
      tmp_len >>= 8n;
    }
  } else {
    // 128-bit length (16 bytes)
    // SHA-384/512 use 128-bit length, high 64 bits are zero for messages < 2^64 bits
    let tmp_len = bitLen;
    for (let i = 0; i < 16; i++) {
      be_len[15 - i] = Number(tmp_len & 0xffn);
      tmp_len >>= 8n;
    }
  }

  // Copy length bytes into blocks
  const lengthStart = totalLen - lengthSizeBytes;
  for (let i = 0; i < lengthSizeBytes; i++) {
    blocksBytes[Math.floor((lengthStart + i) / blockSizeBytes)][(lengthStart + i) % blockSizeBytes] = be_len[i];
  }

  // Convert blocks to hex string
  let hexResult = '';
  for (const block of blocksBytes) {
    for (const byte of block) {
      hexResult += byte.toString(16).padStart(2, '0');
    }
  }

  return hexResult;
}

function computeHash(outLen, input) {
  const hashAlgorithms = {
    20: "sha1",
    28: "sha224",
    32: "sha256",
    48: "sha384",
    64: "sha512",
  };

  const algorithm = hashAlgorithms[outLen];
  if (!algorithm) {
    throw new Error(
      "Invalid hash output length. Use 20, 28, 32, 48, or 64 bytes."
    );
  }

  const hash = createHash(algorithm).update(Buffer.from(input)).digest();
  return new Uint8Array(hash);
}

function bigintToArray(n, k, x) {
  const mod = BigInt(2) ** BigInt(n);
  let result = [];

  for (let i = 0; i < k; i++) {
    result.push(x % mod);
    x = x / mod;
  }

  return result;
}

function bigintToArrayString(n, k, x) {
  const mod = BigInt(2) ** BigInt(n);
  let result = [];

  for (let i = 0; i < k; i++) {
    result.push((x % mod).toString(10));
    x = x / mod;
  }

  return result;
}

function compute_barret_reduction(n_bits, n) {
  return BigInt(2) ** BigInt(2 * n_bits) / n;
}

// SIGNATURE_TYPE:
//   - 1: RSA 2048 bits + SHA2-256 + e = 65537
//   - 2: RSA 4096 bits + SHA2-256 + e = 65537
//   - 3: RSA 2048 bits + SHA1 + e = 65537

//   - 10: RSASSA-PSS 2048 bits MGF1 (SHA2-256) + SHA2-256 + e = 3 + salt = 32
//   - 11: RSASSA-PSS 2048 bits MGF1 (SHA2-256) + SHA2-256 + e = 65537 + salt = 32
//   - 12: RSASSA-PSS 2048 bits MGF1 (SHA2-256) + SHA2-256 + e = 65537 + salt = 64
//   - 13: RSASSA-PSS 2048 bits MGF1 (SHA2-384) + SHA2-384 + e = 65537 + salt = 48
//   - 14: RSASSA-PSS 3072 bits MGF1 (SHA2-256) + SHA2-256 + e = 65537 + salt = 32

//   - 20: ECDSA brainpoolP256r1 + SHA256
//   - 21: ECDSA secp256r1 + SHA256
//   - 22: ECDSA brainpoolP320r1 + SHA256
//   - 23: ECDSA secp192r1 + SHA1

function getSigType(pk, sig, hashType) {
  if (sig.salt) {
    // RSA PSS
    if (
      pk.n.length == 512 &&
      pk.exp == "3" &&
      sig.salt == "32" &&
      hashType == "32"
    ) {
      return 10;
    }
    if (
      pk.n.length == 512 &&
      pk.exp == "10001" &&
      sig.salt == "32" &&
      hashType == "32"
    ) {
      return 11;
    }
    if (
      pk.n.length == 512 &&
      pk.exp == "10001" &&
      sig.salt == "64" &&
      hashType == "32"
    ) {
      return 12;
    }
    if (
      pk.n.length == 512 &&
      pk.exp == "10001" &&
      sig.salt == "48" &&
      hashType == "48"
    ) {
      return 13;
    }
    if (
      pk.n.length == 768 &&
      pk.exp == "10001" &&
      sig.salt == "32" &&
      hashType == "32"
    ) {
      return 14;
    }
  }
  if (sig.salt == 0) {
    // RSA
    if (pk.n.length == 512 && pk.exp == "10001" && hashType == "32") {
      return 1;
    }
    if (pk.n.length == 1024 && pk.exp == "10001" && hashType == "32") {
      return 2;
    }
    if (pk.n.length == 512 && pk.exp == "10001" && hashType == "20") {
      return 3;
    }
  }
  if (sig.r) {
    // print(pk.param);
    switch (pk.param) {
      case "7D5A0975FC2C3057EEF67530417AFFE7FB8055C126DC5C6CE94A4B44F330B5D9":
        // BrainpoolP256r1
        return 21;

      case "FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC":
        // Secp256r1
        return 20;

      case "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFFFFFFFFFE":
        //secp224r1
        return 24;

      case "7BC382C63D8C150C3C72080ACE05AFA0C2BEA28E4FB22787139165EFBA91F90F8AA5814A503AD4EB04A8C7DD22CE2826":
        // BrainpoolP384r1
        return 25;

      case "7830A3318B603B89E2327145AC234CC594CBDD8D3DF91610A83441CAEA9863BC2DED5D5AA8253AA10A2EF1C98B9AC8B57F1117A72BF2C7B9E7C1AC4D77FC94CA":
        //BrainpoolP512r1
        return 26;

      case "secp521r1":
        return 27;
      default:
        return 0;
    }
  }

  return 0;
}

function hexStringToBytes(hexString) {
  hexString = hexString.replace(/\s+/g, "");

  const bytes = [];

  for (let i = 0; i < hexString.length; i += 2) {
    const byte = parseInt(hexString.substr(i, 2), 16);
    bytes.push(byte);
  }

  return bytes;
}

function readJsonFileSync(filePath) {
  try {
    const data = fs.readFileSync(filePath, "utf8");
    const json = JSON.parse(data);
    return json;
  } catch (error) {
    console.error("Error reading or parsing file:", error);
  }
}

function getFirstOctetString(asn1) {
  // EC - first octet string of sod
  if (asn1.name === "OCTET_STRING") {
    return asn1;
  }

  // find first one with recursion
  if (Array.isArray(asn1.sub)) {
    for (let child of asn1.sub) {
      const result = getFirstOctetString(child);
      if (result) {
        return result;
      }
    }
  }
}

function extract_encapsulated_content(asn1) {
  const ec = getFirstOctetString(asn1);

  let hashType = ec.sub[0].sub[2].sub[0].sub[1].length;

  return [ec.content, hashType];
}

function getDg1Shift(asn1, dg1, dgHashType) {
  const ec = getFirstOctetString(asn1);
  const dg1Hash = computeHash(dgHashType, dg1);
  return (
    ec.content.toLowerCase().split(Buffer.from(dg1Hash).toString("hex"))[0]
      .length / 2
  );
}

function getDg15Shift(asn1, dg15, dgHashType) {
  const ec = getFirstOctetString(asn1);
  const dg15Hash = computeHash(dgHashType, dg15);
  return (
    ec.content.toLowerCase().split(Buffer.from(dg15Hash).toString("hex"))[0]
      .length / 2
  );
}

function getEcShift(asn1, ec, hashType) {
  let sa = getZero(asn1);
  const ecHash = computeHash(hashType, ec);

  return (
    sa.dump.toLowerCase().split(Buffer.from(ecHash).toString("hex"))[0].length /
    2
  );
}

function getZero(asn1) {
  if (!asn1) return null;

  // Check if this element is '[0]'
  if (asn1.name === "[0]") {
    // Check if it has a last 'sub' with 'SEQUENCE' and 'content' is "(2 elem)"
    if (
      asn1.sub &&
      asn1.sub[asn1.sub?.length - 1]?.name === "SEQUENCE" &&
      asn1.sub[asn1.sub?.length - 1]?.content === "(2 elem)"
    ) {
      const sequenceSub = asn1.sub[asn1.sub?.length - 1].sub;

      // Check the first sub-element: it should be "OBJECT_IDENTIFIER"
      if (sequenceSub && sequenceSub[0]?.name === "OBJECT_IDENTIFIER") {
        // Check the second sub-element: it should be "SET"
        if (sequenceSub[1]?.name === "SET") {
          // Check if SET has only one sub-element with name "OCTET_STRING"
          if (
            sequenceSub[1]?.sub?.length === 1 &&
            sequenceSub[1]?.sub[0]?.name === "OCTET_STRING"
          ) {
            return asn1; // Found the element that satisfies the condition
          }
        }
      }
    }
  }
  if (Array.isArray(asn1.sub)) {
    for (let child of asn1.sub) {
      const result = getZero(child);
      if (result) return result; // Return the first match found
    }
  }

  return null;
}

function extract_signed_atributes(asn1) {
  let sa = getZero(asn1);

  const hashType = sa.sub.slice(-1)[0].sub.slice(-1)[0].sub[0].length;

  return ["31" + sa.dump.slice(2), hashType];
}

function extract_signature(asn1) {
  var [octet, parent] = findParentOfLastOctetString(asn1);
  const salt = parent.sub.slice(-2, -1)[0].sub.slice(-1)[0].sub?.slice(-1)[0]
    .sub[0].content
    ? parent.sub.slice(-2, -1)[0].sub.slice(-1)[0].sub.slice(-1)[0].sub[0]
        .content
    : 0;
  if (octet.sub) {
    // ECDSA SIG
    let sig = {
      r: BigInt(octet.sub[0].sub[0].content, 10).toString(16).toLowerCase(),
      s: BigInt(octet.sub[0].sub[1].content, 10).toString(16).toLowerCase(),
    };
    return sig;
  } else {
    return { n: octet.content, salt: salt };
  }
}

function findParentOfLastOctetString(asn1, parent = null) {
  let result = null;
  let lastParent = null;

  // If current element is an OCTET_STRING, update result and lastParent
  if (asn1.name === "OCTET_STRING") {
    result = asn1;
    lastParent = parent;
  }

  // Recursively search in sub-elements (if any)
  if (asn1.sub && Array.isArray(asn1.sub)) {
    for (let child of asn1.sub) {
      const [childResult, childParent] = findParentOfLastOctetString(
        child,
        asn1
      );
      if (childResult) {
        result = childResult;
        lastParent = childParent;
      }
    }
  }

  return [result, lastParent];
}

function get_ecdsa_key_location(asn1) {
  // we want to get point and curve info
  if (asn1.sub && asn1.sub.length >= 2) {
    const secondChild = asn1.sub[1];
    if (
      secondChild.name === "BIT_STRING" &&
      secondChild.content.startsWith("00000100")
    ) {
      return asn1; // Return the element if the conditions are met
    }
  }

  // Recursively search in sub-elements (if any)
  if (asn1.sub && Array.isArray(asn1.sub)) {
    for (let child of asn1.sub) {
      const result = get_ecdsa_key_location(child);
      if (result) {
        return result; // Return the found element
      }
    }
  }

  return null; // Return null if no matching element is found
}

function extract_ecdsa_pubkey(asn1) {
  const asn1_location = get_ecdsa_key_location(asn1);
  // console.log(asn1_location)

  let pubkey = asn1_location.sub[1].content.slice(8);
  let x = BigInt("0b" + pubkey.slice(0, pubkey.length / 2)).toString(16);
  let y = BigInt("0b" + pubkey.slice(pubkey.length / 2)).toString(16);

  // let curve_param = BigInt(asn1_location.sub[0].sub[1].sub.slice(-1)[0].content, 10).toString(16)

  let curve_param = asn1_location.sub[0].sub[1].sub
    ? asn1_location.sub[0].sub[1].sub[2].sub[0].content
    : asn1_location.sub[0].sub[1].content.split("\n")[1];
  return { x: x, y: y, param: curve_param };
}

function get_rsa_key_location(asn1) {
  if (asn1.name === "BIT_STRING" && Array.isArray(asn1.sub)) {
    // Look for the SEQUENCE child
    for (let child of asn1.sub) {
      if (child.name === "SEQUENCE" && Array.isArray(child.sub)) {
        // Check if SEQUENCE has exactly 2 children with the name "INTEGER"
        if (
          child.sub.length === 2 &&
          child.sub[0].name === "INTEGER" &&
          child.sub[1].name === "INTEGER"
        ) {
          return asn1; // Return the BIT_STRING element
        }
      }
    }
  }

  // Recursively search through sub-elements
  if (asn1.sub && Array.isArray(asn1.sub)) {
    for (let child of asn1.sub) {
      const result = get_rsa_key_location(child);
      if (result) return result; // Return the found element
    }
  }

  return null; // Return null if no match is found
}

function extract_rsa_pubkey(asn1) {
  const asn1_location = get_rsa_key_location(asn1);

  let pk = BigInt(asn1_location.sub[0].sub[0].content, 10).toString(16);
  let exp = BigInt(asn1_location.sub[0].sub[1].content, 10).toString(16);

  return { n: pk, exp: exp };
}

function extractFromDg15(dg15) {
  if (!dg15) {
    return [0, 0, 0];
  }
  let dg15_decoded = decoded(dg15);
  let pk;
  let aa_shift = 0;
  let pk_type =
    dg15_decoded.sub[0].sub[1].content.slice(0, 8) == "00000100"
      ? "ecdsa"
      : "rsa";
  let aa_sig_type = 0;
  // print(pk_type);
  if (pk_type == "ecdsa") {
    let pk_bit = dg15_decoded.sub[0].sub[1].content.slice(8);
    pk = {
      x: pk_bit.slice(0, pk_bit.length / 2),
      y: pk_bit.slice(pk_bit.length / 2),
    };
    const p = BigInt(dg15_decoded.sub[0].sub[0].sub[1].sub[4].content)
      .toString(16)
      .toLocaleUpperCase();

    switch (p) {
      case "A9FB57DBA1EEA9BC3E660A909D838D718C397AA3B561A6F7901E0E82974856A7": {
        // brainpoolP256r1
        aa_sig_type = 21;
        break;
      }
      case "FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF": {
        // secp256r1
        aa_sig_type = 20;
        break;
      }
      case "D35E472036BC4FB7E13C785ED201E065F98FCFA6F6F40DEF4F92B9EC7893EC28FCD412B1F1B32E27": {
        // brainpool320r1
        aa_sig_type = 22;
        break;
      }
      case "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFFFFFFFFFF": {
        // secp192r1
        aa_sig_type = 23;
        break;
      }
      default:
        aa_sig_type = "unknown tech!";
    }
    aa_shift =
      dg15_decoded.dump.split(BigInt(`0b${pk.x}`).toString(16).toUpperCase())[0]
        .length / 2;
  }
  if (pk_type == "rsa") {
    let pk_location = dg15_decoded.sub[0].sub[1].sub[0];
    let n = pk_location.sub[0].content;
    let exp = pk_location.sub[1].content;

    pk = {
      n: n,
      exp: exp,
    };

    // if (BigInt(pk.n).toString(16).length == 384){
    //     aa_sig_type = 3;
    // }
    // if (BigInt(pk.n).toString(16).length == 256){
    //     if (pk.exp.toString() == "3"){
    //         aa_sig_type = 2;
    //     } else {
    //         aa_sig_type = 1;
    //     }
    // }

    aa_sig_type = 1;
    aa_shift =
      dg15_decoded.dump.split(BigInt(pk.n).toString(16).toUpperCase())[0]
        .length / 2;
  }

  return [pk, aa_shift, aa_sig_type];
}

function writeToCircom(
  sig_algo,
  dg_hash_type,
  doc_type,
  ec_blocks,
  ec_shift,
  dg1_shift,
  dg15_sig_algo,
  dg15_shift,
  dg15_blocks,
  aa_shift,
  name
) {
  let str = `pragma circom 2.1.6;\n\ninclude "../../../circuits/identityManagement/registerIdentityBuilder.circom";\n\ncomponent main { public [slaveMerkleRoot] } = RegisterIdentityBuilder(\n\t${sig_algo}, //sig algo\n\t${dg_hash_type}, //dg hash type\n\t${doc_type}, //document type\n\t${ec_blocks}, //ec len in blocks\n\t${ec_shift}, // ec_shift\n\t${dg1_shift}, //dg1 shift\n\t${dg15_sig_algo}, //dg15 sig algo (0 if no present)\n\t${dg15_shift}, //dg15 shift\n\t${dg15_blocks}, //dg15 len in blocks\n\t${aa_shift} //AA shift in bits\n);`;
  fs.writeFileSync(`test/circuits/generated/${name}.circom`, str);
}

function getChunkedParams(pk, sig) {
  const ec_field_size = pk.param
    ? reHex.test(pk.param)
      ? pk.param.length * 4
      : pk.param.match(/\d+/)
        ? parseInt(pk.param.match(/\d+/)[0], 10)
        : "UNKNOWN FIELD SIZE"
    : 0;
  const chunk_number =
    ec_field_size <= 512
      ? pk.x
        ? Math.ceil(pk.x.length / 16)
        : Math.ceil(pk.n.length / 16)
      : 8;
  const chunk_size = ec_field_size > 512 ? 66 : 64;
  const pk_chunked = pk.x
    ? bigintToArrayString(chunk_size, chunk_number, BigInt("0x" + pk.x)).concat(
        bigintToArrayString(chunk_size, chunk_number, BigInt("0x" + pk.y))
      )
    : bigintToArrayString(chunk_size, chunk_number, BigInt("0x" + pk.n));
  const sig_chunked = pk.x
    ? bigintToArrayString(
        chunk_size,
        chunk_number,
        BigInt("0x" + sig.r)
      ).concat(
        bigintToArrayString(chunk_size, chunk_number, BigInt("0x" + sig.s))
      )
    : bigintToArrayString(chunk_size, chunk_number, BigInt("0x" + sig.n));

  return {
    ec_field_size: ec_field_size,
    chunk_number: ec_field_size != 0 ? chunk_number * 2 : chunk_number,
    pk_chunked: pk_chunked,
    sig_chunked: sig_chunked,
  };
}

function getFakeIdenData(ec, pk) {
  const branches = new Array(80).fill(0);
  const sk_iden = Buffer.from(computeHash(32, ec)).toString("hex").slice(0, 62);
  let pk_hash;
  if (pk.x) {
    if (pk.x.length <= 62) {
      pk_hash = poseidon([BigInt("0x" + pk.x), BigInt("0x" + pk.y)]);
    } else {
      pk_hash = poseidon([
        BigInt("0x" + pk.x.slice(pk.x.length - 62)),
        BigInt("0x" + pk.y.slice(pk.y.length - 62)),
      ]);
    }
  } else {
    let pk_arr = bigintToArray(64, 15, BigInt("0x" + pk.n));
    pk_hash = poseidon(
      Array.from(
        { length: 5 },
        (_, i) =>
          pk_arr[3 * i] * 2n ** 128n +
          pk_arr[3 * i + 1] * 2n ** 64n +
          pk_arr[3 * i + 2]
      )
    );
  }

  const root = poseidon([pk_hash, pk_hash, 1n]).toString(16);

  return [sk_iden, root, branches];
}

function writeToJson(dg1, dg15, sa, ec, pk, sig, sk_iden, root, name) {
  let json = {
    dg1: dg1,
    dg15: dg15,
    signedAttributes: sa,
    encapsulatedContent: ec,
    pubkey: pk,
    signature: sig,
    skIdentity: "0x" + sk_iden,
    slaveMerkleRoot: "0x" + root,
    slaveMerkleInclusionBranches: new Array(80).fill("0"),
  };
  fs.writeFileSync(`test/inputs/generated/${name}.json`, JSON.stringify(json));
}

function processPassport(filePath) {
  // Extract json data
  const json = readJsonFileSync(filePath);

  // Get dg1 and dg15 from json
  const dg1_bytes = json.dg1
    ? reHex.test(json.dg1)
      ? Hex.decode(json.dg1)
      : Base64.unarmor(json.dg1)
    : [];
  const dg15_bytes = reHex.test(json.dg15)
    ? Hex.decode(json.dg15)
    : Base64.unarmor(json.dg15);

  // decode sod
  const asn1_decoded = decoded(json.sod);
  // get ec in hex and bytes
  const [ec_hex, dg_hash_type] = extract_encapsulated_content(asn1_decoded);

  const ec_bytes = hexStringToBytes(ec_hex);

  // get sa in hex and bytes
  const [sa_hex, hash_type] = extract_signed_atributes(asn1_decoded);

  const dgHashBlockLen = dg_hash_type <= 32 ? 512 : 1024;
  const hashBlockLen = hash_type <= 32 ? 512 : 1024;
  const sa_bytes = hexStringToBytes(sa_hex);

  let dg1_padded = dg1_bytes
    ? BigInt(
        "0x" +
          padding(
            Array.from(dg1_bytes)
              .map((b) => b.toString(16).padStart(2, "0"))
              .join(""), dgHashBlockLen
          )
      )
        .toString(2)
        .split("")
    : [];

  if (dg1_padded.length % dgHashBlockLen !== 0) {
    const zerosToAdd = dgHashBlockLen - (dg1_padded.length % dgHashBlockLen);
    dg1_padded = Array(zerosToAdd).fill("0").concat(dg1_padded);
  }

  let dg15_padded =
    dg15_bytes.length != 0
      ? BigInt(
          "0x" +
            padding(
              Array.from(dg15_bytes)
                .map((b) => b.toString(16).padStart(2, "0"))
                .join(""), dgHashBlockLen
            )
        )
          .toString(2)
          .split("")
      : [];

  if (dg15_bytes.length != 0 && dg15_padded.length % dgHashBlockLen !== 0) {
    const zerosToAdd = dgHashBlockLen - (dg15_padded.length % dgHashBlockLen);
    dg15_padded = Array(zerosToAdd).fill("0").concat(dg15_padded);
  }

  let ec_padded = BigInt("0x" + padding(ec_hex, hashBlockLen))
    .toString(2)
    .split("");

  if (ec_padded.length % hashBlockLen !== 0) {
    const zerosToAdd = hashBlockLen - (ec_padded.length % hashBlockLen);
    ec_padded = Array(zerosToAdd).fill("0").concat(ec_padded);
  }

  let sa_padded = BigInt("0x" + padding(sa_hex, hashBlockLen))
    .toString(2)
    .split("");

  if (sa_padded.length % hashBlockLen !== 0) {
    const zerosToAdd = hashBlockLen - (sa_padded.length % hashBlockLen);
    sa_padded = Array(zerosToAdd).fill("0").concat(sa_padded);
  }

  // get signature
  const sig = extract_signature(asn1_decoded);

  // get ecdsa if r s in sig, else rsa
  const pk =
    sig.salt || sig.salt == 0
      ? extract_rsa_pubkey(asn1_decoded)
      : extract_ecdsa_pubkey(asn1_decoded);
  // get sig algo
  const sigType = getSigType(pk, sig, hash_type);

  if (sigType == 0) print("UNKNOWN TECHONOLY");

  // get Shifts
  const dg1_shift = getDg1Shift(asn1_decoded, dg1_bytes, dg_hash_type) * 8;
  const ec_shift = getEcShift(asn1_decoded, ec_bytes, hash_type) * 8;
  const dg15_shift = dg15_bytes.length
    ? getDg15Shift(asn1_decoded, dg15_bytes, dg_hash_type) * 8
    : 0;

  // get dg15 info
  const [aa_pk, aa_shift, aa_sig_type] = extractFromDg15(json.dg15);

  const chunked = getChunkedParams(pk, sig);

  const [sk_iden, icao_root, branches] = getFakeIdenData(ec_bytes, pk);
  const old_naming_convention = `registerIdentity_${sigType}_${dg_hash_type * 8}_${dg1_bytes.length == 93 ? 3 : 1}_${hash_type <= 32 ? Math.ceil((ec_bytes.length + 8) / 64) : Math.ceil((ec_bytes.length + 8) / 128)}_${ec_shift * 8}_${dg1_shift * 8}_${dg15_bytes.length == 0 ? "NA" : aa_sig_type + "_" + dg15_shift * 8 + "_" + (dg_hash_type <= 32 ? Math.ceil((dg15_bytes.length + 8) / 64) : Math.ceil((dg15_bytes.length + 8) / 128)) + "_" + aa_shift * 8}`;

  writeToCircom(
    sigType,
    dg_hash_type * 8,
    dg1_bytes.length == 93 ? 3 : 1,
    hash_type <= 32
      ? Math.ceil((ec_bytes.length + 8) / 64)
      : Math.ceil((ec_bytes.length + 8) / 128),
    ec_shift,
    dg1_shift,
    aa_sig_type,
    dg15_shift,
    dg15_bytes.length != 0
      ? dg_hash_type <= 32
        ? Math.ceil((dg15_bytes.length + 8) / 64)
        : Math.ceil((dg15_bytes.length + 8) / 128)
      : 0,
    aa_shift,
    old_naming_convention
  );
  writeToJson(
    dg1_padded,
    dg15_padded,
    sa_padded,
    ec_padded,
    chunked.pk_chunked,
    chunked.sig_chunked,
    sk_iden,
    icao_root,
    old_naming_convention
  );
  return old_naming_convention;
}

// processPassport("inputs/passport/esp_luis_ruiz_martin.json");

module.exports.processPassport = processPassport;
