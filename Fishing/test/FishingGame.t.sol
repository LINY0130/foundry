// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FishingGame} from "../src/FishingGame.sol";
import {NFT} from "../src/NFT.sol";
import "../src//Factory.sol";

contract FishingGameTest is Test {
    FishingGame public fishingGame;
    NFT public nftContract;
    uint[] public setSpecies;
    address public testowner = address(this);
    
    function setUp() public {
        Factory factory = new Factory(testowner);
        console.log("Owner address: ", factory.owner());
        assertEq(factory.owner(), address(this), "Factory owner should be the same as the test owner");

        factory.createNFTContract("MyNFT", "MNT", "");
        factory.createFishingGameContract();

        address nftAddress = factory.getnewNFTAddress();
        address gameAddress = factory.getnewFishingGameAddress();

        nftContract = NFT(nftAddress);
        fishingGame = FishingGame(gameAddress);
    }

    function _randomNumber(uint256 min, uint256 max) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp))) % (max - min) + min;
    }

    function getBait() internal {
        uint[] memory species;
        species[0] = _randomNumber(1,8);
        species[1] = _randomNumber(1,8);
        species[2] = _randomNumber(1,8);
        setSpecies = arrange(species);
    }
    
    function arrange(uint[] memory arr) public pure returns (uint[] memory) {
        uint n = arr.length;
        bool swapped;
        uint temp;
        for (uint i = 0; i < n - 1; i++) {
            swapped = false;
            for (uint j = 0; j < n - i - 1; j++) {
                if (arr[j] > arr[j + 1]) {
                    // Swap arr[j] and arr[j + 1]
                    temp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = temp;
                    swapped = true;
                }
            }
            if (!swapped) break;
        }
        return arr;
    }

    function test_UserCatchFishWithBait() public {
        // use bait;
        bool caughtFish = false;
        getBait();
        fishingGame.passBait(setSpecies[0], setSpecies[1], setSpecies[2]);
        uint8[8] memory catchFish = fishingGame.UserCatchFish();
        for (uint8 i = 1; i < 8; i++) {
            if (catchFish[i] == 1) {
                caughtFish = true;
                break;
            }
        }
        bool FishSignal;
        bool Fishlost;
        //time pass less than 7200 , nofish caught
        vm.warp(block.timestamp + 7198); 
        (FishSignal, Fishlost) = fishingGame._checkFishTime();
        assertEq(caughtFish, false, "Should not catch any fish because no enough time");
        assertEq(FishSignal, false, "Should not catch any fish because no enough time");
        assertEq(Fishlost, false, "No fish lost");
        assertEq(nftContract.balanceOf(address(this)), 0, "NFT should not be minted upon not enough time");
        //time pass over 14400 , fish must caught
        vm.warp(block.timestamp + 14402);
        (FishSignal, Fishlost) = fishingGame._checkFishTime();
        assertEq(caughtFish, true, "Should catch at least one fish with bait");
        assertEq(FishSignal, true, "Should catch at least one fish with bait");
        assertEq(Fishlost, false, "No fish lost");
        assertEq(nftContract.balanceOf(address(this)), 1, "NFT should be minted upon catching a fish");
        //time pass over 25200 , fish must lost
        vm.warp(block.timestamp + 25203);
        (FishSignal, Fishlost) = fishingGame._checkFishTime();
        assertEq(caughtFish, false, "Over time and fish lost");
        assertEq(FishSignal, false, "Over time and fish lost");
        assertEq(Fishlost, true, "Over time and fish lost");
        assertEq(nftContract.balanceOf(address(this)), 0, "NFT should not be minted upon not enough time");
    }

    function test_UserCatchFishWithoutBait() public {
        // no bait use
        fishingGame.passBait(0,0,0);

        uint256 trials = 10000; // 1000times
        uint256 caughtFishCount = 0; // times for successfully catching a fish

        for (uint256 i = 0; i < trials; i++) {
            uint8[8] memory catchFish = fishingGame.UserCatchFish();

            for (uint8 j = 1; j < 8; j++) {
                if (catchFish[j] == 1) {
                    caughtFishCount++;
                    break;
                }
            }
        }

        uint256 caughtFishPercentage = caughtFishCount * 100 / trials;

        // Verify that the percentage of fish caught is close to 50 per cent
        assertEq(caughtFishPercentage >= 45 && caughtFishPercentage <= 55, true, "Caught fish percentage should be around 50%");
    }

}