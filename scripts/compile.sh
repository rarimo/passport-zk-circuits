#!/bin/bash

# Variable to store the name of the circuit
CIRCUIT=default

# In case there is a circuit name as input
if [ "$1" ]; then
    CIRCUIT=$1
fi

# Delete the build folder, if it exists
rm -r -f build

# Create the build folder
mkdir -p build

# Compile the circuit
circom ${CIRCUIT}.circom --r1cs --wasm --sym --c -o build