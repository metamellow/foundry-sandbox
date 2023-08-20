// SPDX-License-Identifier: GNU-3.0
pragma solidity ^0.8.9;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-. ERC721 STANDARD NFT COLLECTION  .-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY REBEL LABS ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721, Ownable{
    using Strings for uint256;

    uint256 public totalSupply;
    bool public freeMintSwitch;

    string public baseUri = "ipfs://bafybeifvuftc456ml5yj6crrvckklevddnipizzeb6op7prdjmauefsggu/";
    string public baseExtension = ".json";

    mapping(address => uint256) private mintedPerWallet;

    event NewNFTMinted(address sender, uint256 tokenId);

    constructor(
        address _receiver,
        uint256 _reserved,
        string memory _Name,
        string memory _Symbol,
        bool _freeMintSwitch
        ) ERC721(_Name, _Symbol) {
            for (uint256 i; i < _reserved; ) {
                _safeMint(_receiver, ++totalSupply);
                unchecked { ++i; }
            }

            freeMintSwitch = _freeMintSwitch;
    }

    function freeMint() external {
        _safeMint(msg.sender, ++totalSupply);
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