import base64

def base64_to_hex(base64_str):
    return base64.b64decode(base64_str).hex()

def hex_to_bin(hex_str):
    return bin(int(hex_str, 16))[2:].zfill(len(hex_str) * 4)

def bigint_to_array(n, k, x):
    mod = 1
    for idx in range(n):
        mod *= 2

    ret = []
    x_temp = x
    for _ in range(k):
        ret.append(str(x_temp % mod))
        x_temp //= mod  

    return ret

def format_bit_string(bit_string):
    bit_array = [int(bit) for bit in bit_string]

    return bit_array

