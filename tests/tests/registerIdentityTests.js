// const chai = require("chai");
// const path = require("path");
// const wasm_tester = require("./tester");

// const F1Field = require("ffjavascript").F1Field;
// const Scalar = require("ffjavascript").Scalar;
// exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
// const Fr = new F1Field(exports.p);

// const assert = chai.assert;

// const rsa4096EcdsaParamsNoTS = require('./registerIdentityInputs/inputRSA4096_ecdsa_params_noTS.json')
// const rsa4096RsaNoParamsNoTS = require('./registerIdentityInputs/inputRSA4096_rsa_noParams_noTS.json')
// const rsa4096RsaNoParamsTS = require('./registerIdentityInputs/inputRSA4096_rsa_params_TS.json')
// const rsa2048RsaParamsTS = require("./registerIdentityInputs/inputRSA2048_rsa_params_TS.json")
// const rsa2048NoAANoParamsTS = require("./registerIdentityInputs/inputRSA2048_noAA_noParams_TS.json")
// // const invalidInputBirthLower19 = require('./queryIdentityInputs/inputQueryInvalid23073BirthLower19.json')

// describe("Register circuit test", function () {
//     this.timeout(100000);
//     it("Register circuit RSA4096: valid, case ECDSA, with PARAMS ANY NULL, no Timestamp", async function () {
//         const circuit = await wasm_tester(
//             path.join(__dirname, "../identityManagement/registerIdentityUniversalRSA4096.circom")
//         );
//         const w = await circuit.calculateWitness(rsa4096EcdsaParamsNoTS);
//         await circuit.checkConstraints(w);
//     });

//     it("Register circuit RSA4096: valid, case RSA, no PARAMS ANY NULL, no Timestamp", async function () {
//         const circuit = await wasm_tester(
//             path.join(__dirname, "../identityManagement/registerIdentityUniversalRSA4096.circom")
//         );
//         const w = await circuit.calculateWitness(rsa4096RsaNoParamsNoTS);
//         await circuit.checkConstraints(w);
//     });

//     it("Register circuit RSA4096: valid, case RSA, no PARAMS ANY NULL, with Timestamp", async function () {
//         const circuit = await wasm_tester(
//             path.join(__dirname, "../identityManagement/registerIdentityUniversalRSA4096.circom")
//         );
//         const w = await circuit.calculateWitness(rsa4096RsaNoParamsTS);
//         await circuit.checkConstraints(w);
//     });

//     it("Register circuit RSA2048: valid, case RSA, with PARAMS ANY NULL, with Timestamp", async function () {
//         const circuit = await wasm_tester(
//             path.join(__dirname, "../identityManagement/registerIdentityUniversalRSA2048.circom")
//         );
//         const w = await circuit.calculateWitness(rsa2048RsaParamsTS);
//         await circuit.checkConstraints(w);
//     });

//     it("Register circuit RSA2048: valid, case no AA, no PARAMS ANY NULL, with Timestamp", async function () {
//         const circuit = await wasm_tester(
//             path.join(__dirname, "../identityManagement/registerIdentityUniversalRSA2048.circom")
//         );
//         const w = await circuit.calculateWitness(rsa2048NoAANoParamsTS);
//         await circuit.checkConstraints(w);
//     });

// });
