import json
import base64
import subprocess
import re
import hashlib
import os
import python_poseidon
from smt.tree import SparseMerkleTree
from smt.utils import DEFAULTVALUE, PLACEHOLDER, digest
from smt.proof import verify_proof
import argparse



def hash_dg15_rsa(pk):

    
    rsa_arr = [int(pk[:50], 16), int(pk[50:100], 16), int(pk[100:150], 16), int(pk[150:200], 16), int(pk[200:256], 16)]
    
    tmp =  python_poseidon.poseidon(rsa_arr)
    print(tmp)
    return tmp

def hash_dg15_ecdsa(pk):

    ecdsa_arr = [int(pk[8:256], 16), int(pk[256+8:512], 16)]
    tmp = python_poseidon.poseidon(ecdsa_arr)
    print(tmp)
    return tmp

def proof(pk):

    hex_string = hex(pk)[2:]  

    if len(hex_string) % 2 != 0:
        hex_string = '0' + hex_string

    hex_bytes = bytes.fromhex(hex_string)   
    tree = SparseMerkleTree()
    tree.update(b"a", hex_bytes)

    root = tree.root_as_hex()

    path = digest(b"a")
    side_nodes, old_leafhash, old_leafdata, sibdata = tree._get_sidenodes(
            path, root, False
        )
    
    print(old_leafhash)



    return root

def bigint_to_array(n, k, x):
    # Initialize mod to 1 (Python's int can handle arbitrarily large numbers)
    mod = 1
    for idx in range(n):
        mod *= 2

    # Initialize the return list
    ret = []
    x_temp = x
    for idx in range(k):
        # Append x_temp mod mod to the list
        ret.append(str(x_temp % mod))
        # Divide x_temp by mod for the next iteration
        x_temp //= mod  # Use integer division in Python

    return ret

def format_bit_string(bit_string):
    bit_array = [int(bit) for bit in bit_string]

    return bit_array

def sha256_hash_from_hex(hex_str):
    # Step 1: Convert hex string to bytes
    byte_data = bytes.fromhex(hex_str)
    
    # Step 2: Compute SHA-256 hash
    sha256_hash = hashlib.sha256(byte_data).hexdigest()
    
    return sha256_hash

def sha1_hash_from_hex(hex_str):
    # Step 1: Convert hex string to bytes
    byte_data = bytes.fromhex(hex_str)
    
    # Step 2: Compute SHA-1 hash
    sha1_hash = hashlib.sha1(byte_data).hexdigest()
    
    return sha1_hash

def base64_to_hex(base64_str):
    return base64.b64decode(base64_str).hex()

def hex_to_bin(hex_str):
    return bin(int(hex_str, 16))[2:].zfill(len(hex_str) * 4)

# Pad binary string to a given chunk size
def pad_binary(binary_str, chunk_size):
    original_length = len(binary_str)
    binary_str += '1'
    
    while (len(binary_str) + 64) % chunk_size != 0:
        binary_str += '0'

    length_bin = bin(original_length)[2:].zfill(64)
    binary_str += length_bin
    return binary_str

# Process and pad hex string
def process_and_pad_hex(hex_str, chunk_size):
    binary_str = hex_to_bin(hex_str)
    padded_binary_str = pad_binary(binary_str, chunk_size)
    num_blocks = len(padded_binary_str) // chunk_size
    return binary_str, padded_binary_str, num_blocks

# Pad array to length of 4096 for dg15
def pad_array_to_4096(array):
    if len(array) > 4096:
        raise ValueError("Input array length exceeds 4096 elements.")
    
    return array + [0] * (4096 - len(array))

# Main function to process passport data
def dg_interactions(passport_file, chunk_size):
    with open(passport_file, 'r') as f:
        passport_data = json.load(f)

    dg1_base64 = passport_data.get('dg1', '')
    dg15_base64 = passport_data.get('dg15', '')
    dg15_hex = "0"

    dg15_pk_hash = 0
    # Convert base64 to hex
    dg1_hex = base64_to_hex(dg1_base64)
    if dg15_base64:
        dg15_hex = base64_to_hex(dg15_base64)

        if len (dg15_hex) == 630:
            dg15_pk_hash = hash_dg15_ecdsa(dg15_hex[-512:])
        else:
            dg15_pk_hash = hash_dg15_rsa(dg15_hex[64:320])

    
    # Process both dg1 and dg15
    _, dg1_padded, _ = process_and_pad_hex(dg1_hex, chunk_size)
    _, dg15_padded, dg15_blocks = process_and_pad_hex(dg15_hex, chunk_size)

    # Pad dg15 to a length of 4096 after the initial padding
    dg15_padded_to_4096 = pad_array_to_4096([bit for bit in dg15_padded])
    
    return dg15_blocks, [bit for bit in dg1_padded], dg15_padded_to_4096, dg15_pk_hash

