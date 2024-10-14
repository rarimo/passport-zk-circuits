#!/bin/bash

# Execute the first command and wait for it to complete
node ./helpers/generateRegisterIdentityTest.js
if [ $? -ne 0 ]; then
    echo "Error executing generateRegisterIdentityTest.js"
    exit 1
fi

# Execute the second command and wait for it to complete
npx hardhat zkit compile
if [ $? -ne 0 ]; then
    echo "Error during hardhat zkit compile"
    exit 1
fi

# Execute the third command and wait for it to complete
npx hardhat zkit make
if [ $? -ne 0 ]; then
    echo "Error during hardhat zkit make"
    exit 1
fi

# Execute the final command
npx hardhat test
if [ $? -ne 0 ]; then
    echo "Error during npm run test"
    exit 1
fi

echo "All commands executed successfully."
