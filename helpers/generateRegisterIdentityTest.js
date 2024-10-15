const { exec } = require('child_process');
const fs = require('fs');
const path = require("path");

function createQueryCircuit(){
    res_string = "pragma circom  2.1.6;\n\n"
    res_string += `include "../../circuits/identityManagement/circuits/queryIdentity.circom";\n\n`
    res_string += `component main { public [eventID,\n`
    res_string +=  `                       eventData,\n`
    res_string +=  `                       idStateRoot,\n` 
    res_string +=  `                       selector,\n`
    res_string +=  `                       currentDate,\n`
    res_string +=  `                       timestampLowerbound,\n`
    res_string +=  `                       timestampUpperbound,\n`
    res_string +=  `                       identityCounterLowerbound,\n`
    res_string +=  `                       identityCounterUpperbound,\n`
    res_string +=  `                       birthDateLowerbound,\n`
    res_string +=  `                       birthDateUpperbound,\n`
    res_string +=  `                       expirationDateLowerbound,\n`
    res_string +=  `                       expirationDateUpperbound,\n`
    res_string +=  `                       citizenshipMask\n`
    res_string +=  `                       ] } = QueryIdentity(80);`

    try {
        fs.writeFileSync("test/circuits/queryIdentity.circom", res_string, 'utf8');
        // console.log(`File created and content written to ${filePath}`);
    } catch (err) {
        console.error(`Error writing to file: ${err}`);
    }

    res_string = "pragma circom  2.1.6;\n\n"
    res_string += `include "../../circuits/identityManagement/circuits/queryIdentityTD1.circom";\n\n`
    res_string += `component main { public [eventID,\n`
    res_string +=  `                       eventData,\n`
    res_string +=  `                       idStateRoot,\n` 
    res_string +=  `                       selector,\n`
    res_string +=  `                       currentDate,\n`
    res_string +=  `                       timestampLowerbound,\n`
    res_string +=  `                       timestampUpperbound,\n`
    res_string +=  `                       identityCounterLowerbound,\n`
    res_string +=  `                       identityCounterUpperbound,\n`
    res_string +=  `                       birthDateLowerbound,\n`
    res_string +=  `                       birthDateUpperbound,\n`
    res_string +=  `                       expirationDateLowerbound,\n`
    res_string +=  `                       expirationDateUpperbound,\n`
    res_string +=  `                       citizenshipMask\n`
    res_string +=  `                       ] } = QueryIdentity(80);`

    try {
        fs.writeFileSync("test/circuits/queryIdentityTD1.circom", res_string, 'utf8');
        // console.log(`File created and content written to ${filePath}`);
    } catch (err) {
        console.error(`Error writing to file: ${err}`);
    }
}

function updateOnlyFilesInConfig(filenames, configFilePath) {
    try {
        let configContent = fs.readFileSync(configFilePath, 'utf8');

        let lines = configContent.split('\n');

        // Find and update the line that contains 'onlyFiles: []'
        lines = lines.map(line => {
            if (line.includes('onlyFiles:')) {
                return `      onlyFiles: ["queryIdentity.circom", "queryIdentityTD1.circom", ${filenames.map(file => `"${file}.circom"`)}],`
            }
            return line;
        });

        // Join the lines back into a single string
        const updatedConfigContent = lines.join('\n');

        // Write the updated content back to the config file
        fs.writeFileSync(configFilePath, updatedConfigContent, 'utf8');

        console.log(`Successfully updated onlyFiles in ${configFilePath}`);
    } catch (error) {
        console.error(`Error updating config file: ${error.message}`);
    }

}



function modifyFile(filePath) {
    try {
        const fileContent = fs.readFileSync(filePath, 'utf8');
        
        const lines = fileContent.split('\n');

        if (lines.length < 3) {
            throw new Error('The file does not have at least 3 lines.');
        }

        const thirdLine = lines[2];
        
        if (thirdLine.length >= 12) {
            const modifiedLine = thirdLine.slice(0, 10) + thirdLine.slice(16, 75) + "Mock" + thirdLine.slice(82);

            lines[2] = modifiedLine; 
        } else {
            throw new Error('The third line does not have enough characters.');
        }

        const updatedContent = lines.join('\n');

        fs.writeFileSync(filePath, updatedContent, 'utf8');

        console.log(`File successfully updated at ${filePath}`);
    } catch (err) {
        console.error(`Error modifying file: ${err.message}`);
    }
}