# Function to parse ASN.1 data using OpenSSL
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

# Function to extract ASN.1 components
def extract_asn1_components(asn1_data):
    # Print the parsed ASN.1 data
    # print("Parsed ASN.1 Data:\n", asn1_data)
    
    # Example patterns to extract different components
    # Adjust these patterns based on your ASN.1 structure


    octet_strings_pattern = re.compile(r'OCTET STRING.*')

    lines = asn1_data.split('\n')
    salt = 0

    if ("INTEGER" in lines[-3]):
        #type = rsapss
        salt = int(lines[-3].split(":")[-1], 16)
        # print(salt)
    
    # Filter lines that contain "cont [ 0 ]"
    cont_lines = [line for line in lines if 'cont [ 0 ]' in line]

    pubkey_ecdsa_lines = [line for line in lines if 'l=  66' in line]
    
    pubkey_ecdsa_location = 0

    rsa_pubkey_location = 0

    rsa_pubkey_locations = [line for line in lines if 'BIT STRING' in line]

    rsa_pubkey_len = int([s for s in rsa_pubkey_locations[0].split(" l=")[1].split(" ") if s][0])

    rsa_pubkey_location = int([s for s in rsa_pubkey_locations[0].split(":")[0].split(" ") if s][0])


    # print(pubkey_ecdsa_lines)

    for line in pubkey_ecdsa_lines:
        if "BIT STRING" in line:
            filtered_list = [s for s in line.split(":")[0].split(" ") if s]
            pubkey_ecdsa_location = int(filtered_list[0])


    sa_locations = []
    for line in cont_lines:
        # print(line)
        filtered_list = [s for s in line.split("l=")[2].split(" ") if s]
        sa_locations.append([int(line.split(":")[0]), int(filtered_list[0]) + 2])

    octet_strings = octet_strings_pattern.findall(asn1_data)

    ec = ""
    sign = ""
    if octet_strings:
        ec = str(octet_strings[0]).split(":")[1] #ec
        sign = str(octet_strings[-1]).split(":")[1]#sig


    return (sa_locations, ec, sign, pubkey_ecdsa_location, salt, rsa_pubkey_location, rsa_pubkey_len)


