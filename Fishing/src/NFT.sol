// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "../lib/solmate/src/tokens/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";
import "./FishingGame.sol";
import "./Factory.sol";

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

contract NFT is ERC721, Ownable, AccessControl {

    FishingGame public fishingGame;
    Factory public factory;
    using Strings for uint256;

    //every user has he's fish types;
    mapping(address => uint8[8]) public tokenRarities;
    //every fish has a rarity;
    mapping (uint => Rarity) public NftRarity;

    string public baseURI;
    uint256 public currentTokenId;
    // address public OwnerAddress;
    address public UserAddress;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // uint256 public constant TOTAL_SUPPLY = 10_000;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        address _factoryAddress
    ) ERC721(_name, _symbol) Ownable(msg.sender) {
        baseURI = _baseURI;
        factory = Factory(_factoryAddress);//factory address
        address fishingGameAddress = factory.getnewNFTAddress();
        fishingGame = FishingGame(fishingGameAddress);
    }

    function grantMinterRole(address account) external onlyOwner {
        grantRole(MINTER_ROLE, account);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function mintToken(address recipient) public payable returns (uint256) {
        require(hasRole(MINTER_ROLE, msg.sender), "Only admin contract or fish contract can mint." );
        UserAddress = recipient;
        Rarity fishRarity = fishingGame.getCaughtFishRarity();
        tokenRarities[recipient][uint(fishRarity)] += 1;          
        require(fishRarity != Rarity.NOFISH, "NFT: No fish caught");

        uint256 newTokenId = ++currentTokenId;
        NftRarity[newTokenId] = fishingGame.getCaughtFishRarity();
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
