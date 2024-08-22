// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {FishingGame} from "../src/FishingGame.sol";

contract FishingTest is Test {
    FishingGame public fishingGame;
    uint[] public setSpecies;
    
    //考虑写两个测试，一个pass000，另一个pass有值的。
    function setUp() public {
        fishingGame = new FishingGame(0x0000000000000000000000000000000000000000);
        getBait();
        fishingGame.passBait(setSpecies[0], setSpecies[1], setSpecies[2]);
    }

    function _randomNumber(uint256 min, uint256 max) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp))) % (max - min) + min;
    }

    function getBait() internal {
        uint[] memory species;
        species[0] = _randomNumber(0,8);
        species[1] = _randomNumber(0,8);
        species[2] = _randomNumber(0,8);
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


    // function test_Increment() public {
    //     counter.increment();
    //     assertEq(counter.number(), 1);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }


}
