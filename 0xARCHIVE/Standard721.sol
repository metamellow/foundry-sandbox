// SPDX-License-Identifier: GNU-3.0
pragma solidity ^0.8.9;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-. ERC721 STANDARD NFT COLLECTION  .-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY REBEL LABS ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFT is ERC721, Ownable, ERC721Burnable{
    using Strings for uint256;
    uint256 public totalSupply;

    uint256 public walletMax;
    uint256 public mintPrice;
    address public paymentToken;

    string public baseUri = "ipfs://xxx/";
    string public baseExtension = ".json";

    mapping(address => uint256) private mintedPerWallet;

    event NewNFTMinted(address sender, uint256 tokenId);

    constructor(
        uint256 _walletMax,
        uint256 _mintPrice,
        address _paymentToken,
        address _receiver,
        uint256 _reserved,
        string memory _Name,
        string memory _Symbol
        ) ERC721(_Name, _Symbol) {
            for (uint256 i; i < _reserved; ) {
                _safeMint(_receiver, ++totalSupply);
                unchecked { ++i; }
            }
            paymentToken = _paymentToken;
            walletMax = _walletMax;
            mintPrice = _mintPrice;
    }

    // --- USER ACTIONS ---
    function mint() external payable{
        require(mintedPerWallet[msg.sender] < walletMax, "Already at wallet maximum");
        if(mintPrice == 0){
            mintedPerWallet[msg.sender] = mintedPerWallet[msg.sender] += 1;
            _safeMint(msg.sender, ++totalSupply);
        } else {
            if(paymentToken == address(0)){
                require(mintPrice <= msg.value, "Need more gas to mint");
            } else {
                // users must APPROVE before this
                IERC20(paymentToken).transferFrom(msg.sender, address(this), mintPrice);
            }
            mintedPerWallet[msg.sender] = mintedPerWallet[msg.sender] += 1;
            _safeMint(msg.sender, ++totalSupply);
        }
    }

    // --- DEV ACTIONS ---
    function devActions(
        bool _pullFunds, 
        uint256 _walletMax, 
        uint256 _mintPrice, 
        address _paymentToken
        ) external onlyOwner {
        walletMax = _walletMax;
        mintPrice = _mintPrice;
        paymentToken = _paymentToken;
        if(_pullFunds == true){
            uint256 erc20 = IERC20(_paymentToken).balanceOf(address(this));
            if(erc20 > 0){IERC20(_paymentToken).transfer(msg.sender, erc20);}
            uint256 gas = address(this).balance;
            if(gas > 0){payable(msg.sender).transfer(gas);}
        }
    }

    // --- NFT DETAILS ---
    function setBaseUri(string memory _baseUri) external onlyOwner {
        baseUri = _baseUri;
    }

	function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
 
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }
 
    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }
}