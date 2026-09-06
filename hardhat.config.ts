import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-toolbox";
import "tsconfig-paths/register";

import "@solarity/hardhat-zkit";
import "@solarity/chai-zkit";

import { HardhatUserConfig } from "hardhat/config";

// 6 universal register-identity circuits, restored from 4468884^ with:
//   - PassportVerificationFlow signature repaired (6-param for RSA, 8-param for PSS)
//   - RSA/PSS exponent passed as a value (65537 / 3) instead of a bit count
//   - PSS SALT_LEN/EXP argument order and the pubkey port name fixed
//   - CSCA modulus leaf: full-key SHA256 (top 248 bits) instead of partial Poseidon(5)
const universalMains = [
  "registerIdentityUniversalRSA2048.circom",
  "registerIdentityUniversalRSA2048TD1.circom",
  "registerIdentityUniversalRSA4096.circom",
  "registerIdentityUniversalRSAPss2048s32e17.circom",
  "registerIdentityUniversalRSAPss2048s32e2.circom",
  "registerIdentityUniversalRSAPss2048s64e17.circom",
];

const config: HardhatUserConfig = {
  networks: {
    hardhat: {
      initialDate: "1970-01-01T00:00:00Z",
    },
  },
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      evmVersion: "paris",
    },
  },
  zkit: {
    circuitsDir: "circuits/identityManagement",
    compilationSettings: {
      c: true,
      onlyFiles: universalMains,
      skipFiles: []
    },
    setupSettings: {
      ptauDir: "zkit/ptau",
      onlyFiles: universalMains,
      skipFiles: []
    },
  },
  typechain: {
    outDir: "generated-types/ethers",
    target: "ethers-v6",
    alwaysGenerateOverloads: true,
    discriminateTypes: true,
  },
};

export default config;
