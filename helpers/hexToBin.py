hex_input = 0x3

bin_input = bin(hex_input)

string = str(bin_input)[2:]

print(string)

with open('output.txt', 'w') as file:
    file.write('{"in" : [')
    for item in string:
        file.write(item + ",")
    file.write("]}")
