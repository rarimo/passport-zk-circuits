const chai = require("chai");
const path = require("path");
const wasm_tester = require("../index").wasm;
const c_tester = require("../index").c;
const { exec } = require('child_process');
const fs = require('fs');

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

params = [32, 10, "p256", 256, 256]

function generateFiles(params, done) {
    exec(`python3 tests/tests/autocurve.py ${params[0]} ${params[1]} ${params[2]} ${params[3]} ${params[4]}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error executing script: ${error.message}`);
            return done(error);
        }
        if (stderr) {
            console.error(`Script stderr: ${stderr}`);
            return done(new Error(stderr));
        }
    });

}

describe("File generation test", function () {
    this.timeout(10000000);

    before(function(done) {
        generateFiles(params, done);
    });


    it("Test", async function () {

        const testJson = path.join(__dirname, `./inputs/sigver/sig_test_${params[2]}.json`);
    
        try {
            const data = await fs.promises.readFile(testJson, 'utf8');
            const input = JSON.parse(data);
    
            const circuit = await wasm_tester(
                path.join(__dirname, `./circuits/testCurve/test_curve.circom`)
            );
            const w = await circuit.calculateWitness({ 
                signature: input.signature,
                pubkey: input.pubkey,
                hashed: input.hashed,
                
            });
            await circuit.checkConstraints(w);
    
        } catch (err) {
            console.error('Error:', err);
            throw err;  
        }
    });
});
