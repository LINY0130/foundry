// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFT.sol";

contract Admin is Ownable {
    NFT public nftContract;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address _nftAddress) Ownable(msg.sender) {
        nftContract = NFT(_nftAddress);
    }

    // Grant the MINTER_ROLE 
    function grantMinterRole(address contractAddress) public onlyOwner {
        nftContract.grantRole(MINTER_ROLE, contractAddress);
    }

}