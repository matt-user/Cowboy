// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BlockChainCowboys is ERC721{
    struct Cowboy {
        string name;
        uint shots;
        bool dodging;
        bool shooting;
    }

    enum Commands{ RELOAD, SHOOT, DODGE }

    Cowboy[] public cowboys;
    Cowboy private cowboy1;
    Cowboy private cowboy2;
    address public gameOwner;
    bool turnOver;

    constructor() {
        gameOwner = msg.sender;
        turnOver = false;
    }

    modifier onlyOwnerOf(uint _cowboyId) {
        require(ownerOf(_cowboyId) == msg.sender, "Must be the owner of the cowboy to battle");
        _;
    }

    modifier onlyGameOwner(string memory message) {
        require(gameOwner == msg.sender, message);
        _;
    }

    function createNewCowboy(string memory _name, address _to) public onlyGameOwner("Only the game owner can create new cowboys.") {
        uint id = cowboys.length;
        cowboys.push(Cowboy(_name, 0, false, false));
        _safeMint(_to, id);
    }

    function startBattle(uint _cowboy1, uint _cowboy2) public onlyGameOwner("Only the game owner can start battles between cowboys.") {
        cowboy1 = cowboys[_cowboy1];
        cowboy2 = cowboys[_cowboy2];
    }

    function takeTurn(uint command, uint cowboy) public onlyOwnerOf(cowboy) {
        if (command == 0) {
            reload(cowboy);
        } else if (command == 1) {
            shoot(cowboy);
        } else if (command == 2) {
            dodge(cowboy);
        } else {
            // Error
        }
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


