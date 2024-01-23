#!/bin/bash
set -e 

CIRCUIT_NAME=$1
BUILD_DIR=""
CIRCUIT_FILE=""

# Define the build directory where intermediate files will be stored
if [ -d ./ ]; then
    BUILD_DIR="./$CIRCUIT_NAME.dev"
    CIRCUIT_FILE="./$CIRCUIT_NAME.circom"
elif [ -d ../ ]; then
    BUILD_DIR="../$CIRCUIT_NAME.dev"
    CIRCUIT_FILE="../$CIRCUIT_NAME.circom"
else
    echo "Error: can't find way to circuits folder: unknow directory."
    exit 1
fi

if [ -z "$CIRCUIT_NAME" ]; then
    echo "Error: CIRCUIT_NAME is empty."
    exit 1
elif [ ! -e "$CIRCUIT_FILE" ]; then
    echo "Error: circuit doesn't exist."
    exit 1
fi

rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}

# Compiling circuit with .r1cs and .wasm files as result
echo -e "\nCompiling the circuits..."

circom ${CIRCUIT_FILE} --r1cs --wasm --c --sym -o ${BUILD_DIR}

mv ${BUILD_DIR}/${CIRCUIT_NAME}_js/${CIRCUIT_NAME}.wasm ${BUILD_DIR}/${CIRCUIT_NAME}.wasm

# snarkjs r1cs print ${BUILD_DIR}/${CIRCUIT_NAME}.r1cs ${BUILD_DIR}/${CIRCUIT_NAME}.sym

echo -e "\nCircuit compiled ${BUILD_DIR}"
