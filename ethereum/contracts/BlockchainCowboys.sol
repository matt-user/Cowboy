// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BlockChainCowboys is ERC721{
    struct BattleOffer {
        bool wantsToBattle;
        address willOnlyBattle;  // Specify to only battle a specific person
    }

    struct Battle {
        uint cowboyId1;
        uint cowboyId2;
        uint turns;
        string command1;
        string command2;
    }

    struct Cowboy {
        string name;
        uint shots;
        bool takenTurn;
        bool dodging;
        bool shooting;
    }

    enum Commands{ RELOAD, SHOOT, DODGE }

    // Maps the id of a cowboy to if they want to battle or not
    mapping(uint => BattleOffer) wantsToBattle;
    Cowboy[] public cowboys;
    Battle battle;
    address public gameOwner;

    constructor() {
        gameOwner = msg.sender;
    }

    modifier onlyOwnerOf(uint _cowboyId) {
        require(ownerOf(_cowboyId) == msg.sender, "Must be the owner of the cowboy to battle");
        _;
    }

    modifier onlyGameOwner() {
        require(gameOwner == msg.sender, "Only the game owner can do this");
        _;
    }

    function createNewCowboy(string memory _name, address _to) public onlyGameOwner {
        uint id = cowboys.length;
        cowboys.push(Cowboy(_name, 0, false, false, false));
        _safeMint(_to, id);
    }

    /**
    * @dev Offers a battle with the cowboy of the given id
    * @param cowboyId id of cowboy who wants to fight
    **/
    function offerCowboyToBattle(uint cowboyId) public onlyOwnerOf(cowboyId) {
        wantsToBattle[cowboyId] = BattleOffer(true, address(0));
    }

    /**
    * @dev Offers a battle with the cowboy specifically to the address to
    * @param cowboyId id of cowboy who wants to fight to address caller wants to fight
    **/
    function offerCowboyToBattle(uint cowboyId, address to) public onlyOwnerOf(cowboyId) {
        wantsToBattle[cowboyId] = BattleOffer(true, to);
    }

    function fightCowboy(uint ownerCowboyId, uint cowboyId) public onlyOwnerOf(ownerCowboyId) {
        BattleOffer storage battleOffer = wantsToBattle[cowboyId];
        require(battleOffer.wantsToBattle, "This cowboy does not want to battle right now.");
        require(battleOffer.willOnlyBattle == address(0) || battleOffer.willOnlyBattle == msg.sender, "This cowboy does not want to battle with you");
        battle = Battle(cowboyId, ownerCowboyId, 0, "", "");
    }

    function takeTurn(uint command, uint cowboyId) public onlyOwnerOf(cowboyId) {
        require(!cowboys[cowboyId].takenTurn, "This cowboy cannot take a turn until this turn is over");
        if (command == 0) {
            reload(cowboyId);
        } else if (command == 1) {
            shoot(cowboyId);
        } else if (command == 2) {
            dodge(cowboyId);
        } else {
            // Error
        }
        cowboys[cowboyId].takenTurn = true;
    }

    function reload(uint _cowboy) public {
        Cowboy storage cowboy = cowboys[_cowboy];
        cowboy.shots++;
        cowboy.dodging = false;
        cowboy.shooting = false;
    }

    function shoot(uint _cowboy) public {
        Cowboy storage cowboy = cowboys[_cowboy];
        cowboy.shots--;
        cowboy.dodging = false;
        cowboy.shooting = true;
    }

    function dodge(uint _cowboy) public {
        Cowboy storage cowboy = cowboys[_cowboy];
        cowboy.dodging = true;
        cowboy.shooting = false;
    }
}


