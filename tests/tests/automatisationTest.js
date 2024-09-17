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

function generateFilesForAll(filenames, done) {
    let pending = filenames.length;
    filenames.forEach((filename) => {
        console.log("executing for", filename);
        exec(`python3 tests/tests/generate_files.py ${filename}`, (error, stdout, stderr) => {
            if (error) {
                console.error(`Error executing script: ${error.message}`);
                return done(error);
            }
            if (stderr) {
                console.error(`Script stderr: ${stderr}`);
                return done(new Error(stderr));
            }
            if (--pending === 0) done(); // Call done only after all files are processed
        });
    });
}

describe("File generation test", function () {
    this.timeout(10000000);

    const passportDir = path.join(__dirname, './inputs/passport');

    // Read all filenames from the passport directory
    const filenames = fs.readdirSync(passportDir).filter(file => file.endsWith('.json'));
   
    before(function(done) {
        generateFilesForAll(filenames.map(file => path.join(passportDir, file)), done);
    });

    filenames.forEach(filename => {
        // it("Verification passport test", async function () {

        //     let short_fileneme = filename.split("/")[filename.split("/").length - 1].split(".json")[0];

        //     const testJson = path.join(__dirname, `./inputs/generated/input_${short_fileneme}.dev.json`);
        
        //     try {
        //         const data = await fs.promises.readFile(testJson, 'utf8');
        //         const input = JSON.parse(data);
        
        //         const circuit = await wasm_tester(
        //             path.join(__dirname, `./circuits/passportVerification/main_${short_fileneme}.circom`)
        //         );
        //         const w = await circuit.calculateWitness({ 
        //             dg1: input.dg1,
        //             dg15: input.dg15,
        //             encapsulatedContent: input.encapsulatedContent,
        //             signedAttributes: input.signedAttributes,
        //             signature: input.signature,
        //             pubkey: input.pubkey
        //         });
        //         await circuit.checkConstraints(w);
        
        //     } catch (err) {
        //         console.error('Error:', err);
        //         throw err;  
        //     }
        // });

        it("Register identity test", async function () {

            let short_fileneme = filename.split("/")[filename.split("/").length - 1].split(".json")[0];

            const testJson = path.join(__dirname, `./inputs/generated/input_${short_fileneme}_2.dev.json`);
        
            try {
                const data = await fs.promises.readFile(testJson, 'utf8');
                const input = JSON.parse(data);
        
                const circuit = await wasm_tester(
                    path.join(__dirname, `./circuits/identityManagement/main_${short_fileneme}.circom`)
                );
                const w = await circuit.calculateWitness({ 
                    dg1: input.dg1,
                    dg15: input.dg15,
                    encapsulatedContent: input.encapsulatedContent,
                    signedAttributes: input.signedAttributes,
                    signature: input.signature,
                    pubkey: input.pubkey,
                    skIdentity: input.skIdentity,
                    slaveMerkleInclusionBranches: input.slaveMerkleInclusionBranches,
                    slaveMerkleRoot: input.slaveMerkleRoot
                });
                await circuit.checkConstraints(w);
        
            } catch (err) {
                console.error('Error:', err);
                throw err;  
            }
        });
    });

});
