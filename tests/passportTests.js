const chai = require("chai");
const path = require("path");
const wasm_tester = require("./tester");

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

const validInput = require('./inputs/validInput.json')
const isNotAdultInput = require('./inputs/isNotAdultInput.json')
const passportExpiredInput = require('./inputs/passportExpiredInput.json')
const credValidExceedsPassportInput = require('./inputs/credValidExceedsPassportInput.json')

describe("Simple test", function () {
    this.timeout(100000);

    it("SHA256 circuit witness generation on a valid data", async function () {

        const circuit = await wasm_tester(
            path.join(__dirname, "../passportVerification/passportVerificationSHA256.circom")
        );
        const w = await circuit.calculateWitness(validInput);
        await circuit.checkConstraints(w);
    });

    it("SHA256 circuit witness generation failed: is not Adult", async function () {

        const circuit = await wasm_tester(
            path.join(__dirname, "../passportVerification/passportVerificationSHA256.circom")
        );
        try {
            const w = await circuit.calculateWitness(isNotAdultInput);
            await circuit.checkConstraints(w);
            assert.fail('Is not adult constraint checks failed. Witness generation seccessful')
        } catch(e){
            // Everything is OK, could not generate witness because user is under age lowerbound;
        }
    });

    it("SHA256 circuit witness generation failed: passport has expired", async function () {

        const circuit = await wasm_tester(
            path.join(__dirname, "../passportVerification/passportVerificationSHA256.circom")
        );
        try {
            const w = await circuit.calculateWitness(passportExpiredInput);
            await circuit.checkConstraints(w);
            assert.fail('Is not adult constraint checks failed. Witness generation seccessful')
        } catch(e){
            // Everything is OK, could not generate witness because passport has expired;
        }
    });

    it("SHA256 circuit witness generation failed: credential validity period exceeds passport", async function () {

        const circuit = await wasm_tester(
            path.join(__dirname, "../passportVerification/passportVerificationSHA256.circom")
        );
        try {
            const w = await circuit.calculateWitness(credValidExceedsPassportInput);
            await circuit.checkConstraints(w);
            assert.fail('Is not adult constraint checks failed. Witness generation seccessful')
        } catch(e){
            // Everything is OK, could not generate witness because credential validity period exceeds passport;
        }
    });
});
