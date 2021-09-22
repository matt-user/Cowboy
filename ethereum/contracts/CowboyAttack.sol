// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./CowboyFactory.sol";

contract CowboyAttack is CowboyFactory {
    
    struct Battle {
        uint cowboyId0;
        uint cowboyId1;
        string winner;
        uint turnCounter;
        bool gameOver;
    }

    Battle[] private battles;

    modifier onlyOwnerOf(uint _cowboyId) {
        require(msg.sender == cowboyToOwner[_cowboyId], "You are not the owner of this cowboy");
        _;
    }

    function enterBattle(uint _battleId, uint _cowboyId) onlyOwnerOf(_cowboyId) external {
        
    }
}