function copyFileSync(src, dest) {
    try {
        fs.copyFileSync(src, dest);
    } catch (err) {
        console.error(`Error copying file: ${err}`);
    }
}

function generateTestFile(filenames){

    let result_str = "import { zkit } from \"hardhat\";\nimport { expect } from \"chai\";\nimport fs from \"fs\";\nimport path from \"path\";\nimport { Poseidon, babyJub } from \"@iden3/js-crypto\";\n"
    result_str += `import { Core } from "@zkit";\n`

    result_str += `\nfunction bigintToUint8Array(bigIntValue: bigint): Uint8Array {`
    result_str += `\n\tconst hexString = bigIntValue.toString(16);`
    result_str += `\n\tconst paddedHexString = hexString.length % 2 === 0 ? hexString : '0' + hexString;`
    result_str += `\n\tconst byteArray = new Uint8Array(paddedHexString.length / 2);`
    result_str += `\n\tfor (let i = 0; i < byteArray.length; i++) {`
    result_str += `\n\t\tbyteArray[i] = parseInt(paddedHexString.substr(i * 2, 2), 16);`
    result_str += `\n\t}`
    result_str += `\n\tif (byteArray.length < 32) {`
    result_str += `\n\t\tconst paddedArray = new Uint8Array(32);`
    result_str += `\n\t\tpaddedArray.set(byteArray, 32 - byteArray.length);`
    result_str += `\n\t\treturn paddedArray;`
    result_str += `\n\t}`
    result_str += `\n\treturn byteArray;`
    result_str += `\n}\n`
    
    result_str += `\n\ndescribe("Register Identity Circuit Tests", function () {\n`
    for (var i = 0; i < filenames.length; i++){
        result_str += `\tlet circuit${i}: Core.R${filenames[i].slice(1)}Circom.RegisterIdentityBuilder;\n`
        result_str += `\tlet input${i}: any;\n`
    }
    result_str += `\tlet queryCircuit: Core.QueryIdentityCircom.QueryIdentity;\n`
	result_str += `\tlet queryCircuitTD1: Core.QueryIdentityTD1Circom.QueryIdentity;\n`
    
  
    result_str += `\n\n\tbefore(async function () {\n`;
    for (var i = 0; i < filenames.length; i++){
       result_str += `\t\tcircuit${i} = await zkit.getCircuit("test/circuits/${filenames[i]}.circom:RegisterIdentityBuilder");\n`
       result_str += `\t\tconst testJson${i} = path.join(__dirname, \`./inputs/${filenames[i]}.json\`);\n`
       result_str += `\t\tconst data${i} = await fs.promises.readFile(testJson${i}, 'utf8');\n`
       result_str += `\t\tinput${i} = JSON.parse(data${i});\n`
    }
    result_str += `\n\t\tqueryCircuit = await zkit.getCircuit("test/circuits/queryIdentity.circom:QueryIdentity");`
    result_str += `\n\t\tqueryCircuitTD1 = await zkit.getCircuit("test/circuits/queryIdentityTD1.circom:QueryIdentity");\n\n`

    result_str += `\t});\n`

    for (var i = 0; i < filenames.length; i++){
        result_str += `\n\n\tit("${filenames[i]} test", async function () {\n`
        result_str += `\n\t\tlet docType${i} = parseInt("${filenames[i]}".split("_")[3]);\n`
        result_str += `\n\t\tlet dg1Len${i} = 760;`
        result_str += `\n\t\t\tif (docType${i} == 3){`
        result_str += `\n\t\t\tdg1Len${i} = 744;`
        result_str += `\n\t\t}\n`
        result_str += `\n\t\tconst circuitInput${i} = {`
        result_str += `\n\t\t\tdg1: input${i}.dg1,`
        result_str += `\n\t\t\tdg15: input${i}.dg15,`
        result_str += `\n\t\t\tsignedAttributes: input${i}.signedAttributes,`
        result_str += `\n\t\t\tencapsulatedContent: input${i}.encapsulatedContent,`
        result_str += `\n\t\t\tpubkey: input${i}.pubkey,`
        result_str += `\n\t\t\tsignature: input${i}.signature,`
        result_str += `\n\t\t\tskIdentity: input${i}.skIdentity,`
        result_str += `\n\t\t\tslaveMerkleRoot: input${i}.slaveMerkleRoot,`
        result_str += `\n\t\t\tslaveMerkleInclusionBranches: input${i}.slaveMerkleInclusionBranches`
        result_str += `\n\t\t};`
        result_str += `\n\t\tawait expect(circuit${i}).to.have.witnessInputs(circuitInput${i});`
        result_str += `\n\t\tconst proof${i} = await circuit${i}.generateProof(circuitInput${i});`
        result_str += `\n\t\tawait expect(circuit${i}).to.verifyProof(proof${i});\n\n`
        result_str += `\n\t\tlet chunking${i} = ["", "", "", ""];`
        result_str += `\n\t\tfor (var i = 0; i < 4; i++){`
        result_str += `\n\t\t\tfor (var j = 0; j < dg1Len${i}/4; j++){`
        result_str += `\n\t\t\t\tchunking${i}[i] += input${i}.dg1[i*(dg1Len${i}/4) + dg1Len${i}/4 - 1 - j].toString();`
        result_str += `\n\t\t\t}`
        result_str += `\n\t\t}\n`
		result_str += `\n\t\tlet skHash${i} = Poseidon.hash([BigInt(input${i}.skIdentity)]);`
		result_str += `\n\t\tlet dgCommit${i} = Poseidon.hash([BigInt(\`0b\${chunking${i}[0]}\`), BigInt(\`0b\${chunking${i}[1]}\`), BigInt(\`0b\${chunking${i}[2]}\`), BigInt(\`0b\${chunking${i}[3]}\`), skHash${i}]);`
		result_str += `\n\t\tconst timestampSeconds${i} = Date.now().toString().slice(0, Date.now().toString().length-3);`
		result_str += `\n\t\tlet value${i} = Poseidon.hash([BigInt(dgCommit${i}), 1n, BigInt(timestampSeconds${i})]);`
		result_str += `\n\n\t\tlet pubkey${i} = babyJub.mulPointEscalar(babyJub.Base8, BigInt(input${i}.skIdentity));`
		result_str += `\n\t\tlet pk_hash${i} = Poseidon.hash(pubkey${i});`
		result_str += `\n\t\tlet index${i} = Poseidon.hash([BigInt(proof${i}.publicSignals.passportHash), pk_hash${i}]);`
		result_str += `\n\n\t\tlet root${i} = Poseidon.hash([index${i}, value${i}, 1n]);`
		result_str += `\n\t\tlet branches${i} = new Array(80).fill("0");\n`
        result_str += `\t\tconst queryCircuitInput${i} = {\n`
		result_str += `\t\t\tdg1: input${i}.dg1.slice(0, dg1Len${i}),\n`
        result_str += `\t\t\teventID: "0x1234567890",\n`
        result_str += `\t\t\teventData: "0x12345678901234567890",\n`
        result_str += `\t\t\tidStateRoot: \`\$\{root${i}\}\`,\n`
        result_str += `\t\t\tidStateSiblings: branches${i},\n`
        result_str += `\t\t\tpkPassportHash: \`\$\{proof${i}.publicSignals.passportHash\}\`,\n`
        result_str += `\t\t\tskIdentity: \`\$\{input${i}.skIdentity\}\`,\n`
        result_str += `\t\t\tselector: "0",\n`
        result_str += `\t\t\ttimestamp: \`\$\{timestampSeconds${i}\}\`,\n`
        const currentDate = new Date();
        const formattedDate = currentDate.toISOString().split('T')[0].split("-");
        const date = `0x3${formattedDate[0][2]}3${formattedDate[0][3]}3${formattedDate[1][0]}3${formattedDate[1][1]}3${formattedDate[2][0]}3${formattedDate[2][1]}`
        result_str += `\t\t\tcurrentDate: "${date}",\n`
        result_str += `\t\t\tidentityCounter: "1",\n`
        result_str += `\t\t\ttimestampLowerbound: "0",\n`
        result_str += `\t\t\ttimestampUpperbound: "19000000000",\n`
        result_str += `\t\t\tidentityCounterLowerbound: "0",\n`
        result_str += `\t\t\tidentityCounterUpperbound: "1000",\n`
        const birthDate = `0x3${formattedDate[0][3] >= 8 ? parseInt(formattedDate[0][2], 10) - 1 : parseInt(formattedDate[0][2], 10) - 2}3${formattedDate[0][3] >= 8 ? parseInt(formattedDate[0][3], 10) - 8 : parseInt(formattedDate[0][3], 10) + 2}3${formattedDate[1][0]}3${formattedDate[1][1]}3${formattedDate[2][0]}3${formattedDate[2][1]}`
        result_str += `\t\t\tbirthDateLowerbound: "0x303030303030",\n`
        result_str += `\t\t\tbirthDateUpperbound: "${birthDate}",\n`
        result_str += `\t\t\texpirationDateLowerbound: "0x303030303030",\n`
        result_str += `\t\t\texpirationDateUpperbound: "0x333030303030",\n`
        result_str += `\t\t\tcitizenshipMask: "15"\n`
		result_str += `\t\t}\n`
        result_str += `\n\t\tif (docType${i} == 3) {`
		result_str += `\n\t\t\tawait expect(queryCircuit).to.have.witnessInputs(queryCircuitInput${i});`
		result_str += `\n\t\t\tconst proof${i}_2 = await queryCircuit.generateProof(queryCircuitInput${i});`
		result_str += `\n\t\t\tawait expect(queryCircuit).to.verifyProof(proof${i}_2);`
		result_str += `\n\t\t}else{`
		result_str += `\n\t\t\tawait expect(queryCircuitTD1).to.have.witnessInputs(queryCircuitInput${i});`
		result_str += `\n\t\t\tconst proof${i}_2 = await queryCircuitTD1.generateProof(queryCircuitInput${i});`
		result_str += `\n\t\t\tawait expect(queryCircuitTD1).to.verifyProof(proof${i}_2);`
		result_str += `\n\t\t}`
        result_str += `\n\t});\n`
    }
    result_str += "});"
    const filePath = path.join(__dirname, '../test/registerIdentityTest.ts');

    try {
        fs.writeFileSync(filePath, result_str, 'utf8');
        // console.log(`File created and content written to ${filePath}`);
    } catch (err) {
        console.error(`Error writing to file: ${err}`);
    }
}

