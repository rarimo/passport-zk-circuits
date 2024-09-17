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

describe("Hasher test", function () {
    this.timeout(100000);

	const hexStr = "ffff";

	it("SHA-1 160 Hash test", async function () {
		const testJson = path.join(__dirname, './inputs/hasher/hasher512.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/hasher/sha1-1.circom")
			);
			const w = await circuit.calculateWitness({ in: input.in });
			await circuit.checkConstraints(w);

			
			let hash = w.slice(1, 1+160).join(""); // bit str representation of calculated hash

			const buffer = Buffer.from(hexStr, 'hex');

			const hashBuffer = crypto.createHash('sha1')
				.update(buffer)
				.digest('hex');

			let hash2 = hashBuffer.split('').map(hexChar => {
				return parseInt(hexChar, 16).toString(2).padStart(4, '0');
			}).join('');							//bit representation of real hash

			assert.equal(hash, hash2);
	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}
	});

	it("SHA-1 224 Hash test", async function () {
		const testJson = path.join(__dirname, './inputs/hasher/hasher512.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/hasher/sha224-1.circom")
			);
			const w = await circuit.calculateWitness({ in: input.in },true);
			await circuit.checkConstraints(w);


			let hash = w.slice(1, 1+224).join(""); // bit str representation of calculated hash

			const buffer = Buffer.from(hexStr, 'hex');

			const hashBuffer = crypto.createHash('sha224')
				.update(buffer)
				.digest('hex');

			let hash2 = hashBuffer.split('').map(hexChar => {
				return parseInt(hexChar, 16).toString(2).padStart(4, '0');
			}).join('');							//bit representation of real hash

			assert.equal(hash, hash2);

			
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}
	});

	it("SHA-1 256 Hash test", async function () {
		const testJson = path.join(__dirname, './inputs/hasher/hasher512.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/hasher/sha256-1.circom")
			);
			const w = await circuit.calculateWitness({ in: input.in });
			await circuit.checkConstraints(w);

			let hash = w.slice(1, 1+256).join(""); // bit str representation of calculated hash

			const buffer = Buffer.from(hexStr, 'hex');

			const hashBuffer = crypto.createHash('sha256')
				.update(buffer)
				.digest('hex');

			let hash2 = hashBuffer.split('').map(hexChar => {
				return parseInt(hexChar, 16).toString(2).padStart(4, '0');
			}).join('');							//bit representation of real hash

			assert.equal(hash, hash2);

	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}
	});

	it("SHA-1 384 Hash test", async function () {
		const testJson = path.join(__dirname, './inputs/hasher/hasher1024.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/hasher/sha384-1.circom")
			);
			const w = await circuit.calculateWitness({ in: input.in });
			await circuit.checkConstraints(w);


			let hash = w.slice(1, 1+384).join(""); // bit str representation of calculated hash

			const buffer = Buffer.from(hexStr, 'hex');

			const hashBuffer = crypto.createHash('sha384')
				.update(buffer)
				.digest('hex');

			let hash2 = hashBuffer.split('').map(hexChar => {
				return parseInt(hexChar, 16).toString(2).padStart(4, '0');
			}).join('');							//bit representation of real hash

			assert.equal(hash, hash2);
	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}
	});

	it("SHA-1 512 Hash test", async function () {
		const testJson = path.join(__dirname, './inputs/hasher/hasher1024.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/hasher/sha512-1.circom")
			);
			const w = await circuit.calculateWitness({ in: input.in });
			await circuit.checkConstraints(w);


			let hash = w.slice(1, 1+512).join(""); // bit str representation of calculated hash

			const buffer = Buffer.from(hexStr, 'hex');

			const hashBuffer = crypto.createHash('sha512')
				.update(buffer)
				.digest('hex');

			let hash2 = hashBuffer.split('').map(hexChar => {
				return parseInt(hexChar, 16).toString(2).padStart(4, '0');
			}).join('');							//bit representation of real hash

			assert.equal(hash, hash2);
	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}
	});
	
});
