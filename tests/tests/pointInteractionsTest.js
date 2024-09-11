// const chai = require("chai");
// const path = require("path");
// const wasm_tester = require("../index").wasm;
// const c_tester = require("../index").c;

// const fs = require('fs');

// const F1Field = require("ffjavascript").F1Field;
// const Scalar = require("ffjavascript").Scalar;
// exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
// const Fr = new F1Field(exports.p);

// const assert = chai.assert;

// describe("Point interactions test", function () {
//     this.timeout(100000);

// 	it("Add unequal test", async function () {
// 		const testJson = path.join(__dirname, './inputs/hasher512.json');
	
// 		try {
// 			const data = await fs.promises.readFile(testJson, 'utf8');
// 			const input = JSON.parse(data);
	
// 			const circuit = await wasm_tester(
// 				path.join(__dirname, "../../circuits/hasher/sha1-1.circom")
// 			);
// 			const w = await circuit.calculateWitness({ in: input.in });
// 			await circuit.checkConstraints(w);
	
// 		} catch (err) {
// 			console.error('Error:', err);
// 			throw err;  
// 		}
// 	});

// 	it("Double point", async function () {
// 		const testJson = path.join(__dirname, './inputs/hasher512.json');
	
// 		try {
// 			const data = await fs.promises.readFile(testJson, 'utf8');
// 			const input = JSON.parse(data);
	
// 			const circuit = await wasm_tester(
// 				path.join(__dirname, "../../circuits/hasher/sha224-1.circom")
// 			);
// 			const w = await circuit.calculateWitness({ in: input.in });
// 			await circuit.checkConstraints(w);
	
// 		} catch (err) {
// 			console.error('Error:', err);
// 			throw err;  
// 		}
// 	});

// 	it("Scalar multiplication test", async function () {
// 		const testJson = path.join(__dirname, './inputs/hasher512.json');
	
// 		try {
// 			const data = await fs.promises.readFile(testJson, 'utf8');
// 			const input = JSON.parse(data);
	
// 			const circuit = await wasm_tester(
// 				path.join(__dirname, "../../circuits/hasher/sha256-1.circom")
// 			);
// 			const w = await circuit.calculateWitness({ in: input.in });
// 			await circuit.checkConstraints(w);
	
// 		} catch (err) {
// 			console.error('Error:', err);
// 			throw err;  
// 		}
// 	});

// 	it("Scalar multiplication test(pipinger)", async function () {
// 		const testJson = path.join(__dirname, './inputs/hasher1024.json');
	
// 		try {
// 			const data = await fs.promises.readFile(testJson, 'utf8');
// 			const input = JSON.parse(data);
	
// 			const circuit = await wasm_tester(
// 				path.join(__dirname, "../../circuits/hasher/sha384-1.circom")
// 			);
// 			const w = await circuit.calculateWitness({ in: input.in });
// 			await circuit.checkConstraints(w);
	
// 		} catch (err) {
// 			console.error('Error:', err);
// 			throw err;  
// 		}
// 	});

	
// });
