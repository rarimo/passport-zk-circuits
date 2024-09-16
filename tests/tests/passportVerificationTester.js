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

describe("Passport verification test", function () {
    this.timeout(10000000);

	it("Australia test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_australia.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_australia.circom")
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

	it("Britain test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_britain.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_britain.circom")
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

	it("China test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_china.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_china.circom")
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
	
    it("Denmark test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_denmark.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_denmark.circom")
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

    it("Japan test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_japan.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_japan.circom")
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

    it("Philipine test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_philipine.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_philipine.circom")
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

    it("Spain test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_spain.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_spain.circom")
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

    it("Ukraine test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_ukr.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_ukr.circom")
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


	it("Australia corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_australia_corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_australia.circom")
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

	it("Britain corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_britain_corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_britain.circom")
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

	it("China corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_china_corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_china.circom")
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
	
    it("Denmark corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_denmark_corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_denmark.circom")
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

    it("Japan corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_japan_corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_japan.circom")
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

    it("Philipine corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_philipine_corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_philipine.circom")
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

    it("Spain corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_spain_corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_spain.circom")
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

    it("Ukraine corrupted test", async function () {
		const testJson = path.join(__dirname, './inputs/passport_verification/input_ukr_corrupted.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "../../circuits/passportVerification/main_ukr.circom")
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
