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

function bigintToArray(n, k, x) {
    let mod = BigInt(1);
    for (let idx = 0; idx < n; idx++) {
        mod *= BigInt(2);
    }

    const ret = [];
    let xTemp = x;
    for (let idx = 0; idx < k; idx++) {
        ret.push(xTemp % mod);
        xTemp /= mod; 
    }

    return ret;
}

describe("Point interactions test", function () {
    this.timeout(10000000);

	const pointx = BigInt('0x8bd2aeb9cb7e57cb2c4b482ffc81b7afb9de27e1e3bd23c23a4453bd9ace3262');
	const pointy = BigInt('0x547ef835c3dac4fd97f8461a14611dc9c27745132ded8e545c1d54c72f046997');
	const scalar = BigInt('0x001301858ce07e3bf445932fa053a6d832cbbc761480db2961f606da978da50c');
	const pointx2 = BigInt('0x743cf1b8b5cd4f2eb55f8aa369593ac436ef044166699e37d51a14c2ce13ea0e');
	const pointy2 = BigInt('0x36ed163337deba9c946fe0bb776529da38df059f69249406892ada097eeb7cd4');
	const pointx3 = BigInt('0xa8f217b77338f1d4d6624c3ab4f6cc16d2aa843d0c0fca016b91e2ad25cae39d');
	const pointy3 = BigInt('0x4b49cafc7dac26bb0aa2a6850a1b40f5fac10e4589348fb77e65cc5602b74f9d');
	const pointScalX = BigInt('0x960a741c8d8a23d7453d793ac810edf087cffd9d20e15e57b7f228d6f0d80cd0');
	const pointScalY = BigInt('0x52f466e48816dabf4ea8519cbbff0068647e69fa291e0ed91c835ff7b6b31faf');

	it("Add unequal test (Brainpool)", async function () {
		const testJson = path.join(__dirname, './inputs/point/pointBrainpool.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "./circuits/point/brainpoolP256r1/pointAdd.circom")
			);
			const w = await circuit.calculateWitness({ 
				scalar: input.scalar,
				point:  input.point,
				point2: input.point2
			});
			await circuit.checkConstraints(w);

			const sumX = w.slice(1, 1+6);
			const sumY = w.slice(1+6, 1+12);			

			const realSumX = bigintToArray(43, 6, pointx3);
			const realSumY = bigintToArray(43, 6, pointy3);

			for (let i = 0; i < 6; i++){
				assert.equal(sumX[i], realSumX[i]);
				assert.equal(sumY[i], realSumY[i]);
			}
	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}

	});

	it("Double test (Brainpool)", async function () {
		const testJson = path.join(__dirname, './inputs/point/pointBrainpool.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "./circuits/point/brainpoolP256r1/pointDouble.circom")
			);
			const w = await circuit.calculateWitness({ 
				scalar: input.scalar,
				point:  input.point,
				point2: input.point2
			});
			await circuit.checkConstraints(w);

			const doubleX = w.slice(1, 1+6);
			const doubleY = w.slice(1+6, 1+12);			

			const realDoubleX = bigintToArray(43, 6, pointx2);
			const realDoubleY = bigintToArray(43, 6, pointy2);

			for (let i = 0; i < 6; i++){
				assert.equal(doubleX[i], realDoubleX[i]);
				assert.equal(doubleY[i], realDoubleY[i]);
			}

		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}

	});

	it("Scalar multiplication test (Add and double method) (Brainpool)", async function () {
		const testJson = path.join(__dirname, './inputs/point/pointBrainpool.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "./circuits/point/brainpoolP256r1/pointMult.circom")
			);
			const w = await circuit.calculateWitness({ 
				scalar: input.scalar,
				point:  input.point,
				point2: input.point2
			});
			await circuit.checkConstraints(w);

			const multX = w.slice(1, 1+6);
			const multY = w.slice(1+6, 1+12);			

			const realmultX = bigintToArray(43, 6, pointScalX);
			const realmultY = bigintToArray(43, 6, pointScalY);

			for (let i = 0; i < 6; i++){
				assert.equal(multX[i], realmultX[i]);
				assert.equal(multY[i], realmultY[i]);
			}


	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}

	});

	it("Scalar multiplication test (Pipenger method) (Brainpool)", async function () {
		const testJson = path.join(__dirname, './inputs/point/pointBrainpool.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "./circuits/point/brainpoolP256r1/pointMultPip.circom")
			);
			const w = await circuit.calculateWitness({ 
				scalar: input.scalar,
				point:  input.point,
				point2: input.point2
			});
			await circuit.checkConstraints(w);

			const multX = w.slice(1, 1+6);
			const multY = w.slice(1+6, 1+12);			

			const realmultX = bigintToArray(43, 6, pointScalX);
			const realmultY = bigintToArray(43, 6, pointScalY);

			for (let i = 0; i < 6; i++){
				assert.equal(multX[i], realmultX[i]);
				assert.equal(multY[i], realmultY[i]);
			}

		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}

	});

	const pointx_2 = BigInt('0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296');
	const pointy_2 = BigInt('0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5');
	const scalar_2 = BigInt('0x4d1301858ce07e3bf445932fa053a6d832cbbc761480db2961f606da978da50c');

	const pointx2_2 = BigInt('0x7cf27b188d034f7e8a52380304b51ac3c08969e277f21b35a60b48fc47669978');
	const pointy2_2 = BigInt('0x07775510db8ed040293d9ac69f7430dbba7dade63ce982299e04b79d227873d1');

	const pointx3_2 = BigInt('0x5ecbe4d1a6330a44c8f7ef951d4bf165e6c6b721efada985fb41661bc6e7fd6c');
	const pointy3_2 = BigInt('0x8734640c4998ff7e374b06ce1a64a2ecd82ab036384fb83d9a79b127a27d5032');

	const pointScalX_2 = BigInt('0x5fe7bfc2f00c709933016b8278650118f177d02394fc1073797e7339dd83a756');
	const pointScalY_2 = BigInt('0xd7ae52a2e80fb02889091774b8bc0b6ce2997c6486e5504795d6902137cd0287');


	it("Add unequal test (P256)", async function () {
		const testJson = path.join(__dirname, './inputs/point/pointP256.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "./circuits/point/P256/pointAdd.circom")
			);
			const w = await circuit.calculateWitness({ 
				scalar: input.scalar,
				point:  input.point,
				point2: input.point2
			});
			await circuit.checkConstraints(w);

			const sumX = w.slice(1, 1+6);
			const sumY = w.slice(1+6, 1+12);			

			const realSumX = bigintToArray(43, 6, pointx3_2);
			const realSumY = bigintToArray(43, 6, pointy3_2);

			for (let i = 0; i < 6; i++){
				assert.equal(sumX[i], realSumX[i]);
				assert.equal(sumY[i], realSumY[i]);
			}
	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}

	});

	it("Double test (P256)", async function () {
		const testJson = path.join(__dirname, './inputs/point/pointP256.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "./circuits/point/P256/pointDouble.circom")
			);
			const w = await circuit.calculateWitness({ 
				scalar: input.scalar,
				point:  input.point,
				point2: input.point2
			});
			await circuit.checkConstraints(w);

			const doubleX = w.slice(1, 1+6);
			const doubleY = w.slice(1+6, 1+12);			

			const realDoubleX = bigintToArray(43, 6, pointx2_2);
			const realDoubleY = bigintToArray(43, 6, pointy2_2);

			for (let i = 0; i < 6; i++){
				assert.equal(doubleX[i], realDoubleX[i]);
				assert.equal(doubleY[i], realDoubleY[i]);
			}

		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}

	});

	it("Scalar multiplication test (Add and double method) (P256)", async function () {
		const testJson = path.join(__dirname, './inputs/point/pointP256.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "./circuits/point/P256/pointMult.circom")
			);
			const w = await circuit.calculateWitness({ 
				scalar: input.scalar,
				point:  input.point,
				point2: input.point2
			});
			await circuit.checkConstraints(w);

			const multX = w.slice(1, 1+6);
			const multY = w.slice(1+6, 1+12);			

			const realmultX = bigintToArray(43, 6, pointScalX_2);
			const realmultY = bigintToArray(43, 6, pointScalY_2);

			for (let i = 0; i < 6; i++){
				assert.equal(multX[i], realmultX[i]);
				assert.equal(multY[i], realmultY[i]);
			}


	
		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}

	});

	it("Scalar multiplication test (Pipenger method) (P256)", async function () {
		const testJson = path.join(__dirname, './inputs/point/pointP256.json');
	
		try {
			const data = await fs.promises.readFile(testJson, 'utf8');
			const input = JSON.parse(data);
	
			const circuit = await wasm_tester(
				path.join(__dirname, "./circuits/point/P256/pointMultPip.circom")
			);
			const w = await circuit.calculateWitness({ 
				scalar: input.scalar,
				point:  input.point,
				point2: input.point2
			});
			await circuit.checkConstraints(w);

			const multX = w.slice(1, 1+6);
			const multY = w.slice(1+6, 1+12);			

			const realmultX = bigintToArray(43, 6, pointScalX_2);
			const realmultY = bigintToArray(43, 6, pointScalY_2);

			for (let i = 0; i < 6; i++){
				assert.equal(multX[i], realmultX[i]);
				assert.equal(multY[i], realmultY[i]);
			}

		} catch (err) {
			console.error('Error:', err);
			throw err;  
		}

	});

});
