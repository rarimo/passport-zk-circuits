import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-toolbox";
import "tsconfig-paths/register";

import "@solarity/hardhat-zkit";
import "@solarity/chai-zkit";

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
    circuitsDir: "test/circuits/",
    compilationSettings: {
      c: true,
      onlyFiles: ["queryIdentity.circom", "registerIdentity_1_256_3_4_600_248_1_1496_3_256.circom","registerIdentity_1_256_3_5_576_248_NA.circom","registerIdentity_1_256_3_6_576_248_1_2432_5_296.circom"],
      skipFiles: []
    },
    setupSettings: {
      ptauDir: "zkit/ptau",
      onlyFiles: ["queryIdentity.circom", "registerIdentity_1_256_3_4_600_248_1_1496_3_256.circom","registerIdentity_1_256_3_5_576_248_NA.circom","registerIdentity_1_256_3_6_576_248_1_2432_5_296.circom"],
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
