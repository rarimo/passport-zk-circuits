const chai = require("chai");
const path = require("path");
const wasm_tester = require("../index").wasm;
const c_tester = require("../index").c;
const crypto = require('crypto');



const fs = require('fs');

const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);

const assert = chai.assert;

describe("RSAPSS test", function () {
    this.timeout(100000);

	it("RsaPss s32 e2 test", async function () {
		const testJson = path.join(__dirname, './inputs/rsaPss/rsaPssS32e2.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/rsaPSS/VerifyRsaSigs32e2.circom")
			);
			const w = await circuit.calculateWitness({ 
                pubkey: input.pubkey,
                signature: input.signature,
                hashed: input.hashed
            });
			await circuit.checkConstraints(w);
	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}
	});

    it("RsaPss s32 e17 test", async function () {
		const testJson = path.join(__dirname, './inputs/rsaPss/rsaPssS32e17.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/rsaPSS/VerifyRsaSigs32e17.circom")
			);
			const w = await circuit.calculateWitness({ 
                pubkey: input.pubkey,
                signature: input.signature,
                hashed: input.hashed
             });
			await circuit.checkConstraints(w);
	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}
	});

    it("RsaPss s64 e17 test", async function () {
		const testJson = path.join(__dirname, './inputs/rsaPss/rsaPssS64e17.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/rsaPSS/VerifyRsaSigs64e17.circom")
			);
			const w = await circuit.calculateWitness({ 
                pubkey: input.pubkey,
                signature: input.signature,
                hashed: input.hashed
             });
			await circuit.checkConstraints(w);
	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}
	});

    it("RsaPss s32 e2 corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/rsaPss/rsaPssS32e2corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/rsaPSS/VerifyRsaSigs32e2.circom")
			);
			const w = await circuit.calculateWitness({ 
                pubkey: input.pubkey,
                signature: input.signature,
                hashed: input.hashed
            });
			await circuit.checkConstraints(w);
	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}
	});

    it("RsaPss s32 e17 corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/rsaPss/rsaPssS32e17corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/rsaPSS/VerifyRsaSigs32e17.circom")
			);
			const w = await circuit.calculateWitness({ 
                pubkey: input.pubkey,
                signature: input.signature,
                hashed: input.hashed
             });
			await circuit.checkConstraints(w);
	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}
	});

    it("RsaPss s64 e17 corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/rsaPss/rsaPssS64e17corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/rsaPSS/VerifyRsaSigs64e17.circom")
			);
			const w = await circuit.calculateWitness({ 
                pubkey: input.pubkey,
                signature: input.signature,
                hashed: input.hashed
             });
			await circuit.checkConstraints(w);
	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}
	});


	
});
