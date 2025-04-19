signature = 0x2
modulus   = 0xc
exponent  = 0x010001

def bigint_to_array(n, k, x):
    # Initialize mod to 1 (Python's int can handle arbitrarily large numbers)
    mod = 1
    for idx in range(n):
        mod *= 2

    # Initialize the return list
    ret = []
    x_temp = x
    for idx in range(k):
        # Append x_temp mod to the list
        ret.append(str(x_temp % mod))
        # Divide x_temp by mod for the next iteration
        x_temp //= mod  # Use integer division in Python

    return ret

print(bigint_to_array(64, 64, signature))
print(bigint_to_array(64, 64, modulus))
print(bigint_to_array(64, 64, exponent))
