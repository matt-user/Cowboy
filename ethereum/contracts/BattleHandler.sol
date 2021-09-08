// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/// @title handles cowboy battling
/// @author mattauer@umich.edu
contract BattleHandler {
    struct Battle {
        uint cowboyId0;
        uint cowboyId1;
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

    constructor() {}

    /**
    * @dev requires the given cowboy id is within bounds
     */
    modifier cowboyIdInBounds(uint cowboyId) {
        require(cowboyId < cowboyList.length, "Given cowboy id out of bounds");
        _;
    }

    /**
    * @dev requires the given battle id is within bounds
     */
     modifier battleIdInBounds(uint battleId) {
         require(battleId < battleList.length, "Given battle id out of bounds");
         _;
     }

    /**
    * @dev returns the winning name if the battle is over
    * @param battleId id of the battle to get the winner
    * @return returns the name of the winner of the battle
    **/
    function getWinner(uint battleId) public view returns(string memory) {
        Battle storage battle = battleList[battleId];
        require(battle.gameOver, "There is no winner yet.");
        return battle.winner;
    }

    /**
    * @dev returns the battle of the give battle id
    * @param battleId id of the battle to return
    * @return the battle of the given id
    **/
    function getBattle(uint battleId) public battleIdInBountds(battleId) view returns(Battle memory) {
        return battleList[battleId];
    }

    /**
    * @dev returns the cowboy of the given id
    * @param cowboyId id of the cowboy to return
    * @return the cowboy of the given id
     */
     function getCowboy(uint cowboyId) public cowboyIdInBounds(cowboyId) view returns(Cowboy memory) {
         return cowboyList[cowboyId];
     }

    /**
    * @dev creates a new cowboy
    * @param _name name of the new cowboy
    **/
    function createCowboy(string memory _name) public {
        cowboyList.push(Cowboy(_name, 0, false, false, false));
    }

    /**
    * @dev creates a new battle
    * @param cowboyId1 id of cowboy1
    * @param cowboyId2 id of cowboy2
     */
    function createBattle(uint cowboyId1, uint cowboyId2) public cowboyIdInBounds(cowboyId1) cowboyIdInBounds(cowboyId2) {
        battleList.push(Battle(cowboyId1, cowboyId2, "", 0, false));
    }

    /**
    * @dev takes turn for a cowboy in a battle
    * @param command what action the cowboy takes
    * @param cowboyId specifies which cowboy to command
    * @param battleId specifies the battle for this turn
    */
    function takeTurn(uint command, uint cowboyId, uint battleId) public cowboyIdInBounds(cowboyId) battleIdInBounds(battleId) {
        Battle storage battle = battleList[battleId];
        require(!battle.gameOver, "The game is over your cowboy can't take turns.");
        require(cowboyId == battle.cowboyId0 || cowboyId == battle.cowboyId1, "The given cowboy is not in the given battle");
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

    /**
    * @dev finishes the turn for the two battling cowboys
    * @param battle the battle whose turn finished
     */
    function finishTurn(Battle storage battle) internal {
        Cowboy storage cowboy1 = cowboyList[battle.cowboyId0];
        Cowboy storage cowboy2 = cowboyList[battle.cowboyId1];
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

    /**
    * @dev reloads the given cowboy
    * @param cowboy cowboy to reload
     */
    function reload(Cowboy storage cowboy) internal {
        cowboy.shots++;
        cowboy.reloading = true;
        cowboy.shooting = false;
    }

    /**
    * @dev shoots a bullet from the cowboy
    * @param cowboy who shoots
     */
    function shoot(Cowboy storage cowboy) internal {
        require(cowboy.shots >= 1, "Your cowboy can't shoot without ammo");
        cowboy.shots--;
        cowboy.reloading = false;
        cowboy.shooting = true;
    }

    /**
    * @dev tell cowboy to dodge
    * @param cowboy who dodges
     */
    function dodge(Cowboy storage cowboy) internal {
        cowboy.reloading = false;
        cowboy.shooting = false;
    }
}