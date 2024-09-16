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

describe("File generation test", function () {
    this.timeout(10000000);

    const filename = "tests/tests/inputs/passport/masarate.json";

    before(function(done) {
        exec(`python3 tests/tests/generate_files.py ${filename}`, (error, stdout, stderr) => {
          if (error) {
            console.error(`Error executing script: ${error.message}`);
            return done(error);
          }
          if (stderr) {
            console.error(`Script stderr: ${stderr}`);
            return done(new Error(stderr));
          }
          done(); 
        });
      });


	it("Verification test", async function () {

        let short_fileneme = filename.split("/")[filename.split("/").length - 1].split(".json")[0];

		const testJson = path.join(__dirname, `./inputs/generated/input_${short_fileneme}.dev.json`);
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, `../../circuits/passportVerification/main_${short_fileneme}.circom`)
			);
			const w = await circuit.calculateWitness({ 
                dg1: input.dg1,
                dg15: input.dg15,
                encapsulatedContent: input.encapsulatedContent,
                signedAttributes: input.signedAttributes,
                signature: input.signature,
                pubkey: input.pubkey
            });
			await circuit.checkConstraints(w);
	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}
	});

  
});