# Function to decode base64 and print decoded data
def decode_base64_and_print(file_path):
    # Read JSON file
    with open(file_path, 'r') as file:
        data = json.load(file)
    
    # Extract 'sod' field
    sod_base64 = data.get('sod', '')
    
    # Decode base64
    try:
        sod_bytes = base64.b64decode(sod_base64)
        # print("Decoded SOD Data (bytes):", sod_bytes)
        
        # Save decoded data to a temporary file for ASN.1 parsing
        with open('temp_asn1.der', 'wb') as file:
            file.write(sod_bytes)
        
        # Run OpenSSL asn1parse command to parse ASN.1 data
        asn1_data = parse_asn1('temp_asn1.der')
        
        # Extract ASN.1 components from the parsed data
        (sa_locations, ec, sign, pubkey_ecdsa_location, salt, rsa_pubkey_location, rsa_pubkey_len) = extract_asn1_components(asn1_data)


        ec_len = len(ec)*4

        hex_sod = base64.b64decode(sod_base64).hex()

        pubkey = ""


        sa = "31"
        for [n, l] in sa_locations:
            # print(hex_sod[n*2:n*2+3])
            if (hex_sod[n*2] == "a" and hex_sod[n*2+1] == "0" and (hex_sod[n*2 + 2] == "6" or hex_sod[n*2 + 2] == "4")):
                sa += hex_sod[n*2+2:n*2+l*2]
        # print(sa)
        sig_algo = 0
        e_bits = 0
        sod_hex = base64.b64decode(sod_base64).hex()
        # print(sod_hex)

        chunk_num = 0

        pubkey_arr = ""
        signature_arr = ""

        tmp = 0

        #Brainpool
        if "7d5a0975fc2c3057eef67530417affe7fb8055c126dc5c6ce94a4b44f330b5d9" in sod_hex: #brainpool a constant
            sig_algo = 7 
            tmp = 1

            pubkey = hex_sod[2*(pubkey_ecdsa_location + 4): 2*pubkey_ecdsa_location + 136]
            pubkey_bit = hex_to_bin(pubkey)
            pubkey_arr = format_bit_string(pubkey_bit)

            chunk_num = 4

            sign = sign[-132:]
            sig = sign.split("0220")[0] + sign.split("0220")[1]
            sig_bit = hex_to_bin(sig)
            signature_arr = format_bit_string(sig_bit) 

        #P256
        if str.lower("FFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFF") in sod_hex: #P256 a constant
            sig_algo = 6 
            tmp = 1
            chunk_num = 4

            pubkey = hex_sod[2*(pubkey_ecdsa_location + 4): 2*pubkey_ecdsa_location + 136]
            pubkey_bit = hex_to_bin(pubkey)
            pubkey_arr = format_bit_string(pubkey_bit)

            sign = sign[-132:]
            sig = sign.split("0220")[0] + sign.split("0220")[1]
            sig_bit = hex_to_bin(sig)
            signature_arr = format_bit_string(sig_bit) 

        #RsaPss
        if salt != 0:

            # print(len(sign))
            #RsaPss 2048
            if len(sign) == 512:
                sig_algo = 3
                signature_arr = bigint_to_array(64, 32, int(sign, 16))

                chunk_num = 32

                pubkey = hex_sod[rsa_pubkey_location * 2 -1: rsa_pubkey_location *2 + rsa_pubkey_len*2 + 2].split("82010100")[1][0:512]

                pubkey_arr = bigint_to_array(64, chunk_num, int(pubkey, 16))

                e_bits =  2 if (rsa_pubkey_len == 269) else 17

        if (salt == 0 and tmp == 0):
            #Rsa
            # print(sign)
            #Rsa 2048
            if (len(sign) == 512):
                sig_algo = 1
                chunk_num = 32
                signature_arr = bigint_to_array(64, 32, int(sign, 16))
                pubkey = hex_sod[rsa_pubkey_location * 2 -1: rsa_pubkey_location *2 + rsa_pubkey_len*2 + 2].split("82010100")[1][0:512]
                pubkey_arr = bigint_to_array(64, chunk_num, int(pubkey, 16))
                e_bits =  2 if (rsa_pubkey_len == 269) else 17

            
            #Rsa4096
            else: 
                chunk_size = 64
                sig_algo = 2
                chunk_num = 64
                signature_arr = bigint_to_array(64, 64, int(sign, 16))
                pubkey = hex_sod[rsa_pubkey_location * 2 -1:rsa_pubkey_location * 2 -1 + 1200].split("82020100")[1][0:1024]
                pubkey_arr = bigint_to_array(64, chunk_num, int(pubkey, 16))
                e_bits =  17 if (rsa_pubkey_len == 527) else 2

        chunk_size = 512

        dg15_blocks, dg1_res, dg15_res, dg15_pk_hash = dg_interactions(file_path, chunk_size)

        _, ec_padded, ec_blocks = process_and_pad_hex(ec, chunk_size)
        ec_res = pad_array_to_4096([bit for bit in ec_padded])


        _, sa_padded, _ = process_and_pad_hex(sa, chunk_size)
        sa_res = pad_array_to_4096([bit for bit in sa_padded])


        dg1 = base64_to_hex(data.get('dg1', ''))
        dg1_256 = str.upper(sha256_hash_from_hex(dg1))
        dg1_160 = str.upper(sha1_hash_from_hex(dg1))

        dg1shift = 0

        if dg1_256 in ec:
            dg1shift = len(ec.split(dg1_256)[0])*4
        
        if dg1_160 in ec:
            dg1shift = len(ec.split(dg1_160)[0])*4

       
        dg15 = base64_to_hex(data.get('dg15', ''))
        

        dg_hash_algo = 256
        if dg1_160 in ec:
            dg_hash_algo = 160

        isdg15 = 0

        dg15shift = dg_hash_algo
        ec_shift = len(sa)*4 - 256


        if dg15:
            dg15shift = ec_len - dg_hash_algo
            isdg15 = 1

        dg15_arr = []
        ec_arr = []
        sa_arr = []


        for i in range(1, 9):
            dg15_arr.append(0 if i != dg15_blocks else 1)
            ec_arr.append(0 if i != ec_blocks else 1)
            sa_arr.append(0 if i !=2 else 1)

        

        short_file_path = file_path.split(".json")[0].split("/")[-1]

        print(short_file_path)
        short_file_path2 = short_file_path+"2"
        padded_output_file = "./tests/tests/inputs/generated/input_{short_file_path}.dev.json".format(short_file_path = short_file_path)
       
        with open(padded_output_file, 'w') as f_out:
            json.dump({
                "dg1": dg1_res,
                "dg15": dg15_res,
                "signedAttributes": sa_res,
                "encapsulatedContent": ec_res,
                "pubkey": pubkey_arr,
                "signature": signature_arr
            }, f_out, indent=4)

        root = proof(dg15_pk_hash)
        padded_output_file2 = "input_{short_file_path2}.dev.json".format(short_file_path2 = short_file_path2)
        
        sk_iden = int(sha256_hash_from_hex(ec)[:62], 16)

        # with open(padded_output_file2, 'w') as f_out:
        #     json.dump({
        #         "dg1": dg1_res,
        #         "dg15": dg15_res,
        #         "signedAttributes": sa_res,
        #         "encapsulatedContent": ec_res,
        #         "pubkey": pubkey_arr,
        #         "signature": signature_arr,
        #         "skIdentity": sk_iden,
        #         "slaveMerkleRoot": ,
        #         "slaveMerkleInclusionBranches": 

        #     }, f_out, indent=4)


        document_type = 1
        if (len(dg1) == 190):
            document_type = 3
        

        circom_code = ""
        circom_code += "pragma circom 2.1.6;\n\n"
        circom_code += "include  \"./circuits/registerIdentityBuilder.circom\";\n\n"
        circom_code += "component main = RegisterIdentityBuilder(\n\t\t2,\n\t\t8,\n\t\t8,\n\t\t8,\n"
        circom_code += "\t\t{chunk_size},\n".format(chunk_size = chunk_size)
        circom_code += "\t\t256,\t//hash type\n"
        circom_code += "\t\t{sig_algo},\n".format(sig_algo = sig_algo)
        circom_code += "\t\t{salt},\n".format(salt = salt)
        circom_code += "\t\t{e_bits},\n".format(e_bits = e_bits)
        circom_code += "\t\t64,\n"
        circom_code += "\t\t{chunk_num},\n".format(chunk_num = chunk_num)
        circom_code += "\t\t{dg_hash_algo},\n".format(dg_hash_algo = dg_hash_algo)
        circom_code += "\t\t{document_type},\n".format(document_type = document_type)
        circom_code += "\t\t80,\n"
        circom_code += "\t\t[[{dg1shift}, {dg15shift}, {ec_shift}, {dg15_blocks}, {ec_blocks}, {isdg15}]],\n".format(
            dg1shift = dg1shift,
            dg15shift = dg15shift,
            ec_shift = ec_shift,
            dg15_blocks = dg15_blocks,
            ec_blocks = ec_blocks,
            isdg15 = isdg15
        )
        circom_code += "\t\t1,\n"
        circom_code += "\t\t[\n\t\t\t{dg15_arr},\n\t\t\t{ec_arr},\n\t\t\t{sa_arr}\n\t\t]\n".format(
            dg15_arr = dg15_arr,
            ec_arr = ec_arr,
            sa_arr = sa_arr
        )
        circom_code += ");" 


        with open('./circuits/identityManagement/main_{short_file_path}.circom'.format(short_file_path = short_file_path), 'w') as file:
            file.write(circom_code)

        circom_code = "pragma circom 2.1.6;\n\n"
        circom_code += "include \"./passportVerificationBuilder.circom\";"
        circom_code += "component main = PassportVerificationBuilder(\n\t\t2,\n\t\t8,\n\t\t8,\n\t\t8,\n"
        circom_code += "\t\t{chunk_size},\n".format(chunk_size = chunk_size)
        circom_code += "\t\t256,\t//hash type\n"
        circom_code += "\t\t{sig_algo},\n".format(sig_algo = sig_algo)
        circom_code += "\t\t{salt},\n".format(salt = salt)
        circom_code += "\t\t{e_bits},\n".format(e_bits = e_bits)
        circom_code += "\t\t64,\n"
        circom_code += "\t\t{chunk_num},\n".format(chunk_num = chunk_num)
        circom_code += "\t\t{dg_hash_algo},\n".format(dg_hash_algo = dg_hash_algo)
        circom_code += "\t\t80,\n"
        circom_code += "\t\t[[{dg1shift}, {dg15shift}, {ec_shift}, {dg15_blocks}, {ec_blocks}, {isdg15}]],\n".format(
            dg1shift = dg1shift,
            dg15shift = dg15shift,
            ec_shift = ec_shift,
            dg15_blocks = dg15_blocks,
            ec_blocks = ec_blocks,
            isdg15 = isdg15
        )
        circom_code += "\t\t1,\n"
        circom_code += "\t\t[\n\t\t\t{dg15_arr},\n\t\t\t{ec_arr},\n\t\t\t{sa_arr}\n\t\t]\n".format(
            dg15_arr = dg15_arr,
            ec_arr = ec_arr,
            sa_arr = sa_arr
        )
        circom_code += ");" 
        with open('./circuits/passportVerification/main_{short_file_path}.circom'.format(short_file_path = short_file_path), 'w') as file:
            file.write(circom_code)


    except Exception as e:
        print("Error decoding base64 data:", e)
        

# Main script execution
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Decode a base64 encoded passport file.')
    parser.add_argument('passport_file_path', type=str, help='Path to the passport.json file')

    # Parse the arguments
    args = parser.parse_args()
    print("Current working directory (./):", os.getcwd())

    # Use the provided file path
    decode_base64_and_print(args.passport_file_path)