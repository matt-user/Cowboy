// Compiles Contracts and outputs them to a json abi
const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname, 'build');
// Whenever we compile/recompile remove the abis
fs.removeSync(buildPath);

// Compile the solidity contract file and output the abi
const contractFolder = 'contracts';
const contractName = 'BattleHandler.sol';
const contractPath = path.resolve(__dirname, contractFolder, contractName);
const source = fs.readFileSync(contractPath, 'utf-8');
const input = {
    language: "Solidity",
    sources: {
        contractName: {
            content: source,
        },
    },
    settings: {
        outputSelection: {
            "*": {
                "*": ["*"],
            },
        },
    },
};

const output = JSON.parse(solc.compile(JSON.stringify(input))).contracts[contractName];

// Create build folder if it does not already exist
fs.ensureDirSync(buildPath);

for (let contract in output) {
    fs.outputJSONSync(
        path.resolve(buildPath, `${contract}.json`),
        output[contract]
    );
}
