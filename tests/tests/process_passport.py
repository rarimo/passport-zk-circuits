import json
import base64
import subprocess
import re
import argparse

from write_to_files import *
from padding import *
from hasher import *
from utils import *

def get_new_sig_type(sig_type, salt, e_bits):
    if sig_type == 7:
        sig_type = 21
    if sig_type == 6: 
        sig_type = 20
    if sig_type == 3 and e_bits == 2:
        sig_type = 10
    if sig_type == 3 and e_bits == 17 and salt == 32:
        sig_type = 11
    if sig_type == 3 and e_bits == 17 and salt == 64:
        sig_type = 12
    if sig_type == 5:
        sig_type = 13
    if sig_type == 4:
        sig_type = 14
    return sig_type

def get_AA_shift_and_pubkey(dg15_hex, dg15_sig_algo, dg15_base64):
    if dg15_sig_algo == 20 or dg15_sig_algo == 21:
        
        return (len(dg15_hex) - 128)*4, [dg15_hex[-128:-64], dg15_hex[-64:]]
    if dg15_sig_algo == 22:
        return (len(dg15_hex) - 160)*4, [dg15_hex[-160:-80], dg15_hex[-80:]]
    if dg15_sig_algo == 23:
        return (len(dg15_hex) - 96)*4, [dg15_hex[-96:-48], dg15_hex[-48:]]
    

    dg15_bytes = base64.b64decode(dg15_base64)
    
    with open('temp_asn1.der', 'wb') as file:
        file.write(dg15_bytes)

    decoded = parse_asn1("temp_asn1.der")
    print(decoded)
    pos = 0 
    hl= 0
    for line in decoded.split('\n'):
        if 'BIT STRING' in line:
            pos = int(line.split('l=')[2].split(" ")[1])
            hl = int(line.split('hl=')[1][0])

    e_bits = dg15_hex.split("02")[-1][2::1]
    pub_len = pos - (len(e_bits) + 4) - hl
    pub_len_bits = 8 * (pub_len-pub_len%2)
    pubkey = dg15_hex[-(len(e_bits) + 4 + (pub_len-pub_len%2)*2):-(len(e_bits) + 4)]
    return len(dg15_hex)*4 - pub_len_bits - (len(e_bits)+4)*4, pubkey


def padd_dg1(dg1_hex, dg_chunk_size):
    _, dg1_padded, _ = process_and_pad_hex(dg1_hex, dg_chunk_size)
    return format_bit_string(dg1_padded)

def process_dg1(passport_file):
    with open(passport_file, 'r') as f:
        passport_data = json.load(f)

    dg1_base64 = passport_data.get('dg1', '')
    dg1_hex = base64_to_hex(dg1_base64)

    return dg1_hex

def padd_dg15(dg15_hex, dg_chunk_size):
    dg15_padded = ""
    dg15_blocks = 1
    if dg15_hex:
        _, dg15_padded, dg15_blocks = process_and_pad_hex(dg15_hex, dg_chunk_size)

    dg15_padded_to_many = ""
    if dg_chunk_size == 512:
        dg15_padded_to_many = pad_array_to_4096(format_bit_string(dg15_padded))
    else:
        dg15_padded_to_many = pad_array_to_8192(format_bit_string(dg15_padded))

    return dg15_blocks, dg15_padded_to_many

def process_dg15(passport_file):
    with open(passport_file, 'r') as f:
        passport_data = json.load(f)

    dg15_base64 = passport_data.get('dg15', '')
    dg15_hex = "0"

    if dg15_base64:
        dg15_hex = base64_to_hex(dg15_base64)
    return dg15_hex, dg15_base64

def process_ec(asn1_data, chunk_size):
    octet_strings_pattern = re.compile(r'OCTET STRING.*')
    octet_strings = octet_strings_pattern.findall(asn1_data)
    ec_hex = str(octet_strings[0]).split(":")[1]

    _, ec_padded, ec_blocks = process_and_pad_hex(ec_hex, chunk_size)

    if chunk_size == 512:
        ec_padded_to_many = pad_array_to_4096(format_bit_string(ec_padded))
    else:
        ec_padded_to_many = pad_array_to_8192(format_bit_string(ec_padded))
    
    return ec_hex, ec_padded_to_many, ec_blocks

