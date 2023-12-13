#!/bin/bash
set -e 

SETUP_POWERS=$1
BUILD_DIR=powers.dev

# Define the build directory where intermediate files will be stored
if [ -d . ]; then
    BUILD_DIR="./$BUILD_DIR"
elif [ -d .. ]; then
    BUILD_DIR="../$BUILD_DIR"
else
    echo "Error: can't find way to circuits folder: unknow directory."
    exit 1
fi

mkdir -p $BUILD_DIR/$SETUP_POWERS

# Generatin trusted setup as powers/SETUP_POWERS.ptau
echo -e "\Generating trustep setup..."

snarkjs powersoftau new bn128 ${SETUP_POWERS} ${BUILD_DIR}/${SETUP_POWERS}/pot${SETUP_POWERS}_0000.ptau 
echo `xxd -l 128 -p /dev/urandom` | snarkjs powersoftau contribute ${BUILD_DIR}/${SETUP_POWERS}/pot${SETUP_POWERS}_0000.ptau ${BUILD_DIR}/${SETUP_POWERS}/pot${SETUP_POWERS}_0001.ptau --name="Someone" -v

snarkjs powersoftau prepare phase2 ${BUILD_DIR}/${SETUP_POWERS}/pot${SETUP_POWERS}_0001.ptau ${BUILD_DIR}/${SETUP_POWERS}.ptau -v

# Removing redudant files
rm -rf $BUILD_DIR/$SETUP_POWERS

echo -e "\nTrusted setup generated $BUILD_DIR/$SETUP_POWERS.ptau"
