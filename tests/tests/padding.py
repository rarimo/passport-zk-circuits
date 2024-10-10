from utils import hex_to_bin

def pad_binary(binary_str, chunk_size):
    original_length = len(binary_str)
    binary_str += '1'
    
    while (len(binary_str) + 64) % chunk_size != 0:
        binary_str += '0'

    length_bin = bin(original_length)[2:].zfill(64)
    binary_str += length_bin
    return binary_str

def process_and_pad_hex(hex_str, chunk_size):
    binary_str = hex_to_bin(hex_str)
    padded_binary_str = pad_binary(binary_str, chunk_size)
    num_blocks = len(padded_binary_str) // chunk_size
    return binary_str, padded_binary_str, num_blocks

def pad_array_to_4096(array):
    if len(array) > 4096:
        raise ValueError("Input array length exceeds 4096 elements.")
    
    return array + [0] * (4096 - len(array))

def pad_array_to_8192(array):
    if len(array) > 8192:
        raise ValueError("Input array length exceeds 4096 elements.")
    
    return array + [0] * (8192 - len(array))

