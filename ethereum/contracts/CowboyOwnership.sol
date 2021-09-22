// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./CowboyAttack.sol";

contract CowboyOwnership is CowboyAttack, ERC721 {

    using SafeMath for uint256;

    mapping (uint => address) cowboyApprovals;

    /**
    * @notice returns the number of cowboys the given address possesses
    * @param _owner address of the owner
    * @return returns the number of cowboys
    */
    function balanceOf(address _owner) external view returns (uint) {
        return ownerCowboyCount[_owner];
    }

    /**
    * @notice returns the owner of the given cowboy id
    * @param _tokenId id of the cowboy
    * @return returns the owner's address
    */
    function ownerOf(uint _tokenId) external view returns (address) {
        return cowboyToOwner[_tokenId];
    }

    /**
    * @notice transfers the cowboy from one address to another
    * @param _from the address to move the cowboy from
    * @param _to address to move the cowboy to
    * @param _tokenId id of the cowboy to move
    */
    function transferFrom(address _from, address _to, uint _tokenId) external payable {
        // Requires that the transfer originates from the owner of the cowboy
        // Or someone who is approved to transfer the cowboy
        require(cowboyToOwner[_tokenId] == msg.sender || cowboyApprovals[_tokenId] == msg.sender);
        _transfer(_from, _to, _tokenId);
    }

    /**
    * @notice handles the actual transfer of cowboys from one address to another
    * @param _from the address to move the cowboy from
    * @param _to address to move the cowboy to
    * @param _tokenId id of the cowboy to move
    */
    function _transfer(address _from, address _to, uint _tokenId) private {
        ownerCowboyCount[_to] = ownerCowboyCount[_to].add(1);
        ownerCowboyCount[msg.sender] = ownerCowboyCount[msg.sender].sub(1);
        cowboyToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    /**
    * @notice approves an address to transfer a cowboy
    * @param _approved address of the person approved to transfer cowboy
    * @param _tokenId id of the cowboy approved to be transfered
    */
    function approve(address _approved, uint _tokenId) external payable onlyOwnerOf(_tokenId) {
        cowboyApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }
}