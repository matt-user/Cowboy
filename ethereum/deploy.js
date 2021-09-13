// Deploys our contracts to the rinkeby test network
const HDWalletProvider = require('@truffle/hdwallet-provider');
const Web3 = require('web3');
const compiledBattleHandler = require('./build/BattleHandler.json');
require('dotenv').config();

const provider = new HDWalletProvider(process.env.SECRET, process.env.INFURA_API);

const web3 = new Web3(provider);

const deploy = async () => {
    const accounts = await web3.eth.getAccounts();
    console.log(`Attempting to deploy from account ${accounts[0]}`);
    const result = await new web3.eth.Contract(compiledBattleHandler.abi)
        .deploy({ data: compiledBattleHandler.evm.bytecode.object })
        .send({ gas: '3000000', from: accounts[0], gasPrice: '5000000000'});
    console.log(`Contract deployed to ${result.options.address }`);
    provider.engine.stop();
}
deploy();
