const chai = require("chai");
const path = require("path");
const wasm_tester = require("../index").wasm;
const c_tester = require("../index").c;

const fs = require('fs');

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

describe("Register identity test", function () {
    this.timeout(100000);

	it("Ukraine test", async function () {
		const testJson = path.join(__dirname, './inputs/register_identity/input_ukr.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/identityManagement/main_ukr.circom")
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

    it("Denmark test", async function () {
		const testJson = path.join(__dirname, './inputs/register_identity/input_denmark.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/identityManagement/main_denmark.circom")
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

    it("Ukraine corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/register_identity/input_ukr_corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/identityManagement/main_ukr.circom")
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

    it("Denmark corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/register_identity/input_denmark_corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/identityManagement/main_denmark.circom")
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
