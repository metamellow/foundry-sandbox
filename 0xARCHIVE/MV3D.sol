// SPDX-License-Identifier: GNU
pragma solidity ^0.8.9;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-. MODULUSVERSE 3D NFT COLLECTION  .-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY METAMELLOW ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFT is ERC721, Ownable{
    using Strings for uint256;

    address public erc20contract;
    uint256 public erc20Price; 
    uint256 public gasPrice; 
    uint256 public maxTokens;
    uint256 public maxMintAmount; 
    uint256 public totalSupply;
    bool public isSaleActive;

    string public baseUri = "ipfs://bafybeibczm3tlfrriimzkhneoch4btord2ojiw4vnjrn7qtifmchcmkfci/";
    string public baseExtension = ".json";

    mapping(address => uint256) private mintedPerWallet;

    event NewNFTMinted(address sender, uint256 tokenId);

    constructor(
        address[] memory _addresses,    // ["",""]
        address _erc20contract,         // 0xc2132D05D31c914a87C6611C10748AEb04B58e8F // USDT
        uint256 _erc20Price,            // 50000000000000000000 // 50 ERC20 token
        uint256 _gasPrice,              // 1000000000000000 // 0.001 gas token
        uint256 _maxTokens,             // 380
        uint256 _maxMintAmount,         // 100
        bool _isSaleActive,             // false
        string memory _Name,            // Modulusverse 3D
        string memory _Symbol           // MV3D
        ) ERC721(_Name, _Symbol) {
            erc20contract = _erc20contract;
            erc20Price = _erc20Price;
            gasPrice = _gasPrice;
            maxTokens = _maxTokens;
            maxMintAmount = _maxMintAmount;
            isSaleActive = _isSaleActive;

            uint256 length = _addresses.length;
            for (uint256 i; i < length; ) {
                _safeMint(_addresses[i], ++totalSupply);
                unchecked { ++i; }
            }
    }

    // Public Functions
    function mint(uint256 _numTokens) external payable {
        require(isSaleActive, "The sale is paused.");
        require(_numTokens <= maxMintAmount, "Cannot mint that many in one txn");
        require(mintedPerWallet[msg.sender] + _numTokens <= maxMintAmount, "Cannot mint that many total in wallet");
        uint256 curTotalSupply = totalSupply;
        require(curTotalSupply + _numTokens <= maxTokens, "Exceeds total supply");
        require(_numTokens * gasPrice <= msg.value, "Insufficient funds");
        uint256 erc20Cost = erc20Price * _numTokens;
        // users must APPROVE staking contract to use their erc20 before v-this-v can work
        bool success = IERC20(erc20contract).transferFrom(msg.sender, address(this), erc20Cost);
        require(success == true, "transfer failed!");
        for(uint256 i = 1; i <= _numTokens; ++i) {
            _safeMint(msg.sender, curTotalSupply + i);
        }
        mintedPerWallet[msg.sender] += _numTokens;
        totalSupply += _numTokens;
        emit NewNFTMinted(msg.sender, totalSupply);
    }

    // Owner-only functions
    function flipSaleState() external onlyOwner {
        isSaleActive = !isSaleActive;
    }

    function setErc20Contract(address _contractAddress) external onlyOwner {
        erc20contract = _contractAddress;
    }

    function setGasPrice(uint256 _price) external onlyOwner {
        gasPrice = _price;
    }

    function setERC20Price(uint256 _price) external onlyOwner {
        erc20Price = _price;
    }

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

    function withdrawAll(address address_100) external payable onlyOwner {
        uint256 erc20Balance = IERC20(erc20contract).balanceOf(address(this));
        uint256 gasBalance = address(this).balance;
        if(erc20Balance > 0){
            uint256 hundred_percent_ERC20 = erc20Balance * 100 / 100;
            bool transferAOne = IERC20(erc20contract).transfer(address_100, hundred_percent_ERC20);
            require(transferAOne, "transfer failed!");
        }
        if(gasBalance > 0){
            uint256 hundred_percent_Gas = gasBalance * 100 / 100;
            ( bool transferBOne, ) = payable(address_100).call{value: hundred_percent_Gas}("");
            require(transferBOne, "Transfer failed.");
        }
    }
}