def get_sa(sod_hex, sa_locations, chunk_size):
    sa = ""
    for [n, l] in sa_locations:
        if (sod_hex[n*2] == "a" and sod_hex[n*2+1] == "0" and (sod_hex[n*2 + 2] == "6" or sod_hex[n*2 + 2] == "4" or sod_hex[n*2 + 2] == "5")):
            sa = "31" + sod_hex[n*2+2:n*2+l*2]
    if (sa == ""):
        n = sa_locations[-3][0]
        l = sa_locations[-3][1]
        sa = "31" + sod_hex[n*2+2:n*2+l*2]

    _, sa_padded, _ = process_and_pad_hex(sa, chunk_size)
    sa_res = format_bit_string(sa_padded)
    return sa, sa_res

def process_sa(asn1_data):
    lines = asn1_data.split('\n')
    cont_lines = [line for line in lines if 'cont [ 0 ]' in line]
    sa_locations = []
    for line in cont_lines:
        filtered_list = [s for s in line.split("l=")[2].split(" ") if s]
        sa_locations.append([int(line.split(":")[0]), int(filtered_list[0]) + 2])
    return sa_locations

def process_pubkey(asn1_data):
    lines = asn1_data.split('\n')
    # print(asn1_data)s

    pubkey_ecdsa_location = 0

    rsa_pubkey_location = 0

    pubkey_ecdsa_lines = [line for line in lines if 'l=  66' in line]
    pubkey_ecdsa_lines_224 = [line for line in lines if 'l=  58' in line]

    rsa_pubkey_locations = [line for line in lines if 'BIT STRING' in line]

    rsa_pubkey_len = int([s for s in rsa_pubkey_locations[0].split(" l=")[1].split(" ") if s][0])

    rsa_pubkey_location = int([s for s in rsa_pubkey_locations[0].split(":")[0].split(" ") if s][0])

    for line in pubkey_ecdsa_lines:
        if "BIT STRING" in line:
            filtered_list = [s for s in line.split(":")[0].split(" ") if s]
            pubkey_ecdsa_location = int(filtered_list[0])
    for line in pubkey_ecdsa_lines_224:
        if "BIT STRING" in line:
            filtered_list = [s for s in line.split(":")[0].split(" ") if s]
            pubkey_ecdsa_location = int(filtered_list[0])

    return pubkey_ecdsa_location, rsa_pubkey_location, rsa_pubkey_len 

def process_algo(asn1_data):
    lines = asn1_data.split('\n')

    hash_locations = [line for line in lines if 'sha' in str.lower(line)]
    hash_type = int(str.lower(hash_locations[-1]).split("sha")[1][:3])
    chunk_size = 512 if hash_type <= 256 else 1024
    return hash_type, chunk_size

def process_sign(asn1_data):
    octet_strings_pattern = re.compile(r'OCTET STRING.*')
    octet_strings = octet_strings_pattern.findall(asn1_data)
    sign = str(octet_strings[-1]).split(":")[1]

    return sign

def process_salt(asn1_data):
    
    lines = asn1_data.split('\n')
    salt = 0
    if ("INTEGER" in lines[-3]):
        salt = int(lines[-3].split(":")[-1], 16)

    return salt

def parse_asn1(file_path):
    try:
        # Run OpenSSL asn1parse command
        result = subprocess.run(['openssl', 'asn1parse', '-in', file_path, '-inform', 'DER'],
                                capture_output=True, text=True, check=True)
        
        # Return the parsed ASN.1 data as a string
        return result.stdout
    except subprocess.CalledProcessError as e:
        print("Error parsing ASN.1 data:", e)
        return ""

