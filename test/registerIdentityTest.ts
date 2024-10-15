import { zkit } from "hardhat";
import { expect } from "chai";
import fs from "fs";
import path from "path";
import { Poseidon, babyJub } from "@iden3/js-crypto";
import { Core } from "@zkit";

function bigintToUint8Array(bigIntValue: bigint): Uint8Array {
	const hexString = bigIntValue.toString(16);
	const paddedHexString = hexString.length % 2 === 0 ? hexString : '0' + hexString;
	const byteArray = new Uint8Array(paddedHexString.length / 2);
	for (let i = 0; i < byteArray.length; i++) {
		byteArray[i] = parseInt(paddedHexString.substr(i * 2, 2), 16);
	}
	if (byteArray.length < 32) {
		const paddedArray = new Uint8Array(32);
		paddedArray.set(byteArray, 32 - byteArray.length);
		return paddedArray;
	}
	return byteArray;
}


describe("Register Identity Circuit Tests", function () {
	let circuit0: Core.RegisterIdentity_1_256_3_4_600_248_1_1496_3_256Circom.RegisterIdentityBuilder;
	let input0: any;
	let circuit1: Core.RegisterIdentity_1_256_3_5_576_248_NACircom.RegisterIdentityBuilder;
	let input1: any;
	let circuit2: Core.RegisterIdentity_1_256_3_6_576_248_1_2432_5_296Circom.RegisterIdentityBuilder;
	let input2: any;
	let queryCircuit: Core.QueryIdentityCircom.QueryIdentity;
	let queryCircuitTD1: Core.QueryIdentityTD1Circom.QueryIdentity;


	before(async function () {
		circuit0 = await zkit.getCircuit("test/circuits/registerIdentity_1_256_3_4_600_248_1_1496_3_256.circom:RegisterIdentityBuilder");
		const testJson0 = path.join(__dirname, `./inputs/registerIdentity_1_256_3_4_600_248_1_1496_3_256.json`);
		const data0 = await fs.promises.readFile(testJson0, 'utf8');
		input0 = JSON.parse(data0);
		circuit1 = await zkit.getCircuit("test/circuits/registerIdentity_1_256_3_5_576_248_NA.circom:RegisterIdentityBuilder");
		const testJson1 = path.join(__dirname, `./inputs/registerIdentity_1_256_3_5_576_248_NA.json`);
		const data1 = await fs.promises.readFile(testJson1, 'utf8');
		input1 = JSON.parse(data1);
		circuit2 = await zkit.getCircuit("test/circuits/registerIdentity_1_256_3_6_576_248_1_2432_5_296.circom:RegisterIdentityBuilder");
		const testJson2 = path.join(__dirname, `./inputs/registerIdentity_1_256_3_6_576_248_1_2432_5_296.json`);
		const data2 = await fs.promises.readFile(testJson2, 'utf8');
		input2 = JSON.parse(data2);

		queryCircuit = await zkit.getCircuit("test/circuits/queryIdentity.circom:QueryIdentity");
		queryCircuitTD1 = await zkit.getCircuit("test/circuits/queryIdentityTD1.circom:QueryIdentity");

	});


	it("registerIdentity_1_256_3_4_600_248_1_1496_3_256 test", async function () {

		let docType0 = parseInt("registerIdentity_1_256_3_4_600_248_1_1496_3_256".split("_")[3]);

		let dg1Len0 = 760;
			if (docType0 == 3){
			dg1Len0 = 744;
		}

		const circuitInput0 = {
			dg1: input0.dg1,
			dg15: input0.dg15,
			signedAttributes: input0.signedAttributes,
			encapsulatedContent: input0.encapsulatedContent,
			pubkey: input0.pubkey,
			signature: input0.signature,
			skIdentity: input0.skIdentity,
			slaveMerkleRoot: input0.slaveMerkleRoot,
			slaveMerkleInclusionBranches: input0.slaveMerkleInclusionBranches
		};
		await expect(circuit0).to.have.witnessInputs(circuitInput0);
		const proof0 = await circuit0.generateProof(circuitInput0);
		await expect(circuit0).to.verifyProof(proof0);


		let chunking0 = ["", "", "", ""];
		for (var i = 0; i < 4; i++){
			for (var j = 0; j < dg1Len0/4; j++){
				chunking0[i] += input0.dg1[i*(dg1Len0/4) + dg1Len0/4 - 1 - j].toString();
			}
		}

		let skHash0 = Poseidon.hash([BigInt(input0.skIdentity)]);
		let dgCommit0 = Poseidon.hash([BigInt(`0b${chunking0[0]}`), BigInt(`0b${chunking0[1]}`), BigInt(`0b${chunking0[2]}`), BigInt(`0b${chunking0[3]}`), skHash0]);
		const timestampSeconds0 = Date.now().toString().slice(0, Date.now().toString().length-3);
		let value0 = Poseidon.hash([BigInt(dgCommit0), 1n, BigInt(timestampSeconds0)]);

		let pubkey0 = babyJub.mulPointEscalar(babyJub.Base8, BigInt(input0.skIdentity));
		let pk_hash0 = Poseidon.hash(pubkey0);
		let index0 = Poseidon.hash([BigInt(proof0.publicSignals.passportHash), pk_hash0]);

		let root0 = Poseidon.hash([index0, value0, 1n]);
		let branches0 = new Array(80).fill("0");
		const queryCircuitInput0 = {
			dg1: input0.dg1.slice(0, dg1Len0),
			eventID: "0x1234567890",
			eventData: "0x12345678901234567890",
			idStateRoot: `${root0}`,
			idStateSiblings: branches0,
			pkPassportHash: `${proof0.publicSignals.passportHash}`,
			skIdentity: `${input0.skIdentity}`,
			selector: "0",
			timestamp: `${timestampSeconds0}`,
			currentDate: "0x323431303135",
			identityCounter: "1",
			timestampLowerbound: "0",
			timestampUpperbound: "19000000000",
			identityCounterLowerbound: "0",
			identityCounterUpperbound: "1000",
			birthDateLowerbound: "0x303030303030",
			birthDateUpperbound: "0x303631303135",
			expirationDateLowerbound: "0x303030303030",
			expirationDateUpperbound: "0x333030303030",
			citizenshipMask: "15"
		}

		if (docType0 == 3) {
			await expect(queryCircuit).to.have.witnessInputs(queryCircuitInput0);
			const proof0_2 = await queryCircuit.generateProof(queryCircuitInput0);
			await expect(queryCircuit).to.verifyProof(proof0_2);
		}else{
			await expect(queryCircuitTD1).to.have.witnessInputs(queryCircuitInput0);
			const proof0_2 = await queryCircuitTD1.generateProof(queryCircuitInput0);
			await expect(queryCircuitTD1).to.verifyProof(proof0_2);
		}
	});


	it("registerIdentity_1_256_3_5_576_248_NA test", async function () {

		let docType1 = parseInt("registerIdentity_1_256_3_5_576_248_NA".split("_")[3]);

		let dg1Len1 = 760;
			if (docType1 == 3){
			dg1Len1 = 744;
		}

		const circuitInput1 = {
			dg1: input1.dg1,
			dg15: input1.dg15,
			signedAttributes: input1.signedAttributes,
			encapsulatedContent: input1.encapsulatedContent,
			pubkey: input1.pubkey,
			signature: input1.signature,
			skIdentity: input1.skIdentity,
			slaveMerkleRoot: input1.slaveMerkleRoot,
			slaveMerkleInclusionBranches: input1.slaveMerkleInclusionBranches
		};
		await expect(circuit1).to.have.witnessInputs(circuitInput1);
		const proof1 = await circuit1.generateProof(circuitInput1);
		await expect(circuit1).to.verifyProof(proof1);


		let chunking1 = ["", "", "", ""];
		for (var i = 0; i < 4; i++){
			for (var j = 0; j < dg1Len1/4; j++){
				chunking1[i] += input1.dg1[i*(dg1Len1/4) + dg1Len1/4 - 1 - j].toString();
			}
		}

		let skHash1 = Poseidon.hash([BigInt(input1.skIdentity)]);
		let dgCommit1 = Poseidon.hash([BigInt(`0b${chunking1[0]}`), BigInt(`0b${chunking1[1]}`), BigInt(`0b${chunking1[2]}`), BigInt(`0b${chunking1[3]}`), skHash1]);
		const timestampSeconds1 = Date.now().toString().slice(0, Date.now().toString().length-3);
		let value1 = Poseidon.hash([BigInt(dgCommit1), 1n, BigInt(timestampSeconds1)]);

		let pubkey1 = babyJub.mulPointEscalar(babyJub.Base8, BigInt(input1.skIdentity));
		let pk_hash1 = Poseidon.hash(pubkey1);
		let index1 = Poseidon.hash([BigInt(proof1.publicSignals.passportHash), pk_hash1]);

		let root1 = Poseidon.hash([index1, value1, 1n]);
		let branches1 = new Array(80).fill("0");
		const queryCircuitInput1 = {
			dg1: input1.dg1.slice(0, dg1Len1),
			eventID: "0x1234567890",
			eventData: "0x12345678901234567890",
			idStateRoot: `${root1}`,
			idStateSiblings: branches1,
			pkPassportHash: `${proof1.publicSignals.passportHash}`,
			skIdentity: `${input1.skIdentity}`,
			selector: "0",
			timestamp: `${timestampSeconds1}`,
			currentDate: "0x323431303135",
			identityCounter: "1",
			timestampLowerbound: "0",
			timestampUpperbound: "19000000000",
			identityCounterLowerbound: "0",
			identityCounterUpperbound: "1000",
			birthDateLowerbound: "0x303030303030",
			birthDateUpperbound: "0x303631303135",
			expirationDateLowerbound: "0x303030303030",
			expirationDateUpperbound: "0x333030303030",
			citizenshipMask: "15"
		}

		if (docType1 == 3) {
			await expect(queryCircuit).to.have.witnessInputs(queryCircuitInput1);
			const proof1_2 = await queryCircuit.generateProof(queryCircuitInput1);
			await expect(queryCircuit).to.verifyProof(proof1_2);
		}else{
			await expect(queryCircuitTD1).to.have.witnessInputs(queryCircuitInput1);
			const proof1_2 = await queryCircuitTD1.generateProof(queryCircuitInput1);
			await expect(queryCircuitTD1).to.verifyProof(proof1_2);
		}
	});


	it("registerIdentity_1_256_3_6_576_248_1_2432_5_296 test", async function () {

		let docType2 = parseInt("registerIdentity_1_256_3_6_576_248_1_2432_5_296".split("_")[3]);

		let dg1Len2 = 760;
			if (docType2 == 3){
			dg1Len2 = 744;
		}

		const circuitInput2 = {
			dg1: input2.dg1,
			dg15: input2.dg15,
			signedAttributes: input2.signedAttributes,
			encapsulatedContent: input2.encapsulatedContent,
			pubkey: input2.pubkey,
			signature: input2.signature,
			skIdentity: input2.skIdentity,
			slaveMerkleRoot: input2.slaveMerkleRoot,
			slaveMerkleInclusionBranches: input2.slaveMerkleInclusionBranches
		};
		await expect(circuit2).to.have.witnessInputs(circuitInput2);
		const proof2 = await circuit2.generateProof(circuitInput2);
		await expect(circuit2).to.verifyProof(proof2);


		let chunking2 = ["", "", "", ""];
		for (var i = 0; i < 4; i++){
			for (var j = 0; j < dg1Len2/4; j++){
				chunking2[i] += input2.dg1[i*(dg1Len2/4) + dg1Len2/4 - 1 - j].toString();
			}
		}

		let skHash2 = Poseidon.hash([BigInt(input2.skIdentity)]);
		let dgCommit2 = Poseidon.hash([BigInt(`0b${chunking2[0]}`), BigInt(`0b${chunking2[1]}`), BigInt(`0b${chunking2[2]}`), BigInt(`0b${chunking2[3]}`), skHash2]);
		const timestampSeconds2 = Date.now().toString().slice(0, Date.now().toString().length-3);
		let value2 = Poseidon.hash([BigInt(dgCommit2), 1n, BigInt(timestampSeconds2)]);

		let pubkey2 = babyJub.mulPointEscalar(babyJub.Base8, BigInt(input2.skIdentity));
		let pk_hash2 = Poseidon.hash(pubkey2);
		let index2 = Poseidon.hash([BigInt(proof2.publicSignals.passportHash), pk_hash2]);

		let root2 = Poseidon.hash([index2, value2, 1n]);
		let branches2 = new Array(80).fill("0");
		const queryCircuitInput2 = {
			dg1: input2.dg1.slice(0, dg1Len2),
			eventID: "0x1234567890",
			eventData: "0x12345678901234567890",
			idStateRoot: `${root2}`,
			idStateSiblings: branches2,
			pkPassportHash: `${proof2.publicSignals.passportHash}`,
			skIdentity: `${input2.skIdentity}`,
			selector: "0",
			timestamp: `${timestampSeconds2}`,
			currentDate: "0x323431303135",
			identityCounter: "1",
			timestampLowerbound: "0",
			timestampUpperbound: "19000000000",
			identityCounterLowerbound: "0",
			identityCounterUpperbound: "1000",
			birthDateLowerbound: "0x303030303030",
			birthDateUpperbound: "0x303631303135",
			expirationDateLowerbound: "0x303030303030",
			expirationDateUpperbound: "0x333030303030",
			citizenshipMask: "15"
		}

		if (docType2 == 3) {
			await expect(queryCircuit).to.have.witnessInputs(queryCircuitInput2);
			const proof2_2 = await queryCircuit.generateProof(queryCircuitInput2);
			await expect(queryCircuit).to.verifyProof(proof2_2);
		}else{
			await expect(queryCircuitTD1).to.have.witnessInputs(queryCircuitInput2);
			const proof2_2 = await queryCircuitTD1.generateProof(queryCircuitInput2);
			await expect(queryCircuitTD1).to.verifyProof(proof2_2);
		}
	});
});