#!/bin/bash
set -e 

CIRCUIT_NAME=$1
INPUT_FILE=$2
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

if [ ! -e "$INPUT_FILE" ]; then
    echo "Error: can't find the input file '$INPUT_FILE'"
    exit 1
fi

echo -e "\nGenerating witness..."

node ${BUILD_DIR}/${CIRCUIT_NAME}_js/generate_witness.js ${BUILD_DIR}/${CIRCUIT_NAME}.wasm ${INPUT_FILE} ${BUILD_DIR}/witness.wtns
