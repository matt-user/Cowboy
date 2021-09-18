// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./CowboyFactory";

contract CowboyOwnership is CowboyFactory, ERC721 {

    using SafeMath for uint256;

    mapping (uint => address) cowboyApprovals;

    function ownerOf(uint _tokenId) external view returns (address) {
        return cowboyToOwner[_tokenId];
    }

}