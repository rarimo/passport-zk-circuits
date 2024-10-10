// import { zkit } from "hardhat"; // hardhat-zkit plugin
// import { expect } from "chai"; // chai-zkit extension
// import { QueryIdentity } from "@zkit"; // zktype circuit-object
// import fs from "fs";
// import path from "path";


// async function main() {
//     const circuit: QueryIdentity = await zkit.getCircuit("QueryIdentity");

//     const testJson = path.join(__dirname, `./inputQuery.json`);
//     const data = await fs.promises.readFile(testJson, 'utf8');
//     const input = JSON.parse(data);
//     console.log(input);
//     // witness testing
//     await expect(circuit)
//     .with.witnessInputs({
//         dg1: input.dg1,
//         eventID: input.eventID,
//         idStateRoot: input.idStateRoot,
//         idStateSiblings: input.idStateSiblings,
//         pkPassportHash: input.pkPassportHash,
//         selector: input.selector,
//         skIdentity: input.skIdentity,
//         timestamp: input.timestamp,
//         currentDate: input.currentDate,
//         identityCounter: input.identityCounter,
//         timestampLowerbound: input.timestampLowerbound,
//         timestampUpperbound: input.timestampUpperbound,
//         identityCounterLowerbound: input.identityCounterLowerbound,
//         identityCounterUpperbound: input.identityCounterUpperbound,
//         birthDateUpperbound: input.birthDateUpperbound,
//         expirationDateLowerbound: input.expirationDateLowerbound,
//         expirationDateUpperbound: input.expirationDateUpperbound,
//         citizenshipMask: input.citizenshipMask,
//         eventData: input.eventData,
//         birthDateLowerbound: input.birthDateLowerbound
//     });


// }

// main()
//   .then()
//   .catch((e) => console.log(e));