// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.10;

import "../lib/solmate/src/tokens/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./FishingGame.sol";

error MintPriceNotPaid();
error MaxSupply();
error NonExistentTokenURI();
error WithdrawTransfer();
error NoFishCaught();

// enum Rarity { 
    // NOFISH,
//     COMMON,
//     UNCOMMON,
//     RARE,
//     SUPER_RARE,
//     EPIC,
//     LEGENDARY,
//     MYTHICAL
// }

contract NFT is ERC721, Ownable {

    FishingGame public fishingGame;
    using Strings for uint256;

    mapping(uint256 => Rarity) private tokenRarities;

    string public baseURI;
    uint256 public currentTokenId;
    address public OwnerAdress;
    // uint256 public constant TOTAL_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0.08 ether;
    uint256 private Common_Counter = 0;
    uint256 private Uncommon_Counter = 0;
    uint256 private Rare_Counter = 0;
    uint256 private Super_Rare_Counter = 0;
    uint256 private Epic_Counter = 0;
    uint256 private Legendary_Counter = 0;
    uint256 private Mythical_Counter = 0;

    constructor(
        address _fishingGameAddress,
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        fishingGame = FishingGame(_fishingGameAddress);
        baseURI = _baseURI;
    }

    function mintToken(address recipient) public payable returns (uint256) {
        if (msg.value != MINT_PRICE) {
            revert MintPriceNotPaid();
        }
        tokenRarities[currentTokenId] = fishingGame.getCaughtFishRarity();
        if (tokenRarities[currentTokenId] == Rarity.NOFISH){
            revert NoFishCaught();
        }
        else if (tokenRarities[currentTokenId] == Rarity.COMMON){
            Common_Counter += 1;
        }
        else if (tokenRarities[currentTokenId] == Rarity.UNCOMMON){
            Uncommon_Counter += 1;
        }
        else if (tokenRarities[currentTokenId] == Rarity.RARE){
            Rare_Counter += 1;
        }
        else if (tokenRarities[currentTokenId] == Rarity.SUPER_RARE){
            Super_Rare_Counter += 1;
        }
        else if (tokenRarities[currentTokenId] == Rarity.EPIC){
            Epic_Counter += 1;
        }
        else if (tokenRarities[currentTokenId] == Rarity.LEGENDARY){
            Legendary_Counter += 1;
        }
        else if (tokenRarities[currentTokenId] == Rarity.MYTHICAL){
            Mythical_Counter += 1;
        }
        uint256 newTokenId = ++currentTokenId;
        // if (newTokenId > TOTAL_SUPPLY) {
        //     revert MaxSupply();
        // }
        currentTokenId = newTokenId;
        _safeMint(recipient, newTokenId);
        return newTokenId;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert NonExistentTokenURI();
        }
        return
                bytes(baseURI).length > 0
                    ? string(abi.encodePacked(baseURI, tokenId.toString()))
                    : "";
    }

    function getFishStorage() public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256){
        return (Common_Counter, Uncommon_Counter, Rare_Counter, Super_Rare_Counter, Epic_Counter, Legendary_Counter, Mythical_Counter);
    }

    function withdrawPayments(address payable payee) external onlyOwner {
        if (address(this).balance == 0) {
            revert WithdrawTransfer();
        }

        payable(payee).transfer(address(this).balance);
    }

    function _checkOwner() internal view override {
        require(msg.sender == owner(), "Ownable: caller is not the owner");
    }
}
