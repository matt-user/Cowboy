// Tests for BattleHandler.sol
const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const compiledBattleHandler = require('../ethereum/build/BattleHandler.json');

let accounts;
let battleHandler;
let sendProps;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();

    sendProps = { from: accounts[0], gas: '3000000'};

    // Deploy a battle handler
    battleHandler = await new web3.eth.Contract(compiledBattleHandler.abi)
        .deploy({ data: compiledBattleHandler.evm.bytecode.object })
        .send(sendProps);
});

describe('Battle Handler', () => {
    it('deploys a battle handler', () => {
        assert.ok(battleHandler.options.address, "Battle handler was not deployed correctly");
    });

    it('correctly creates new cowboys', async () => {
        await battleHandler.methods.createCowboy("uno").send(sendProps);
        await battleHandler.methods.createCowboy("dos").send(sendProps);
        const cowboy0 = await battleHandler.methods.getCowboy(0).call();
        const cowboy1 = await battleHandler.methods.getCowboy(1).call();
        cowboyStateHelper(cowboy0, "0", false, false);
        cowboyStateHelper(cowboy1, "0", false, false);
    });

    it('correctly creates new battles', async () => {
        await battleHandler.methods.createCowboy("uno").send(sendProps);
        await battleHandler.methods.createCowboy("dos").send(sendProps);
        await battleHandler.methods.createBattle(0, 1).send(sendProps);
        const battle = await battleHandler.methods.getBattle(0).call();
        battleStateHelper(battle, false, "", "0")
    });

    it('Correctly reloads for the cowboy', async () => {
        // Command cowboy1 to reload
        await battleHandler.methods.takeTurn(0, 1).send(sendProps);
        const battle = await battleHandler.methods.getBattle().call();
        cowboyStateHelper(battle.cowboy1, "1", false, true);
    });

    it('Correctly shoots for the cowboy', async () => {
        // Command cowboy 1 and 2 to reload
        await battleHandler.methods.takeTurn(0, 1).send(sendProps);
        await battleHandler.methods.takeTurn(0, 2).send(sendProps);
        // Command cowboy 1 to shoot
        await battleHandler.methods.takeTurn(1, 1).send(sendProps);
        let battle = await battleHandler.methods.getBattle().call();
        cowboyStateHelper(battle.cowboy1, '0', true, false);
    });

    it('Requires cowboy to have a shot before they can shoot', async () => {
        // Command cowboy 1 to shoot
        try {
            await battleHandler.methods.takeTurn(1, 1).send(sendProps);
            assert(false);
        } catch (err) {
            assert(err.message);
        }
    })

    it('Correctly dodges for the cowboy', async () => {
        // Command cowboy 1 to dodge
        await battleHandler.methods.takeTurn(2, 1).send(sendProps);
        let battle = await battleHandler.methods.getBattle().call();
        cowboyStateHelper(battle.cowboy1, "0", false, false);
    });

    it('Correctly ends the game', async () => {
        // Command cowboy 1 and 2 to reload
        await battleHandler.methods.takeTurn(0, 1).send(sendProps);
        await battleHandler.methods.takeTurn(0, 2).send(sendProps);
        // Command cowboy 1 to shoot and 2 to reload
        await battleHandler.methods.takeTurn(1, 1).send(sendProps);
        await battleHandler.methods.takeTurn(0, 2).send(sendProps);
        let battle = await battleHandler.methods.getBattle().call();
        battleStateHelper(battle, true, "uno", "0");
        let winner = await battleHandler.methods.getWinner().call();
        assert.strictEqual(winner, "uno", "getWinner should return uno");
    });

    it('Allows cowboys to dodge shots', async () => {
        // Command cowboy 1 and 2 to reload
        await battleHandler.methods.takeTurn(0, 1).send(sendProps);
        await battleHandler.methods.takeTurn(0, 2).send(sendProps);
        // Command cowboy 1 to shoot and 2 to dodge
        await battleHandler.methods.takeTurn(1, 1).send(sendProps);
        await battleHandler.methods.takeTurn(2, 2).send(sendProps);
        let battle = await battleHandler.methods.getBattle().call();
        battleStateHelper(battle, false, "", "0")
    });

    it('Makes sure cowboys dont take extra turns', async () => {
        // Command cowboy 2 to reload
        await battleHandler.methods.takeTurn(0, 2).send(sendProps);
        let battle = await battleHandler.methods.getBattle().call();
        cowboyStateHelper(battle.cowboy2, "1", false, true)
        try {
            // Command cowboy 2 to shoot and take extra turn
            await battleHandler.methods.takeTurn(1, 2).send(sendProps);
            assert(false);
        } catch (err) {
            assert.strictEqual(battle.turnCounter, "1", "battle turn count should be 1");
        }
    });

    it('Requires the game to be over before a call to getWinner()', async () => {
        try {
            await battleHandler.methods.getWinner().call();
            assert(false);
        } catch (err) {
            assert(err);
        }
    });

    it('Requires game to be not over for cowboys to take turns', async () => {
        // Command cowboy 1 and 2 to reload
        await battleHandler.methods.takeTurn(0, 1).send(sendProps);
        await battleHandler.methods.takeTurn(0, 2).send(sendProps);
        // Command cowboy 1 to shoot and 2 to reload
        await battleHandler.methods.takeTurn(1, 1).send(sendProps);
        await battleHandler.methods.takeTurn(0, 2).send(sendProps);
        try {
            await battleHandler.methods.takeTurn(0, 1).send(sendProps);
            assert(false);
        } catch (err) {
            assert(err);
        }
    });
});

/**
 * Tests the the cowboy has the correct state
 * @param {Object} cowboy The cowboy to check state
 * @param {String} shotCount the number of shots the cowboy has
 * @param {boolean} shootingShouldBe what cowboy.shooting should be set to
 * @param {boolean} reloadingShouldBe what cowboy.reloading should be set to
**/
function cowboyStateHelper(cowboy, shotCount, shootingShouldBe, reloadingShouldBe) {
    assert.strictEqual(cowboy.shots, shotCount, "reload did not increment cowboy.shots");
    assert.strictEqual(cowboy.reloading, reloadingShouldBe, `cowboy.reloading was not set to ${reloadingShouldBe}`);
    assert.strictEqual(cowboy.shooting, shootingShouldBe, `cowboy.shooting was not set to ${shootingShouldBe}`);
}

/** Tests the state of the battle
 * @param {Object} battle the battle to check state
 * @param {boolean} gameOverShouldBe what gameOver should be
 * @param {string} winnerShouldBe what the winner should be set to
 * @param {string} turnCounterShouldBe what the turnCounter should be
**/
function battleStateHelper(battle, gameOverShouldBe, winnerShouldBe, turnCounterShouldBe) {
    assert.strictEqual(battle.gameOver, gameOverShouldBe, `battle.gameover should be ${gameOverShouldBe}`);
    assert.strictEqual(battle.winner, winnerShouldBe, `battle.winner should be ${winnerShouldBe}`);
    assert.strictEqual(battle.turnCounter, turnCounterShouldBe, `battle.turnCounter should be ${turnCounterShouldBe}`);
}

