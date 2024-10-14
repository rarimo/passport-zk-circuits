import { zkit } from "hardhat";
import { expect } from "chai";
import fs from "fs";
import path from "path";
import { Core, QueryIdentity } from "@zkit";


describe("Register Identity Circuit Tests", function () {
	let circuit0: Core.RegisterIdentity_1_256_3_4_600_248_1_1496_3_256Circom.RegisterIdentityBuilder;
	let input0: any;
	let circuit1: Core.RegisterIdentity_1_256_3_5_576_248_NACircom.RegisterIdentityBuilder;
	let input1: any;
	let circuit2: Core.RegisterIdentity_1_256_3_6_576_248_1_2432_5_296Circom.RegisterIdentityBuilder;
	let input2: any;
	let queryCircuit: QueryIdentity;


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

		queryCircuit = await zkit.getCircuit("QueryIdentity");

	});


	it("registerIdentity_1_256_3_4_600_248_1_1496_3_256 test", async function () {

		const circuitInput = {
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
		await expect(circuit0).to.have.witnessInputs(circuitInput);
		const proof = await circuit0.generateProof(circuitInput);
		await expect(circuit0).to.verifyProof(proof);

		const queryCircuitInput = {
			dg1: input0.dg1,
			eventID: "0x1234567890",
			eventData: "0x12345678901234567890",
			idStateRoot: `"${proof.publicSignals.slaveMerkleRoot}"`,
			idStateSiblings: "",
			pkPassportHash: `"${proof.publicSignals.passportHash}"`,
			skIdentity: `"${input0.skIdentity}"`,
			selector: "0",
			timestamp: "",
			currentDate: "0x323431303134",
			identityCounter: "",
			timestampLowerbound: "0",
			timestampUpperbound: "19000000000",
			identityCounterLowerbound: 0,
			identityCounterUpperbound: 1000,
			birthDateLowerbound: "0x303030303030",
			birthDateUpperbound: "0x303631303134",
			expirationDateLowerbound: "0x303030303030",
			expirationDateUpperbound: "0x333030303030",
			citizenshipMask: "15"
		}

	});


	it("registerIdentity_1_256_3_5_576_248_NA test", async function () {

		const circuitInput = {
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
		await expect(circuit1).to.have.witnessInputs(circuitInput);
		const proof = await circuit1.generateProof(circuitInput);
		await expect(circuit1).to.verifyProof(proof);

		const queryCircuitInput = {
			dg1: input1.dg1,
			eventID: "0x1234567890",
			eventData: "0x12345678901234567890",
			idStateRoot: `""`,
			idStateSiblings: "",
			pkPassportHash: `"${proof.publicSignals.passportHash}"`,
			skIdentity: `"${input1.skIdentity}"`,
			selector: "0",
			timestamp: "",
			currentDate: "0x323431303134",
			identityCounter: "",
			timestampLowerbound: "0",
			timestampUpperbound: "19000000000",
			identityCounterLowerbound: 0,
			identityCounterUpperbound: 1000,
			birthDateLowerbound: "0x303030303030",
			birthDateUpperbound: "0x303631303134",
			expirationDateLowerbound: "0x303030303030",
			expirationDateUpperbound: "0x333030303030",
			citizenshipMask: "15"
		}

	});


	it("registerIdentity_1_256_3_6_576_248_1_2432_5_296 test", async function () {

		const circuitInput = {
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
		await expect(circuit2).to.have.witnessInputs(circuitInput);
		const proof = await circuit2.generateProof(circuitInput);
		await expect(circuit2).to.verifyProof(proof);

		const queryCircuitInput = {
			dg1: input2.dg1,
			eventID: "0x1234567890",
			eventData: "0x12345678901234567890",
			idStateRoot: `"${proof.publicSignals.slaveMerkleRoot}"`,
			idStateSiblings: "",
			pkPassportHash: `"${proof.publicSignals.passportHash}"`,
			skIdentity: `"${input2.skIdentity}"`,
			selector: "0",
			timestamp: "",
			currentDate: "0x323431303134",
			identityCounter: "",
			timestampLowerbound: "0",
			timestampUpperbound: "19000000000",
			identityCounterLowerbound: 0,
			identityCounterUpperbound: 1000,
			birthDateLowerbound: "0x303030303030",
			birthDateUpperbound: "0x303631303134",
			expirationDateLowerbound: "0x303030303030",
			expirationDateUpperbound: "0x333030303030",
			citizenshipMask: "15"
		}

	});
});