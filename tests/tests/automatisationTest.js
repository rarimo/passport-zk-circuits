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

let files = [];
function generateFilesForAll(filenames, done) {
    let index = 0;

    const tmpfilePath = path.join(__dirname, `./inputs/tmp.txt`);
    fs.writeFile(tmpfilePath, '', (err) => {
        if (err) {
          console.error('Error emptying file:', err);
        } else {
          console.log('File emptied successfully');
        }
      });

    function executeNext() {
        if (index >= filenames.length) {
            return done(); // All files have been processed
        }

        const filename = filenames[index];
        console.log("Executing for", filename);

        exec(`python3 tests/tests/process_passport.py ${filename}`, (error, stdout, stderr) => {
            if (error) {
                console.error(`Error executing script: ${error.message}`);
                return done(error);
            }
            if (stderr) {
                console.error(`Script stderr: ${stderr}`);
                return done(new Error(stderr));
            }
            const tmp_txt = path.join(__dirname, `./inputs/tmp.txt`);
            const short_fileneme = fs.promises.readFile(tmp_txt, 'utf8');
            files.push(short_fileneme);
            index++;
            setTimeout(executeNext, 2000); // 2-second delay before processing the next file
        });
    }

    executeNext(); // Start the execution chain
}

describe("File generation test", function () {
    this.timeout(10000000);

    const passportDir = path.join(__dirname, './inputs/passport');

    // Read all filenames from the passport directory
    const filenames = fs.readdirSync(passportDir).filter(file => file.endsWith('.json'));
   
    before(function(done) {
        generateFilesForAll(filenames.map(file => path.join(passportDir, file)), done);
    });

    let counter = 0;
    filenames.forEach(filename => {
        // it("Verification passport test", async function () {

        //     const tmp_txt = path.join(__dirname, `./inputs/tmp.txt`);
        //     const short_fileneme = await fs.promises.readFile(tmp_txt, 'utf8');

        //     const testJson = path.join(__dirname, `./inputs/generated/input_${short_fileneme}.dev.json`);
        
        //     try {
        //         const data = await fs.promises.readFile(testJson, 'utf8');
        //         const input = JSON.parse(data);
        
        //         const circuit = await wasm_tester(
        //             path.join(__dirname, `./circuits/passportVerification/main_${"passportVerification"+short_fileneme.split("registerIdentity"[1])}.circom`)
        //         );
        //         const w = await circuit.calculateWitness({ 
        //             dg1: input.dg1,
        //             dg15: input.dg15,
        //             encapsulatedContent: input.encapsulatedContent,
        //             signedAttributes: input.signedAttributes,
        //             signature: input.signature,
        //             pubkey: input.pubkey,
        //             slaveMerkleInclusionBranches: input.slaveMerkleInclusionBranches,
        //             slaveMerkleRoot: input.slaveMerkleRoot
        //         });
        //         await circuit.checkConstraints(w);
        
        //     } catch (err) {
        //         console.error('Error:', err);
        //         throw err;  
        //     }
        // });

        it("Register identity test", async function () {

            const tmp_txt = path.join(__dirname, `./inputs/tmp.txt`);
            const short_filenemes = await fs.promises.readFile(tmp_txt, 'utf8');

            let short_fileneme = short_filenemes.split("\n")[counter];
            console.log("Executing " + short_fileneme + ".circom");
            const testJson = path.join(__dirname, `./inputs/generated/input_${short_fileneme}_2.dev.json`);
        
            try {
                const data = await fs.promises.readFile(testJson, 'utf8');
                const input = JSON.parse(data);
        
                const circuit = await wasm_tester(
                    path.join(__dirname, `./circuits/identityManagement/${short_fileneme}.circom`)
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
            counter+=1;
        });
    });

});
