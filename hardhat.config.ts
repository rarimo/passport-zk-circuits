import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-toolbox";
import "tsconfig-paths/register";

import "@solarity/hardhat-zkit";

import { HardhatUserConfig } from "hardhat/config";

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
    circuitsDir: "identityManagement",
    nativeCompiler: true,
    compilationSettings: {
      c: true,
      // onlyFiles: ["vote"]
      skipFiles: ["registerIdentity2688TMSP.circom", "registerIdentity2704.circom", "registerIdentityUniversal.circom",
    "registerIdentity2688.circom", "registerIdentityUniversalRSA2048.circom", "registerIdentityUniversalRSA2048TD1.circom",]
    },
    setupSettings: {
      ptauDir: "zkit/ptau",
      skipFiles: ["registerIdentity2688TMSP.circom", "registerIdentity2704.circom", "registerIdentityUniversal.circom",
    "registerIdentity2688.circom", "registerIdentityUniversalRSA2048.circom", "registerIdentityUniversalRSA2048TD1.circom",
    "registerIdentityUniversalRSA4096.circom"]
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
