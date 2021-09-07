// Tests for BattleHandler.sol
const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const compiledBattleHandler = require('../ethereum/build/BattleHandler.json');

let accounts;
let battleHandler;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();

    // Deploy a battle handler
    battleHandler = await new web3.eth.Contract(compiledBattleHandler.abi)
        .deploy({ data: compiledBattleHandler.evm.bytecode.object })
        .send({ from: accounts[0], gas: '3000000' });
});

describe('Battle Handler', () => {
    it('deploys a battle handler', () => {
        assert.ok(battleHandler.options.address, "Battle handler was not deployed correctly");
    });

    it('correctly initialzes data', async () => {
        const battle = await battleHandler.methods.getBattle().call();
        assert.strictEqual(battle.cowboy1.name, "uno");
        assert.strictEqual(battle.cowboy2.name, "dos");
    });
});
