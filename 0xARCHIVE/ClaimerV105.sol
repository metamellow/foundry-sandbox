// SPDX-License-Identifier: GNU-3.0
pragma solidity ^0.8.19;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.  NFT TOKEN TIMER CLAIMER  V1.06 .-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY REBEL LABS ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Claimer is Ownable {
    IERC20 public token;
    IERC721 public nfts;
    address private taxWallet;
    address public burnWallet;
    uint256 private taxRate;
    uint256 public burnRate;
    uint256 public claimRate;
    uint256 public claimPace;
    bool public taxOn;

    mapping(uint256 => uint256) public lastClaimTime;
    mapping(address => uint256) public totalClaimed;

    event ClaimDetails (uint256 claimAmount);
    
    constructor(
        address _tokenAddress, 
        address _nftsAddress, 
        address _taxWallet,
        address _burnWallet,
        uint256 _taxRate, 
        uint256 _burnRate, 
        uint256 _claimPace, 
        uint256 _claimRate, 
        bool _taxOn 
        ) {
        /* "0x47E53f0Ddf71210F2C45dc832732aA188F78AA4f", erc20 */           token = IERC20(_tokenAddress);
        /* "0x88421bc1C0734048f80639BE6EF367f634c33804", erc721 */          nfts = IERC721(_nftsAddress);
        /* "0xEF538a11FB3441eB9b5444654a8075cd63afDdfF" or address(0) */    taxWallet = _taxWallet;
        /* "0x000000000000000000000000000000000000dEaD" or address(0) */    burnWallet = _burnWallet;
        /* "1", 0.1% */             taxRate = _taxRate;
        /* "2", 0.2% */             burnRate = _burnRate;
        /* "604800", 7 day */       claimPace = _claimPace;
        /* "10", 1% */              claimRate = _claimRate;
        /* "true" */                taxOn = _taxOn;
    }

    function claim(uint256 _tokenID) external {
        require(nfts.ownerOf(_tokenID) == msg.sender, "You do not own that NFT");
        if(lastClaimTime[_tokenID] != 0){
            require(lastClaimTime[_tokenID] + claimPace <= block.timestamp, "Time passed in not enough");
        }
        uint256 availableTokens = token.balanceOf(address(this));
        uint256 claimAmount = availableTokens * claimRate / 1000;

        lastClaimTime[_tokenID] = block.timestamp;
        totalClaimed[msg.sender] += claimAmount;

        if(taxOn == true){
            uint256 burnAmount = claimAmount * burnRate / 1000;
            uint256 taxAmount = claimAmount * taxRate / 1000;

            if(burnWallet == address(0)){ERC20Burnable(address(token)).burn(burnAmount);}
            else{token.transfer(address(burnWallet), burnAmount);}
            if(taxWallet != address(0)){token.transfer(address(taxWallet), taxAmount);}

            uint userReward = claimAmount - burnAmount - taxAmount;
            token.transfer(msg.sender, userReward);
        } else {
            token.transfer(msg.sender, claimAmount);
        }

        emit ClaimDetails(claimAmount);
    }

    function updateClaim(
        address _tokenAddress, 
        address _nftAddress,
        uint256 _claimRate,
        uint256 _claimPace
        ) public onlyOwner {
        require(_claimRate > 0 && _claimRate < 1000, "Invalid claimRate range");
        require(_claimPace > 0, "Invalid claimPace range");
        claimRate = _claimRate;
        claimPace = _claimPace;
        token = IERC20(_tokenAddress);
        nfts = IERC721(_nftAddress);
    }

    function updateTax(
        address _tqxWallet, 
        address _burnWallet, 
        uint256 _taxRate, 
        uint256 _burnRate, 
        bool _trueFalse
        ) public onlyOwner{
        require(_taxRate > 0 && _taxRate < 1000, "Invalid taxRate range");
        require(_burnRate > 0 && _burnRate < 1000, "Invalid burnRate range");
        taxWallet = _taxWallet;
        burnWallet = _burnWallet;
        taxRate = _taxRate;
        burnRate = _burnRate;
        taxOn = _trueFalse;
    }

    function withdrawBalances(address _tokenAddress) public onlyOwner{
        IERC20 tokenAddress = IERC20(_tokenAddress);
        uint256 availableERC = tokenAddress.balanceOf(address(this));
        uint256 availableGas = address(this).balance;
        if(availableERC > 0){tokenAddress.transfer(msg.sender, availableERC);}
        if(availableGas > 0){payable(msg.sender).transfer(availableGas);}
    }
}
