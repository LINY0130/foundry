// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

enum Rarity { 
    NOFISH,
    COMMON,
    UNCOMMON,
    RARE,
    SUPER_RARE,
    EPIC,
    LEGENDARY,
    MYTHICAL
}

contract FishingGame {

    uint256 public startTime;
    uint[8] private Prob_Without_Bait;
    uint[42] private Add_Prob;
    uint[3] private Bait;
    uint[8] public FinalCatchFish;

    constructor() {
        startTime = 0;
        //First compare it to the Prob_Without_Bait[0] to determine if caught a fish or not
        Prob_Without_Bait[0] = 0;   //No Bait Use: 0
        //If caught, use the array below to select the fish type
        Prob_Without_Bait[1] = 50;  //COMMON_PROB: Int = 50
        Prob_Without_Bait[2] = 25;  //UNCOMMON_PROB: Int = 25
        Prob_Without_Bait[3] = 12;  //RARE_PROB: Int = 12
        Prob_Without_Bait[4] = 6;   //SUPER_RARE_PROB: Int = 6
        Prob_Without_Bait[5] = 4;   //EPIC_PROB: Int = 4
        Prob_Without_Bait[6] = 2;   //LEGENDARY_PROB: Int = 2
        Prob_Without_Bait[7] = 1;    //MYTHICAL_PROB: Int = 1
        //use 10000,for Bait Influence Probabilities*10 and Diminishing factor(D)*10
        // common bait
        Add_Prob[0] = 100; Add_Prob[1] = 50; Add_Prob[2] = 20; Add_Prob[3] = 10; Add_Prob[4] = 5; Add_Prob[5] = 1;
        // uncommon bait
        Add_Prob[6] = 150; Add_Prob[7] = 70; Add_Prob[8] = 30; Add_Prob[9] = 15; Add_Prob[10] = 10; Add_Prob[11] = 2;
        // rare bait
        Add_Prob[12] = 200; Add_Prob[13] = 100; Add_Prob[14] = 50; Add_Prob[15] = 30; Add_Prob[16] = 20; Add_Prob[17] = 5;
        // super rare bait
        Add_Prob[18] = 250; Add_Prob[19] = 150; Add_Prob[20] = 80; Add_Prob[21] = 50; Add_Prob[22] = 30; Add_Prob[23] = 10;
        // epic bait
        Add_Prob[24] = 300; Add_Prob[25] = 200; Add_Prob[26] = 100; Add_Prob[27] = 70; Add_Prob[28] = 50; Add_Prob[29] = 20;
        // legendary bait
        Add_Prob[30] = 350; Add_Prob[31] = 250; Add_Prob[32] = 150; Add_Prob[33] = 100; Add_Prob[34] = 70; Add_Prob[35] = 30;
        // mythical bait
        Add_Prob[36] = 400; Add_Prob[37] = 300; Add_Prob[38] = 200; Add_Prob[39] = 150; Add_Prob[40] = 100; Add_Prob[41] = 50;
        Bait = [0,0,0];
    }

    //When user claim, call this function
    function Mint() public returns(uint8[8] memory){
        (bool FishSignal,) = checkFishTime();
        uint8[8] memory CatchFish = [0,0,0,0,0,0,0,0];
        FinalCatchFish = [0,0,0,0,0,0,0,0];
        if(FishSignal){
            uint i = 0;
            while ( i < 8 ){
                CatchFish[i] = 0;
                i += 1;
            }
            //users do not use bait
            if((Bait[0] == 0)&&(Bait[1] == 0)&&(Bait[2] == 0)){
                //random number 0 or 1，for no bait used to determine if caught a fish or not；
                uint randomnumber1 = _randomNumber(0, 2);
                if( randomnumber1 == 0 ){
                    //do nothing, all stored 0;
                }
                else if( randomnumber1 == 1 ){
                    CatchFish = calculateProbWithoutBait();
                } 
            }
            // users use bait
            else if(Bait[0] != 0){
                CatchFish = calculateProbWithBait();
            }
        }
        FinalCatchFish = CatchFish;
        return CatchFish;
    }

    //When user passes the bait, call this function to save Bait and StartTime
    function passBait(uint species0, uint species1, uint species2) public {
        Bait = [species0, species1, species2];
        setStartTime(); 
    }
    
    function setStartTime() public {
        startTime = block.timestamp;
    }

    function checkFishTime() private view returns(bool, bool) {
        uint256 currentTime = block.timestamp;
        uint256 randomNumber = _randomNumber(7200, 14400 + 1);
        bool FishSignal = false;
        bool FishLost = false;

        if ((randomNumber < currentTime - startTime) && (currentTime - startTime < randomNumber + 10800)) {
            FishSignal = true;
        } else if (randomNumber + 10800 - 1 < currentTime - startTime) {
            FishLost = true;
        }

        return (FishSignal, FishLost);
    }

    // Calculate the Prob_With_Bait and store in the array
    // 10*P_T = 10*P_1 + 10*P_2*(1-D) + 10*P_3*(1-2D)
    // Use Diminishing factor D*10

    function calculateProbWithoutBait() private view returns(uint8[8] memory){
        uint256 randomNumber100 = _randomNumber(0, 100 + 1);
        uint8[8] memory CatchFish = [0, 0, 0, 0, 0, 0, 0, 0];
        if     ( (0 < randomNumber100) && (randomNumber100 < 2) )    { CatchFish[7] = 1; }
        else if( (1 < randomNumber100) && (randomNumber100 < 4) )    { CatchFish[6] = 1; }
        else if( (3 < randomNumber100) && (randomNumber100 < 8) )    { CatchFish[5] = 1; }
        else if( (7 < randomNumber100) && (randomNumber100 < 14) )   { CatchFish[4] = 1; }
        else if( (13 < randomNumber100) && (randomNumber100 < 26) )  { CatchFish[3] = 1; }
        else if( (25 < randomNumber100) && (randomNumber100 < 51) )  { CatchFish[2] = 1; }
        else if( (50 < randomNumber100) && (randomNumber100 < 101) ) { CatchFish[1] = 1; }
        return CatchFish;
    }

    function calculateProbWithBait() private view returns(uint8[8] memory){
        uint[7] memory Prob_With_Bait;
        uint8[8] memory CatchFish = [0, 0, 0, 0, 0, 0, 0, 0];
        uint D = 2;
        // 1 <= x,y,z <= 7
        uint x = Bait[0];
        uint y = Bait[1];
        uint z = Bait[2];
        // j represents prob of all caught fish type
        // j = 2 means start from uncommom type
        uint j = 2;
        while( j<8 ){
            uint a = Prob_Without_Bait[j];
            uint b = Add_Prob[(x-1)*6 + j - 2];
            uint c = Add_Prob[(y-1)*6 + j - 2];
            uint d = Add_Prob[(z-1)*6 + j - 2];
            uint e = a*10 + b*10 + c*(10 - D) + d*(10 - 2*D);
            Prob_With_Bait[j] = e;
            j +=1;
        }
        // let totalProbSum: Int = 0;
        // for (int t = 2; t < 8; t++){ totalProbSum += self.Prob_With_Bait.get(t); }
        // self.Prob_With_Bait.set(0, 10000 - totalProbSum);

        uint256 Uncommon = Prob_With_Bait[1] + Prob_With_Bait[2] + Prob_With_Bait[3] + Prob_With_Bait[4] + Prob_With_Bait[5] + Prob_With_Bait[6];
        uint256 Rare = Prob_With_Bait[2] + Prob_With_Bait[3] + Prob_With_Bait[4] + Prob_With_Bait[5] + Prob_With_Bait[6];
        uint256 Super_Rare = Prob_With_Bait[3] + Prob_With_Bait[4] + Prob_With_Bait[5] + Prob_With_Bait[6];
        uint256 Epic = Prob_With_Bait[4] + Prob_With_Bait[5] + Prob_With_Bait[6];
        uint256 Legendary = Prob_With_Bait[5] + Prob_With_Bait[6];
        uint256 Mythical = Prob_With_Bait[6];

        //random number 1-10000，for use bait to determine if caught a fish or not；
        uint256 randomnumber10000 = _randomNumber(1, 10001);

        if      ( (0 < randomnumber10000) && (randomnumber10000 < Mythical) )                { CatchFish[7] = 1; }
        else if ( (Mythical-1 < randomnumber10000) && (randomnumber10000 < Legendary) )      { CatchFish[6] = 1; }
        else if ( (Legendary-1 < randomnumber10000) && (randomnumber10000 < Epic) )          { CatchFish[5] = 1; }
        else if ( (Epic-1 < randomnumber10000) && (randomnumber10000 < Super_Rare) )         { CatchFish[4] = 1; }
        else if ( (Super_Rare-1 < randomnumber10000) && (randomnumber10000 < Rare) )         { CatchFish[3] = 1; }
        else if ( (Rare-1 < randomnumber10000) && (randomnumber10000 < Uncommon) )           { CatchFish[2] = 1; }
        else if ( (Uncommon-1 < randomnumber10000) && (randomnumber10000 < 10001) )          { CatchFish[1] = 1; }

        return CatchFish;
    }
    // Consider if use Chainlink VRF to generate random number
    function _randomNumber(uint256 min, uint256 max) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, msg.sender))) % (max - min) + min;
    }

    //Outside Check Fish Result Information
    function getCaughtFishRarity() public view returns (Rarity) {
        if (FinalCatchFish[0] == 1){
            return Rarity.NOFISH;
        } else if (FinalCatchFish[1] == 1){
            return Rarity.COMMON;
        } else if (FinalCatchFish[2] == 1){
            return Rarity.UNCOMMON;
        } else if (FinalCatchFish[3] == 1){
            return Rarity.RARE;
        } else if (FinalCatchFish[4] == 1){
            return Rarity.SUPER_RARE;
        } else if (FinalCatchFish[5] == 1){
            return Rarity.EPIC;
        } else if (FinalCatchFish[6] == 1){
            return Rarity.LEGENDARY;
        } else if (FinalCatchFish[7] == 1){
            return Rarity.MYTHICAL;
        } else return Rarity.NOFISH;
    }
}

