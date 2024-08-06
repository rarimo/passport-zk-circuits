#!/bin/bash
set -e 

CIRCUIT_NAME=$1
BUILD_DIR="$CIRCUIT_NAME.dev"

# Define the build directory where intermediate files will be stored
if [ -d ./$BUILD_DIR ]; then
    BUILD_DIR="./$BUILD_DIR"
elif [ -d ../$BUILD_DIR ]; then
    BUILD_DIR="../$BUILD_DIR"
else
    echo "Error: can't find way to build folder '$BUILD_DIR': unknow directory."
    exit 1
fi

# Verifying proof
echo -e "\nVerifying..."

snarkjs groth16 verify ${BUILD_DIR}/verification_key.json ${BUILD_DIR}/public.json ${BUILD_DIR}/proof.json

echo -e "Verified ${BUILD_DIR}/proof.json"
