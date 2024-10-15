// import { zkit } from "hardhat"; 
// import { expect } from "chai"; 
// import { QueryIdentity } from "@zkit"; 
// import fs from "fs";
// import path from "path";

// describe("QueryIdentity Circuit Test", function () {
//   let circuit: QueryIdentity;
//   let input: any;
  
//   // Before hook to initialize circuit and load input data
//   before(async function () {
//     circuit = await zkit.getCircuit("QueryIdentity");

//     const testJson = path.join(__dirname, `./inputQuery.json`);
//     const data = await fs.promises.readFile(testJson, 'utf8');
//     input = JSON.parse(data);
//   });

//   it("should generate a valid witness and proof for QueryIdentity circuit", async function () {
//     const witness = {
//       dg1: input.dg1,
//       eventID: input.eventID,
//       idStateRoot: input.idStateRoot,
//       idStateSiblings: input.idStateSiblings,
//       pkPassportHash: input.pkPassportHash,
//       selector: input.selector,
//       skIdentity: input.skIdentity,
//       timestamp: input.timestamp,
//       currentDate: input.currentDate,
//       identityCounter: input.identityCounter,
//       timestampLowerbound: input.timestampLowerbound,
//       timestampUpperbound: input.timestampUpperbound,
//       identityCounterLowerbound: input.identityCounterLowerbound,
//       identityCounterUpperbound: input.identityCounterUpperbound,
//       birthDateUpperbound: input.birthDateUpperbound,
//       expirationDateLowerbound: input.expirationDateLowerbound,
//       expirationDateUpperbound: input.expirationDateUpperbound,
//       citizenshipMask: input.citizenshipMask,
//       eventData: input.eventData,
//       birthDateLowerbound: input.birthDateLowerbound
//     };

//     await expect(circuit).to.have.witnessInputs(witness);

//     const proof = await circuit.generateProof(witness);

//     await expect(circuit).to.verifyProof(proof);
//   });
// });
