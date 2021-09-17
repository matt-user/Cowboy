// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CowboyFactory is Ownable {

    using SafeMath for uint256;
    using SafeMath for uint32;
    using SafeMath for uint16;

    event NewCowboy(uint cowboyId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Cowboy {
        string name;
        uint dna;
        uint32 level;
        uint16 winCount;
        uint16 lossCount;
    }

    Cowboy[] public cowboys;

    mapping(uint => address) public cowboyToOwner;
    mapping(address => uint) ownerCowboyCount;

    /**
    * @notice creates a cowboy with random dna
    * @param _name name of the cowboy to create
    */
    function createRandomCowboy(string memory _name) public {
        require(ownerCowboyCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createCowboy(_name, randDna);
    }

    /**
    * @notice generates a "random" set of digits to represent a cowboy's dna
    * @param _str the string to turn into a random set of digits
    */
    function _generateRandomDna(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    /**
    * @notice creates a cowboy with the given parameters
    * @param _name name of the cowboy
    * @param _dna uint representation of the cowboys dna
    */
    function _createCowboy(string memory _name, uint _dna) internal {
        uint id = cowboys.push(Cowboy(_name, _dna, 1, 0, 0)) - 1;
        cowboyToOwner[id] = msg.sender;
        ownerCowboyCount[msg.sender] = ownerCowboyCount[msg.sender].add(1);
        emit NewCowboy(id, _name, _dna);
    }
}