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
        assert.strictEqual(battle.cowboy1.name, "uno", "cowboy1 was not initialzed");
        assert.strictEqual(battle.cowboy2.name, "dos", "cowboy2 was not initialized");
    });

    it('Correctly reloads for the cowboy', async () => {
        // Command cowboy1 to reload
        await battleHandler.methods.takeTurn(0, 1).send({
            from: accounts[0], gas: '3000000'
        });
        const battle = await battleHandler.methods.getBattle().call();
        reloadCheck(battle.cowboy1, "1");
    });

    it('Makes sure cowboys dont take extra turns', async () => {
        // Command cowboy 2 to reload
        await battleHandler.methods.takeTurn(0, 2).send({
            from: accounts[0], gas: '3000000'
        });
        let battle = await battleHandler.methods.getBattle().call();
        reloadCheck(battle.cowboy2, "1")
        try {
            // Command cowboy 2 to shoot and take extra turn
            await battleHandler.methods.takeTurn(1, 2).send({
                from: accounts[0], gas: '3000000'
            });
            assert(false);
        } catch (err) {
            assert.strictEqual(battle.turnCounter, "1", "battle turn count should be 1");
        }
    });
});


function reloadCheck(cowboy, shotCount) {
    assert.strictEqual(cowboy.shots, shotCount, "reload did not increment cowboy.shots");
    assert.strictEqual(cowboy.reloading, true, "cowboy.reloading was not set to true");
    assert.strictEqual(cowboy.shooting, false, "cowboy.shooting was not set to false");
}

function shootCheck(cowboy, shotCount) {
    assert.strictEqual(cowboy.shots, shotCount, "shoot did not decrement cowboy.shots");
    assert.strictEqual(cowboy.shooting, true, "cowboy.shooting was not set to true");
    assert.strictEqual(cowboy.reloading, false, "cowboy.reloading was not set to false");
}
