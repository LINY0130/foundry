// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFT.sol";
import "./FishingGame.sol";

contract Factory is Ownable {
    address[] public nftContracts;
    address[] public fishingGames;
    address public addressFishingGames;
    address public addressNftContract;

    constructor() Ownable(msg.sender) {}

    // Function to create a new NFT contract instance
    function createNFTContract(string memory name, string memory symbol, string memory uri) public onlyOwner {
        NFT nft = new NFT(addressFishingGames, name, symbol, uri);
        nftContracts.push(address(nft));
        addressNftContract = address(nft);
    }

    // Function to create a new FishingGame contract instance
    function createFishingGameContract() public onlyOwner {
        FishingGame game = new FishingGame(addressNftContract);
        fishingGames.push(address(game));
        addressFishingGames = address(game);
    }

}