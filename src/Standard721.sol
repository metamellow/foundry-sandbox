// SPDX-License-Identifier: GNU
pragma solidity ^0.8.9;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-. MODULUSVERSE 3D NFT COLLECTION  .-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY REBEL LABS ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721, Ownable{
    using Strings for uint256;

    uint256 public totalSupply;
    uint256 private reserved;

    string public baseUri = "ipfs://xxx/";
    string public baseExtension = ".json";

    mapping(address => uint256) private mintedPerWallet;

    event NewNFTMinted(address sender, uint256 tokenId);

    constructor(
        address _receiver,
        uint256 _reserved,
        string memory _Name,
        string memory _Symbol
        ) ERC721(_Name, _Symbol) {
            for (uint256 i; i < _reserved; ) {
                _safeMint(_receiver, ++totalSupply);
                unchecked { ++i; }
            }
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
}