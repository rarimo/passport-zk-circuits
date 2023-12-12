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

# Generate the witness.wtns
node build/${CIRCUIT}_js/generate_witness.js build/${CIRCUIT}_js/${CIRCUIT}.wasm input.json build/${CIRCUIT}_js/witness.wtns