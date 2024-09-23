import json


def write_results_to_register_identity(chunk_size, hash_algo, sig_algo, salt, e_bits, chunk_num, dg_hash_algo, document_type, dg1shift, dg15shift, ec_shift, dg15_blocks, ec_blocks, isdg15, dg15_arr, ec_arr, short_file_path):
    
    circom_code = ""
    circom_code += "pragma circom 2.1.6;\n\n"
    circom_code += "include  \"../../../../circuits/identityManagement/circuits/registerIdentityBuilder.circom\";\n\n"
    circom_code += "component main = RegisterIdentityBuilder(\n\t\t8,\t //dg15 chunk number\n\t\t8,\t//encapsulated content chunk number\n"
    circom_code += "\t\t{chunk_size},\t//hash chunk size\n".format(chunk_size = chunk_size)
    circom_code += "\t\t{hash_algo},\t//hash type\n".format(hash_algo = hash_algo)
    circom_code += "\t\t{sig_algo},\t//sig_algo\n".format(sig_algo = sig_algo)
    circom_code += "\t\t{salt},\t//salt\n".format(salt = salt)
    circom_code += "\t\t{e_bits},\t// e_bits\n".format(e_bits = e_bits)
    circom_code += "\t\t64,\t//chunk size\n"
    circom_code += "\t\t{chunk_num},\t//chunk_num\n".format(chunk_num = chunk_num)
    circom_code += "\t\t{},\t//dg hash size chunk size\n".format(512 if dg_hash_algo <= 256 else 1024)
    circom_code += "\t\t{dg_hash_algo},\t//dg hash algo\n".format(dg_hash_algo = dg_hash_algo)
    circom_code += "\t\t{document_type},\t//document type\n".format(document_type = document_type)
    circom_code += "\t\t80,\t//merkle tree depth\n"
    circom_code += "\t\t[[{dg1shift}, {dg15shift}, {ec_shift}, {dg15_blocks}, {ec_blocks}, {isdg15}]],\t//flow matrix\n".format(
        dg1shift = dg1shift,
        dg15shift = dg15shift,
        ec_shift = ec_shift,
        dg15_blocks = dg15_blocks,
        ec_blocks = ec_blocks,
        isdg15 = isdg15
    )
    circom_code += "\t\t1,\t//flow matrix height\n"
    circom_code += "\t\t[\n\t\t\t{dg15_arr},\n\t\t\t{ec_arr}\n\t\t]\t//hash block matrix\n".format(
        dg15_arr = dg15_arr,
        ec_arr = ec_arr,
        )
    circom_code += ");" 


    with open('./tests/tests/circuits/identityManagement/main_{short_file_path}.circom'.format(short_file_path = short_file_path), 'w') as file:
        file.write(circom_code)

def write_results_to_passport_verification(chunk_size, hash_algo, sig_algo, salt, e_bits, chunk_num, dg_hash_algo, dg1shift, dg15shift, ec_shift, dg15_blocks, ec_blocks, isdg15, dg15_arr, ec_arr, short_file_path):
    circom_code = "pragma circom 2.1.6;\n\n"
    circom_code += "include \"../../../../circuits/passportVerification/passportVerificationBuilder.circom\";\n\n"
    circom_code += "component main = PassportVerificationBuilder(\n\t\t8,\t //dg15 chunk number\n\t\t8,\t//encapsulated content chunk number\n"
    circom_code += "\t\t{chunk_size},\t//hash chunk size\n".format(chunk_size = chunk_size)
    circom_code += "\t\t{hash_algo},\t//hash type\n".format(hash_algo = hash_algo)
    circom_code += "\t\t{sig_algo},\t//sig_algo\n".format(sig_algo = sig_algo)
    circom_code += "\t\t{salt},\t//salt\n".format(salt = salt)
    circom_code += "\t\t{e_bits},\t// e_bits\n".format(e_bits = e_bits)
    circom_code += "\t\t64,\t//chunk size\n"
    circom_code += "\t\t{chunk_num},\t//chunk_num\n".format(chunk_num = chunk_num)
    circom_code += "\t\t{},\t//dg hash size chunk size\n".format(512 if dg_hash_algo <= 256 else 1024)
    circom_code += "\t\t{dg_hash_algo},\t//dg hash algo\n".format(dg_hash_algo = dg_hash_algo)
    circom_code += "\t\t80,\t//merkle tree depth\n"
    circom_code += "\t\t[[{dg1shift}, {dg15shift}, {ec_shift}, {dg15_blocks}, {ec_blocks}, {isdg15}]],\t//flow matrix\n".format(
        dg1shift = dg1shift,
        dg15shift = dg15shift,
        ec_shift = ec_shift,
        dg15_blocks = dg15_blocks,
        ec_blocks = ec_blocks,
        isdg15 = isdg15
    )
    circom_code += "\t\t1,\t//flow matrix height\n"
    circom_code += "\t\t[\n\t\t\t{dg15_arr},\n\t\t\t{ec_arr}\n\t\t]\t//hash block matrix\n".format(
        dg15_arr = dg15_arr,
        ec_arr = ec_arr,
    )
    circom_code += ");" 
    with open('./tests/tests/circuits/passportVerification/main_{short_file_path}.circom'.format(short_file_path = short_file_path), 'w') as file:
        file.write(circom_code)

def write_to_json(dg1_res, dg15_res, sa_res, ec_res, pubkey_arr, signature_arr, sk_iden, root, branches, short_file_path):
    padded_output_file = "./tests/tests/inputs/generated/input_{short_file_path}.dev.json".format(short_file_path = short_file_path)
       
    with open(padded_output_file, 'w') as f_out:
        json.dump({
            "dg1": dg1_res,
            "dg15": dg15_res,
            "signedAttributes": sa_res,
            "encapsulatedContent": ec_res,
            "pubkey": pubkey_arr,
            "signature": signature_arr,
            "slaveMerkleRoot": str(root),
            "slaveMerkleInclusionBranches": branches
        }, f_out, indent=4)

    padded_output_file2 = "./tests/tests/inputs/generated/input_{short_file_path}_2.dev.json".format(short_file_path = short_file_path)
    

    with open(padded_output_file2, 'w') as f_out:
        json.dump({
            "dg1": dg1_res,
            "dg15": dg15_res,
            "signedAttributes": sa_res,
            "encapsulatedContent": ec_res,
            "pubkey": pubkey_arr,
            "signature": signature_arr,
            "skIdentity": str(sk_iden),
            "slaveMerkleRoot": str(root),
            "slaveMerkleInclusionBranches": branches
        }, f_out, indent=4)
