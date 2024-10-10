// file location: ./scripts/multiplier.test.ts

import { zkit } from "hardhat"; // hardhat-zkit plugin
import { expect } from "chai"; // chai-zkit extension
import { Multiplier } from "@zkit"; // zktype circuit-object

async function main() {
  const circuit: Multiplier = await zkit.getCircuit("Multiplier");
  // or await zkit.getCircuit("circuits/multiplier.circom:Multiplier");

  // witness testing
  await expect(circuit)
    .with.witnessInputs({ in1: "3", in2: "7" })
    .to.have.witnessOutputs({ out: "21" });

  // proof testing
  const proof = await circuit.generateProof({ in1: "4", in2: "2" });

  await expect(circuit).to.verifyProof(proof);
}

main()
  .then()
  .catch((e) => console.log(e));