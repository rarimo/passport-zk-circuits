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
}

function updateOnlyFilesInConfig(filenames, configFilePath) {
    try {
        let configContent = fs.readFileSync(configFilePath, 'utf8');

        let lines = configContent.split('\n');

        // Find and update the line that contains 'onlyFiles: []'
        lines = lines.map(line => {
            if (line.includes('onlyFiles:')) {
                return `      onlyFiles: ["queryIdentity.circom", ${filenames.map(file => `"${file}.circom"`)}],`
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

    let result_str = "import { zkit } from \"hardhat\";\nimport { expect } from \"chai\";\nimport fs from \"fs\";\nimport path from \"path\";\n"
    result_str += `import { Core, QueryIdentity } from "@zkit";\n`
    
    result_str += `\n\ndescribe("Register Identity Circuit Tests", function () {\n`
    for (var i = 0; i < filenames.length; i++){
        result_str += `\tlet circuit${i}: Core.R${filenames[i].slice(1)}Circom.RegisterIdentityBuilder;\n`
        result_str += `\tlet input${i}: any;\n`
    }
    result_str += `\tlet queryCircuit: QueryIdentity;\n`
    
  
    result_str += `\n\n\tbefore(async function () {\n`;
    for (var i = 0; i < filenames.length; i++){
       result_str += `\t\tcircuit${i} = await zkit.getCircuit("test/circuits/${filenames[i]}.circom:RegisterIdentityBuilder");\n`
       result_str += `\t\tconst testJson${i} = path.join(__dirname, \`./inputs/${filenames[i]}.json\`);\n`
       result_str += `\t\tconst data${i} = await fs.promises.readFile(testJson${i}, 'utf8');\n`
       result_str += `\t\tinput${i} = JSON.parse(data${i});\n\n`
    }
    result_str += `\t\tqueryCircuit = await zkit.getCircuit("QueryIdentity");\n\n`;

    result_str += `\t});\n`

    for (var i = 0; i < filenames.length; i++){
        result_str += `\n\n\tit("${filenames[i]} test", async function () {\n`
        result_str += `\n\t\tconst circuitInput = {`
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
        result_str += `\n\t\tawait expect(circuit${i}).to.have.witnessInputs(circuitInput);`
        result_str += `\n\t\tconst proof = await circuit${i}.generateProof(circuitInput);`
        result_str += `\n\t\tawait expect(circuit${i}).to.verifyProof(proof);\n\n`
        result_str += `\t\tconst queryCircuitInput = {\n`
		result_str += `\t\t\tdg1: input${i}.dg1,\n`
        result_str += `\t\t\teventID: "0x1234567890",\n`
        result_str += `\t\t\teventData: "0x12345678901234567890",\n`
        result_str += `\t\t\tidStateRoot: \`"\$\{proof.publicSignals.slaveMerkleRoot\}"\`,\n`
        result_str += `\t\t\tidStateSiblings: "",\n`
        result_str += `\t\t\tpkPassportHash: \`"\$\{proof.publicSignals.passportHash\}"\`,\n`
        result_str += `\t\t\tskIdentity: \`"\$\{input${i}.skIdentity\}"\`,\n`
        result_str += `\t\t\tselector: "0",\n`
        result_str += `\t\t\ttimestamp: "",\n`
        const currentDate = new Date();
        const formattedDate = currentDate.toISOString().split('T')[0].split("-");
        const date = `0x3${formattedDate[0][2]}3${formattedDate[0][3]}3${formattedDate[1][0]}3${formattedDate[1][1]}3${formattedDate[2][0]}3${formattedDate[2][1]}`
        result_str += `\t\t\tcurrentDate: "${date}",\n`
        result_str += `\t\t\tidentityCounter: "",\n`
        result_str += `\t\t\ttimestampLowerbound: "0",\n`
        result_str += `\t\t\ttimestampUpperbound: "19000000000",\n`
        result_str += `\t\t\tidentityCounterLowerbound: 0,\n`
        result_str += `\t\t\tidentityCounterUpperbound: 1000,\n`
        const birthDate = `0x3${formattedDate[0][3] >= 8 ? parseInt(formattedDate[0][2], 10) - 1 : parseInt(formattedDate[0][2], 10) - 2}3${formattedDate[0][3] >= 8 ? parseInt(formattedDate[0][3], 10) - 8 : parseInt(formattedDate[0][3], 10) + 2}3${formattedDate[1][0]}3${formattedDate[1][1]}3${formattedDate[2][0]}3${formattedDate[2][1]}`
        result_str += `\t\t\tbirthDateLowerbound: "0x303030303030",\n`
        result_str += `\t\t\tbirthDateUpperbound: "${birthDate}",\n`
        result_str += `\t\t\texpirationDateLowerbound: "0x303030303030",\n`
        result_str += `\t\t\texpirationDateUpperbound: "0x333030303030",\n`
        result_str += `\t\t\tcitizenshipMask: "15"\n`
		result_str += `\t\t}\n`
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