def get_ans1_data(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
    
    sod_base64 = data.get('sod', '')

    sod_bytes = base64.b64decode(sod_base64)

    sod_hex = base64.b64decode(sod_base64).hex()
    
    with open('temp_asn1.der', 'wb') as file:
        file.write(sod_bytes)

    return sod_hex

def get_dg_chunk_size(dg1_hex, ec_hex):
    dg1_256 = str.upper(sha256_hash_from_hex(dg1_hex))
    dg1_160 = str.upper(sha1_hash_from_hex(dg1_hex))
    dg1_384 = str.upper(sha384_hash_from_hex(dg1_hex))
    if dg1_256 in ec_hex:
        return 256, 512
    if dg1_160 in ec_hex:
        return 160, 512
    if dg1_384 in ec_hex:
        return 384, 1024
    return 0, 0

def get_aa_sig_algo(dg15_hex):
    if "7d5a0975fc2c3057eef67530417affe7fb8055c126dc5c6ce94a4b44f330b5d9" in dg15_hex:
        return 21
    if "ffffffff00000001000000000000000000000000fffffffffffffffffffffff" in dg15_hex:
        return 20
    if "3ee30b568fbab0f883ccebd46d3f3bb8a2a73513f5eb79da66190eb085ffa9f492f375a97d860eb4" in dg15_hex:
        return 22
    if "fffffffffffffffffffffffffffffffefffffffffffffffc" in dg15_hex:
        return 23
    return 1

def get_sig_algo(sod_hex, salt, signature, hash_algo):
    if "7d5a0975fc2c3057eef67530417affe7fb8055c126dc5c6ce94a4b44f330b5d9" in sod_hex:
        return 7
    if "ffffffff00000001000000000000000000000000fffffffffffffffffffffff" in sod_hex:
        return 6
    if "fffffffffffffffffffffffffffffffefffffffffffffffffffffffe" in sod_hex:
        return 24
    if salt !=0:
        if len(signature) == 384:
            return 4
        if len(signature) == 512:
            return 3 if hash_algo == 256 else 5
        return 4
    if (len(signature) == 512):
        return 1
    return 2

def get_ecdsa_params(sod_hex, pubkey_ecdsa_location, signature):
    pubkey = sod_hex[2*(pubkey_ecdsa_location + 4): 2*pubkey_ecdsa_location + 136]
    pubkey_bit = hex_to_bin(pubkey)
    pubkey_arr = format_bit_string(pubkey_bit)

    chunk_num = 4

    signature = signature[-132:]

    sig = signature[0:64] + signature[68:132]
    
    sig_bit = hex_to_bin(sig)
    signature_arr = format_bit_string(sig_bit) 

    pk_hash = hash_pk_ecdsa(pubkey_bit)

    return pubkey_arr, signature_arr, chunk_num, pk_hash

def get_ecdsa_params_224(sod_hex, pubkey_ecdsa_location, signature):
    pubkey = sod_hex[2*(pubkey_ecdsa_location + 4): 2*pubkey_ecdsa_location + 120]
    pubkey_bit = hex_to_bin(pubkey)
    pubkey_arr = format_bit_string(pubkey_bit)


    chunk_num = 7

    signature = signature[-116:]

    sig = signature[0:56] + signature[60:116]
    sig_bit = hex_to_bin(sig)
    signature_arr = format_bit_string(sig_bit) 

    pk_hash = hash_pk_ecdsa(pubkey_bit)
    
    return pubkey_arr, signature_arr, chunk_num, pk_hash


def get_rsa_2048_rsa_pss_params(sod_hex, rsa_pubkey_location, rsa_pubkey_len, signature):

    signature_arr = bigint_to_array(64, 32, int(signature, 16))
    chunk_num = 32

    pubkey = sod_hex[rsa_pubkey_location * 2 -1: rsa_pubkey_location *2 + rsa_pubkey_len*2 + 2].split("82010100")[1][0:512]
    pubkey_arr = bigint_to_array(64, chunk_num, int(pubkey, 16))

    e_bits =  2 if (rsa_pubkey_len == 269) else 17

    pk_hash =  hash_pk_rsa(chunk_num, pubkey) 

    return pubkey_arr, signature_arr, chunk_num, e_bits, pk_hash


def get_rsa_3072_rsa_pss_params(sod_hex, rsa_pubkey_location, rsa_pubkey_len, signature):

    signature_arr = bigint_to_array(64, 48, int(signature, 16))
    chunk_num = 48
    print(sod_hex)
    pubkey = sod_hex[rsa_pubkey_location * 2 -1: rsa_pubkey_location *2 + rsa_pubkey_len*2 + 2].split("82018100")[1][0:768]
    print(pubkey)
    pubkey_arr = bigint_to_array(64, chunk_num, int(pubkey, 16))

    e_bits =  17

    pk_hash =  hash_pk_rsa(chunk_num, pubkey) 

    return pubkey_arr, signature_arr, chunk_num, e_bits, pk_hash

def get_rsa_4096_params(sod_hex, rsa_pubkey_location, rsa_pubkey_len, signature):

    signature_arr = bigint_to_array(64, 64, int(signature, 16))
    chunk_num = 64

    pubkey = sod_hex[rsa_pubkey_location * 2 -1:rsa_pubkey_location * 2 -1 + 1200].split("82020100")[1][0:1024]
    pubkey_arr = bigint_to_array(64, chunk_num, int(pubkey, 16))

    e_bits =  17 if (rsa_pubkey_len == 527) else 2

    pk_hash =  hash_pk_rsa(chunk_num, pubkey) 

    return pubkey_arr, signature_arr, chunk_num, e_bits, pk_hash

def get_shifts(dg1_hex, dg15_hex, ec_hex, dg_hash_algo, hash_algo, sa_hex):
    if (dg15_hex == "0"):
        dg15_hex = "01"
    dg1_hash = ""
    dg15_hash = ""
    ec_hash = ""
    print(dg_hash_algo)
    print(hash_algo)
    dg1_shift = 0
    dg15_shift = dg_hash_algo
    ec_shift = 0

    if dg_hash_algo == 160:
        dg1_hash = sha1_hash_from_hex(dg1_hex)
        dg15_hash = sha1_hash_from_hex(dg15_hex)

    
    if dg_hash_algo == 256:
        dg1_hash = sha256_hash_from_hex(dg1_hex)
        dg15_hash = sha256_hash_from_hex(dg15_hex)
    
    if dg_hash_algo == 384:
        dg1_hash = sha384_hash_from_hex(dg1_hex)
        dg15_hash = sha384_hash_from_hex(dg15_hex)

    ec_hash = sha256_hash_from_hex(ec_hex)
    if hash_algo == 160:
        ec_hash = sha1_hash_from_hex(ec_hex)
    if hash_algo == 256:
        ec_hash = sha256_hash_from_hex(ec_hex)
    if hash_algo == 384:
        ec_hash = sha384_hash_from_hex(ec_hex)

    dg1_shift = len(str.upper(ec_hex).split(str.upper(dg1_hash))[0])*4
    
    if dg15_hex != "01":
        dg15_shift = len(str.upper(ec_hex).split(str.upper(dg15_hash))[0])*4

    ec_shift = len(str.upper(sa_hex).split(str.upper(ec_hash))[0])*4

    return dg1_shift, dg15_shift, ec_shift    

def get_hash_matrix(dg15_blocks, ec_blocks):
    dg15_arr = []
    ec_arr = []

    for i in range(1, 9):
        dg15_arr.append(0 if i != dg15_blocks else 1)
        ec_arr.append(0 if i != ec_blocks else 1)

    return dg15_arr, ec_arr

def get_root_and_branches(pk_hash):

    root = poseidon([pk_hash, pk_hash, 1])
    branches = []
    for i in range(0, 80):
        branches.append(0)

    return root, branches

def get_sk_iden(ec_hex):
    return str(int(sha256_hash_from_hex(ec_hex)[:62], 16))

def get_short_file_path(file_path):
    return file_path.split(".json")[0].split("/")[-1]

def process_passport(file_path):
    sod_hex = get_ans1_data(file_path)
    asn1_data = parse_asn1('temp_asn1.der')

    hash_algo, chunk_size = process_algo(asn1_data)

    dg1_hex = process_dg1(file_path)
    dg15_hex, dg15_base64 = process_dg15(file_path)
    
    isdg15 = 0 if dg15_hex == "0" else 1

    ec_hex, ec_res, ec_blocks =  process_ec(asn1_data, chunk_size)

    tmp = 512 if hash_algo <= 256 else 1024
    ec_res = ec_res[0:ec_blocks*tmp]

    dg_hash_algo, dg_chunk_size = get_dg_chunk_size(dg1_hex, ec_hex)

    dg1_res = padd_dg1(dg1_hex, dg_chunk_size)
    dg15_blocks, dg15_res = padd_dg15(dg15_hex, dg_chunk_size)

    if dg15_blocks == 1:
        dg15_blocks = 0

    dg15_res = dg15_res[0:dg15_blocks*tmp]

    sa_locations = process_sa(asn1_data)
    sa_hex, sa_res = get_sa(sod_hex, sa_locations, chunk_size)
    

    signature = process_sign(asn1_data)

    salt = process_salt(asn1_data)

    sig_algo = get_sig_algo(sod_hex, salt, signature, hash_algo)

    pubkey_ecdsa_location, rsa_pubkey_location, rsa_pubkey_len = process_pubkey(asn1_data)
    pubkey_arr = []
    signature_arr = []
    chunk_number = 0
    e_bits = 0

    if sig_algo == 6 or sig_algo == 7:
        pubkey_arr, signature_arr, chunk_number, pk_hash = get_ecdsa_params(sod_hex, pubkey_ecdsa_location, signature)
    
    if  sig_algo == 24:
        pubkey_arr, signature_arr, chunk_number, pk_hash = get_ecdsa_params_224(sod_hex, pubkey_ecdsa_location, signature)

    if sig_algo == 2:
        pubkey_arr, signature_arr, chunk_number, e_bits, pk_hash = get_rsa_4096_params(sod_hex, rsa_pubkey_location, rsa_pubkey_len, signature)
    
    if sig_algo == 4:
        pubkey_arr, signature_arr, chunk_number, e_bits, pk_hash = get_rsa_3072_rsa_pss_params(sod_hex, rsa_pubkey_location, rsa_pubkey_len, signature)

    if sig_algo == 1 or sig_algo == 3 or sig_algo == 5:
        pubkey_arr, signature_arr, chunk_number, e_bits, pk_hash = get_rsa_2048_rsa_pss_params(sod_hex, rsa_pubkey_location, rsa_pubkey_len, signature)
   
    dg1_shift, dg15_shift, ec_shift = get_shifts(dg1_hex, dg15_hex, ec_hex, dg_hash_algo, hash_algo, sa_hex)

    dg15_arr, ec_arr = get_hash_matrix(dg15_blocks, ec_blocks)

    root, branches = get_root_and_branches(pk_hash)

    document_type = 3 if len(dg1_hex) == 186 else 1

    sk_iden = get_sk_iden(ec_hex)

    short_file_path = get_short_file_path(file_path)

    sig_algo = get_new_sig_type(sig_algo, salt, e_bits)

    if isdg15 == 0:
        dg15_shift = 0

    if isdg15 !=0:
        isdg15 = get_aa_sig_algo(dg15_hex)

    AA_shift = 0 
    AA_pubkey = ""
    if isdg15!=0:
        (AA_shift, AA_pubkey) = get_AA_shift_and_pubkey(dg15_hex, isdg15, dg15_base64)
    print(AA_shift)
    print(AA_pubkey)

    real_circuit_name = ""
    if isdg15 == 0:
        real_circuit_name = "registerIdentity_"+ str(sig_algo) + "_" + str(dg_hash_algo) + "_" + str(document_type) + "_" + str(ec_blocks) + "_" + str(ec_shift) + "_" + str(dg1_shift) + "_" + "NA"
    else:
        real_circuit_name = "registerIdentity_"+ str(sig_algo) + "_" + str(dg_hash_algo) + "_" + str(document_type) + "_" + str(ec_blocks) + "_" + str(ec_shift) + "_" + str(dg1_shift) + "_" + str(isdg15) + "_" + str(dg15_shift) + "_" + str(dg15_blocks) + "_" + str(AA_shift)




    write_tmp_to_file(real_circuit_name)

    write_results_to_register_identity(sig_algo, dg_hash_algo, document_type, dg1_shift, dg15_shift, ec_shift, dg15_blocks, ec_blocks, isdg15, AA_shift, real_circuit_name)

    write_results_to_passport_verification(sig_algo, dg_hash_algo, dg1_shift, dg15_shift, ec_shift, dg15_blocks, ec_blocks, isdg15, AA_shift, real_circuit_name)

    write_to_json(dg1_res, dg15_res, sa_res, ec_res, pubkey_arr, signature_arr, sk_iden, root, branches, real_circuit_name)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Decode a base64 encoded passport file.')
    parser.add_argument('passport_file_path', type=str, help='Path to the passport.json file')

    args = parser.parse_args()
    process_passport(args.passport_file_path)