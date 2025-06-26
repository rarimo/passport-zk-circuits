const chai = require("chai");
const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const fs = require('fs');
const processPassport = require("./process_passport").processPassport;

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;


describe("File generation test", function () {
    this.timeout(10000000);

    const passportDir = path.join(__dirname, './inputs/passport');

    // Read all filenames from the passport directory
    const filenames = fs.readdirSync(passportDir).filter(file => file.endsWith('.json'));


    filenames.forEach(filename => {

        it("Register identity test", async function () {

            let name = await processPassport("test/inputs/passport/" + filename);

            console.log("Executing " + name + ".circom");
            const testJson = path.join(__dirname, `/inputs/generated/${name}.json`);
        
            try {
                const data = await fs.promises.readFile(testJson, 'utf8');
                const input = JSON.parse(data);
        
                const circuit = await wasm_tester(
                    path.join(__dirname, `./circuits/generated/${name}.circom`)
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
