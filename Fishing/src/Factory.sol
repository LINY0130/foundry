// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./NFT.sol";
import "./FishingGame.sol";


contract Factory is Ownable {
    address[] public nftContracts;
    address[] public fishingGames;
    NFT nft111;

    constructor() Ownable(msg.sender) {
    }

    // Function to create a new NFT contract instance
    function _createNFTContract(string memory name, string memory symbol, string memory uri) private onlyOwner {
        NFT nft = new NFT(name, symbol, uri, address(this));
        nft.grantMinterRole(address(this));
        nftContracts.push(address(nft));
    }

    function createNFTContract(string memory name, string memory symbol, string memory uri) public {
        _createNFTContract(name, symbol, uri);
    }

    // Function to create a new FishingGame contract instance
    function _createFishingGameContract() private onlyOwner {
        FishingGame game = new FishingGame(address(this));
        fishingGames.push(address(game));
    }

    function createFishingGameContract() public {
        _createFishingGameContract();
    }

    // Function to get the length of the nftContracts array
    function nftContractsLength() public view returns (uint256) {
        return nftContracts.length;
    }

    // Function to get the length of the fishingGames array
    function fishingGamesLength() public view returns (uint256) {
        return fishingGames.length;
    }

    //find the fishingGame address
    function getnewFishingGameAddress() public view returns (address) {
        if (fishingGames.length == 0) {
        revert("No FishingGame contracts deployed yet.");
    }
        return fishingGames[fishingGames.length - 1];
    }

    //find the nftContracts address
    function getnewNFTAddress() public view returns (address) {
        if (nftContracts.length == 0) {
        revert("No NFT contracts deployed yet.");
    }
        return nftContracts[nftContracts.length - 1];
    }
}