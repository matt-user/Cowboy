// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract BattleHandler {
    struct Battle {
        Cowboy cowboy1;
        Cowboy cowboy2;
        string winner;
        uint turnCounter;
        bool gameOver;
    }

    struct Cowboy {
        string name;
        uint shots;
        bool takenTurn;
        bool reloading;
        bool shooting;
    }

    Battle[] private battleList;
    Cowboy[] private cowboyList;
    //Battle private battle;

    constructor() {}

    function getWinner(uint battleId) public view returns(string memory) {
        Battle storage battle = battleList[battleId];
        require(battle.gameOver, "There is no winner yet.");
        return battle.winner;
    }

    function getBattle(uint battleId) public view returns(Battle memory) {
        return battleList[battleId];
    }

    function createNewCowboy(string memory _name) public {
        cowboyList.push(Cowboy(_name, 0, false, false, false));
    }

    function createBattle(uint cowboyId1, uint cowboyId2) public {
        battleList.push(Battle(cowboyList[cowboyId1], cowboyList[cowboyId2], "", 0, false));
    }

    function takeTurn(uint command, uint cowboyId, uint battleId) public {
        Battle storage battle = battleList[battleId];
        require(!battle.gameOver, "The game is over your cowboy can't take turns.");
        Cowboy storage cowboy = cowboyList[cowboyId];
        require(!cowboy.takenTurn, "Cowboy has already taken turn this round");

        if (command == 0) {
            reload(cowboy);
        } else if (command == 1) {
            shoot(cowboy);
        } else if (command == 2) {
            dodge(cowboy);
        } else {
            // Error
        }
        cowboy.takenTurn = true;
        battle.turnCounter++;
        if (battle.turnCounter == 2) {
            // Both cowboys have taken their turn
            finishTurn(battle);
        }
    }

    function finishTurn(Battle storage battle) internal {
        Cowboy storage cowboy1 = battle.cowboy1;
        Cowboy storage cowboy2 = battle.cowboy2;
        if (cowboy1.shooting && cowboy2.reloading) {
            // Cowboy 1 wins
            battle.winner = cowboy1.name;
            battle.gameOver = true;
        } else if (cowboy2.shooting && cowboy1.reloading){
            // Cowboy 2 wins
            battle.winner = cowboy2.name;
            battle.gameOver = true;
        }
        // Reset for next turn
        cowboy1.takenTurn = false;
        cowboy2.takenTurn = false;
        battle.turnCounter = 0;
    }

    function reload(Cowboy storage cowboy) internal {
        cowboy.shots++;
        cowboy.reloading = true;
        cowboy.shooting = false;
    }

    function shoot(Cowboy storage cowboy) internal {
        require(cowboy.shots >= 1, "Your cowboy can't shoot without ammo");
        cowboy.shots--;
        cowboy.reloading = false;
        cowboy.shooting = true;
    }

    function dodge(Cowboy storage cowboy) internal {
        cowboy.reloading = false;
        cowboy.shooting = false;
    }
}