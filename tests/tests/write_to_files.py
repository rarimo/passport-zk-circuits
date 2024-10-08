import json


def write_results_to_register_identity(sig_algo, dg_hash_algo, document_type, dg1shift, dg15shift, ec_shift, dg15_blocks, ec_blocks, isdg15, AA_shift, short_file_path):
    
    circom_code = ""
    circom_code += "pragma circom 2.1.6;\n\n"
    circom_code += "include  \"../../../../circuits/identityManagement/circuits/registerIdentityBuilder.circom\";\n\n"
    circom_code += "component main = RegisterIdentityBuilder(\n"
    circom_code += "\t\t{sig_algo},\t//sig_algo\n".format(sig_algo = sig_algo)
    circom_code += "\t\t{dg_hash_algo},\t//dg hash algo\n".format(dg_hash_algo = dg_hash_algo)
    circom_code += "\t\t{document_type},\t//document type\n".format(document_type = document_type)
    circom_code += "\t\t{ec_blocks},\t//encapsulated content len in blocks\n".format(ec_blocks = ec_blocks) 
    circom_code += "\t\t{ec_shift},\t///encapsulated content  shift in bits\n".format(ec_shift = ec_shift) 
    circom_code += "\t\t{dg1shift},\t//dg1 shift in bits\n".format(dg1shift = dg1shift) 
    circom_code += "\t\t{isdg15},\t//dg15 sig algo (0 if not present)\n".format(isdg15 = isdg15) 
    circom_code += "\t\t{dg15shift},\t//dg15 shift in bits\n".format(dg15shift = dg15shift) 
    circom_code += "\t\t{dg15_blocks},\t//dg15 blocks\n".format(dg15_blocks = dg15_blocks)     
    circom_code += "\t\t{AA_shift}\t//AA shift in bits\n".format(AA_shift = AA_shift) 
    circom_code += ");" 


    with open('./tests/tests/circuits/identityManagement/main_{short_file_path}.circom'.format(short_file_path = short_file_path), 'w') as file:
        file.write(circom_code)

def write_results_to_passport_verification(sig_algo, dg_hash_algo, dg1shift, dg15shift, ec_shift, dg15_blocks, ec_blocks, isdg15, AA_shift, short_file_path):
    circom_code = "pragma circom 2.1.6;\n\n"
    circom_code += "include \"../../../../circuits/passportVerification/passportVerificationBuilder.circom\";\n\n"
    circom_code += "component main = PassportVerificationBuilder(\n\t\t8,\t //dg15 chunk number\n\t\t8,\t//encapsulated content chunk number\n"
    circom_code += "\t\t{sig_algo},\t//sig_algo\n".format(sig_algo = sig_algo)
    circom_code += "\t\t{dg_hash_algo},\t//dg hash algo\n".format(dg_hash_algo = dg_hash_algo)
    circom_code += "\t\t{ec_blocks},\t//encapsulated content len in blocks\n".format(ec_blocks = ec_blocks) 
    circom_code += "\t\t{ec_shift},\t///encapsulated content  shift in bits\n".format(ec_shift = ec_shift) 
    circom_code += "\t\t{dg1shift},\t//dg1 shift in bits\n".format(dg1shift = dg1shift) 
    circom_code += "\t\t{isdg15},\t//dg15 sig algo (0 if not present)\n".format(isdg15 = isdg15) 
    circom_code += "\t\t{dg15shift},\t//dg15 shift in bits\n".format(dg15shift = dg15shift) 
    circom_code += "\t\t{dg15_blocks},\t//dg15 blocks\n".format(dg15_blocks = dg15_blocks)     
    circom_code += "\t\t{AA_shift}\t//AA shift in bits\n".format(AA_shift = AA_shift) 
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

def write_tmp_to_file(real_name):
    with open('./tests/tests/inputs/tmp.txt', 'w') as file:
        file.write(real_name)