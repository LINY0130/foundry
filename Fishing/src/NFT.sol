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

// enum Rarity { 
    // NOFISH,      0
//     COMMON,      1
//     UNCOMMON,    2
//     RARE,        3
//     SUPER_RARE,  4
//     EPIC,        5
//     LEGENDARY,   6
//     MYTHICAL     7
// }

contract NFT is ERC721, Ownable {

    FishingGame public fishingGame;
    using Strings for uint256;

    mapping(address => uint8[8]) public tokenRarities;

    string public baseURI;
    uint256 public currentTokenId;
    // address public OwnerAddress;
    address public UserAddress;
    // uint256 public constant TOTAL_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0.08 ether;

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
        UserAddress = recipient;
        Rarity fishRarity = fishingGame.getCaughtFishRarity();
        tokenRarities[recipient][uint(fishRarity)] += 1;          
        require(fishRarity != Rarity.NOFISH, "NFT: No fish caught");

        uint256 newTokenId = ++currentTokenId;
        // if (newTokenId > TOTAL_SUPPLY) {
        //     revert MaxSupply();
        // }

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

    function getFishStorage() public view returns (uint8[8] memory){
        return (tokenRarities[UserAddress]);
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
