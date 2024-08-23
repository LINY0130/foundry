// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./NFT.sol";
import "./FishingGame.sol";

event OwnerSet(address indexed owner);

contract Factory is Ownable {
    address[] public nftContracts;
    address[] public fishingGames;

    constructor(address _owner) Ownable(_owner) {
        emit OwnerSet(_owner);
    }

    // Function to create a new NFT contract instance
    function createNFTContract(string memory name, string memory symbol, string memory uri) public onlyOwner {
        NFT nft = new NFT(name, symbol, uri);
        nftContracts.push(address(nft));
    }

    // Function to create a new FishingGame contract instance
    function createFishingGameContract() public onlyOwner {
        FishingGame game = new FishingGame();
        fishingGames.push(address(game));
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
        return fishingGames[fishingGames.length - 1];
    }

    //find the nftContracts address
    function getnewNFTAddress() public view returns (address) {
        return nftContracts[nftContracts.length - 1];
    }
}