const chai = require("chai");
const path = require("path");
const wasm_tester = require("./tester");

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

const validInput = require('./queryIdentityInputs/inputQueryValid23073.json')
const invalidInputBirthLower19 = require('./queryIdentityInputs/inputQueryInvalid23073BirthLower19.json')

describe("Simple test", function () {
    this.timeout(100000);

    it("Query circuit: valid, selector case: 0, 5, 9, 11, 12, 14 (0b101101000100001)", async function () {

        const circuit = await wasm_tester(
            path.join(__dirname, "../identityManagement/queryIdentity.circom")
        );
        const w = await circuit.calculateWitness(validInput);
        await circuit.checkConstraints(w);
    });

    it("Query circuit: invalid (birth date lowerbound), selector case: 0, 5, 9, 11, 12, 14 (0b101101000100001)", async function () {
        const circuit = await wasm_tester(
            path.join(__dirname, "../identityManagement/queryIdentity.circom")
        );
        try {
            const w = await circuit.calculateWitness(invalidInputBirthLower19);
            await circuit.checkConstraints(w);
            assert.fail('Birth date checks failed. Witness generation seccessful')
        } catch(e){
            // Everything is OK, could not generate witness because birth date lowerbound is less than birth date;
        }
    });

    it("Query circuit: invalid (birth date lowerbound), selector case: 0, 5, 9, 11, 12, 14 (0b101101000100001)", async function () {
        const circuit = await wasm_tester(
            path.join(__dirname, "../identityManagement/queryIdentity.circom")
        );
        try {
            const w = await circuit.calculateWitness(invalidInputBirthLower19);
            await circuit.checkConstraints(w);
            assert.fail('Birth date checks failed. Witness generation seccessful')
        } catch(e){
            // Everything is OK, could not generate witness because user is under age lowerbound;
        }
    });

    // it("SHA256 circuit witness generation failed: is not Adult", async function () {

    //     const circuit = await wasm_tester(
    //         path.join(__dirname, "../passportVerification/passportVerificationSHA256.circom")
    //     );
    //     try {
    //         const w = await circuit.calculateWitness(isNotAdultInput);
    //         await circuit.checkConstraints(w);
    //         assert.fail('Is not adult constraint checks failed. Witness generation seccessful')
    //     } catch(e){
    //         // Everything is OK, could not generate witness because user is under age lowerbound;
    //     }
    // });
});
