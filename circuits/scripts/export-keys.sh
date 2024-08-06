#!/bin/bash
set -e 

CIRCUIT_NAME=$1
SETUP_POWERS=$2
POWERS_FILE=""
BUILD_DIR=""

# Define the build directory where intermediate files will be stored
if [ -d . ]; then
    BUILD_DIR="./$CIRCUIT_NAME.dev"
    POWERS_FILE=../powers.dev/$SETUP_POWERS.ptau
elif [ -d .. ]; then
    BUILD_DIR="../$CIRCUIT_NAME.dev"
    POWERS_FILE=../powers.dev/$SETUP_POWERS.ptau
else
    echo "Error: can't find way to circuits folder: unknow directory."
    exit 1
fi

rm -rf ${BUILD_DIR}/zkey
mkdir -p ${BUILD_DIR}/zkey

# Exporting key with verification_key.json, verifier.sol and circtuis_final.zkey as a result
echo -e "\nExporting keys..."

snarkjs groth16 setup ${BUILD_DIR}/${CIRCUIT_NAME}.r1cs ${POWERS_FILE} ${BUILD_DIR}/${CIRCUIT_NAME}_0000.zkey -v
echo `xxd -l 128 -p /dev/urandom` | snarkjs zkey contribute ${BUILD_DIR}/${CIRCUIT_NAME}_0000.zkey ${BUILD_DIR}/circuit_final.zkey --name="Someone" -v

snarkjs zkey export verificationkey ${BUILD_DIR}/circuit_final.zkey ${BUILD_DIR}/verification_key.json
snarkjs zkey export solidityverifier ${BUILD_DIR}/circuit_final.zkey ${BUILD_DIR}/verifier.sol

# Removing redudant files
rm -rf ${BUILD_DIR}/zkey ${BUILD_DIR}/${CIRCUIT_NAME}_0000.zkey

echo -e "\nKeys exported $BUILD_DIR/circuit_final.zkey, $BUILD_DIR/verification_key.json, $BUILD_DIR/verifier.sol"