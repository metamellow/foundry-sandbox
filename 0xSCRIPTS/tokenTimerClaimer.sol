// SPDX-License-Identifier: GNU-3.0
pragma solidity ^0.8.0;


/*
- need to add an NFT checker owner blocker
- make one of the following for a tax and a burn (if on):
        if(burnOn == true){
        uint burnAmount = rewards * brnRate / 10000;
        try ERC20Burnable(tokenAddr).burn(burnAmount){}
        catch {IERC20(tokenAddr).transfer(address(0), burnAmount);}

        uint userReward = rewards - (burnAmount);
        bool success = IERC20(tokenAddr).transfer(msg.sender, userReward);
        require(success == true, "transfer failed!");

        emit RewardsEmit(msg.sender, userBalance, userReward);
    } else {
        bool success = IERC20(tokenAddr).transfer(msg.sender, rewards);
        require(success == true, "transfer failed!");

        emit RewardsEmit(msg.sender, userBalance, rewards);
    }
- I can make a QRNG call internally and place the result in a secret internal box and then that is the key
*/



/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.  BON TOKEN TIMER CLAIMER  V1.02 .-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY REBEL LABS ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Claimer is Ownable {
    IERC20 public token;
    uint256 public claimRate;
    uint256 public claimPace;
    uint256 public claimKey;

    mapping(address => uint256) public lastClaimTime;
    mapping(address => uint256) public totalClaimed;

    event ClaimDetails (uint256 claimAmount);
    
    constructor(address _tokenAddress, uint256 _claimRate, uint256 _claimPace, uint256 _claimKey) {
        token = IERC20(_tokenAddress);          // "0x123", erc20 token addr
        claimRate = _claimRate;                 // "10"/1000 = 1%
        claimPace = _claimPace;                 // "604800", 7 days
        claimKey = _claimKey;                   // "420", can be anything, RNG after 1st
    }

    function claim(uint256 _claimKey) external {
        require(_claimKey >= 1 && _claimKey <= 1000, "Invalid key value");
        require(_claimKey == claimKey, "Invalid key value");
        require(lastClaimTime[msg.sender] + claimPace <= block.timestamp, "Time passed in not enough");

        uint256 availableTokens = token.balanceOf(address(this));
        uint256 claimAmount = availableTokens * claimRate / 1000;
        require(claimAmount <= availableTokens, "Insufficient tokens in the pool");

        lastClaimTime[msg.sender] = block.timestamp;
        totalClaimed[msg.sender] += claimAmount;

        token.transfer(msg.sender, claimAmount);
        claimKey = _updateClaimKey();

        emit ClaimDetails(claimAmount);
    }

    function _updateClaimKey() internal view returns(uint256 _newKey){
        // better randomization logic added here in the future
        _newKey = uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp))) % 1000 + 1;
        return _newKey;
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

    function withdrawTokens(address _tokenAddress) public onlyOwner{
        IERC20 tokenAddress = IERC20(_tokenAddress);
        uint256 availableTokens = tokenAddress.balanceOf(address(this));
        tokenAddress.transfer(msg.sender, availableTokens);
    }
}