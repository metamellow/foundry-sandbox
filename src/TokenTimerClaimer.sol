// SPDX-License-Identifier: GNU-3.0
pragma solidity ^0.8.0;


/*

*/



/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.  NFT TOKEN TIMER CLAIMER  V1.02 .-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY REBEL LABS ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Claimer is Ownable {
    IERC20 public token;
    IERC721 public nfts;
    uint256 public claimPace;
    uint256 public claimRate;
    uint256 public burnRate;
    bool public burnOn;

    mapping(uint256 => uint256) public lastClaimTime;
    mapping(address => uint256) public totalClaimed;

    event ClaimDetails (uint256 claimAmount);
    
    constructor(address _tokenAddress, address _nftAddress, uint256 _claimPace, uint256 _claimRate) {
        token = IERC20(_tokenAddress);      // "0x123", erc20 token addr
        nfts = IERC721(_nftAddress);        // "0x123", erc721 nft addr
        claimPace = _claimPace;             // "604800", 7 day
        claimRate = _claimRate;             // "5", 0.5%
    }

    function claim(uint256 _tokenID) external {
        require(nfts.ownerOf(_tokenID) == msg.sender, "You do not own that NFT");
        require(lastClaimTime[_tokenID] + claimPace <= block.timestamp, "Time passed in not enough");

        uint256 availableTokens = token.balanceOf(address(this));
        uint256 claimAmount = availableTokens * claimRate / 1000;
        require(claimAmount <= availableTokens, "Insufficient tokens in the pool");

        lastClaimTime[_tokenID] = block.timestamp;
        totalClaimed[msg.sender] += claimAmount;












        if(burnOn == true){
            uint burnAmount = claimAmount * burnRate / 1000;
            try ERC20Burnable(tokenAddr).burn(burnAmount){}
            catch {IERC20(tokenAddr).transfer(address(0), burnAmount);}

            uint userReward = claimAmount - (burnAmount);
            bool success = IERC20(tokenAddr).transfer(msg.sender, userReward);
            require(success == true, "transfer failed!");

            emit RewardsEmit(msg.sender, userBalance, userReward);
        } else {
            bool success = IERC20(tokenAddr).transfer(msg.sender, claimAmount);
            require(success == true, "transfer failed!");

            emit RewardsEmit(msg.sender, userBalance, claimAmount);
        }














        token.transfer(msg.sender, claimAmount);

        emit ClaimDetails(claimAmount);
    }

    function updateTokenAddress(address _tokenAddress) public onlyOwner{
        token = IERC20(_tokenAddress);
    }

    function updateClaimRate(uint256 _claimRate) public onlyOwner{
        require(_claimRate > 0 && _claimRate < 1000, "Invalid claimRate range");
        claimRate = _claimRate;
    }

    function updateClaimPace(uint256 _claimPace) public onlyOwner{
        require(_claimPace > 0, "Invalid claimPace range");
        claimPace = _claimPace;
    }

    function updateBurn(uint256 _burnRate, bool _trueFalse) public onlyOwner{
        require(_burnRate > 0 && _burnRate < 1000, "Invalid burnRate range");
        burnRate = _burnRate;
        burnOn = _trueFalse;
    }

    function withdrawTokens(address _tokenAddress) public onlyOwner{
        IERC20 tokenAddress = IERC20(_tokenAddress);
        uint256 availableTokens = tokenAddress.balanceOf(address(this));
        tokenAddress.transfer(msg.sender, availableTokens);
    }
}