function generateFilesForAll(filenames, callback) {
    let index = 0;
    let circuit_filenames = [];

    function executeNext() {
        if (index >= filenames.length) {
            return callback(null, circuit_filenames); 
        }

        const filename = filenames[index];
        console.log("Executing for", filename);

        exec(`python3 tests/tests/process_passport.py ./test/passports/${filename}`, (error, stdout, stderr) => {
            if (error) {
                console.error(`Error executing script: ${error.message}`);
                return callback(error);
            }
            if (stderr) {
                console.error(`Script stderr: ${stderr}`);
                return callback(new Error(stderr));
            }

            const tmp_txt = path.join(__dirname, `../tests/tests/inputs/tmp.txt`);
            fs.readFile(tmp_txt, 'utf8', (err, short_filename) => {
                if (err) {
                    return callback(err);
                }

                circuit_filenames.push(short_filename.trim());

                copyFileSync(
                    "./tests/tests/circuits/identityManagement/" + circuit_filenames[index] + ".circom", 
                    "./test/circuits/" + circuit_filenames[index] + ".circom"
                );
                modifyFile("./test/circuits/" + circuit_filenames[index] + ".circom");
                copyFileSync(
                    "./tests/tests/inputs/generated/input_" + circuit_filenames[index] + "_2.dev.json", 
                    "./test/inputs/" + circuit_filenames[index] + ".json"
                );

                index++;

                setTimeout(executeNext, 2500); 
            });
        });
    }

    executeNext(); 
}

const passportDir = path.join(__dirname, '../test/passports');
const filenames = fs.readdirSync(passportDir).filter(file => file.endsWith('.json'));
let circuit_filenames = [];

generateFilesForAll(filenames, (err, result) => {
    if (err) {
        console.error("An error occurred:", err);
    } else {
        console.log("Generated filenames:", result);
        circuit_filenames = result;
        generateTestFile(circuit_filenames);
        updateOnlyFilesInConfig(circuit_filenames, "./hardhat.config.ts");
        createQueryCircuit();
    }
});