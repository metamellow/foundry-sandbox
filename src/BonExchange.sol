/*
- add onlyOwner for emergency withdraw
- switch endBlock to require tokensLeft >= exchange amount else revert
- also add a startBlock var
- this will require an approvalo for transfer
- change mint to transfer tokens and also add the erc20 acceptance stuff from staking
- deploy bonv2 on polygon as place holder and burn that token on BRIDGE
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract bonExchange is Ownable {

  	IERC20 public bon;
  	IERC20 public bank;
  	uint256 public end;

  	constructor(
		address _bon,
		address _bank,
		uint256 _secondsTillEnd
		){
		bon = IERC20(_bon);
		bank = IERC20(_bank);
		end = block.timestamp + _secondsTillEnd;
  	}

  	event MigrateToBANK(address indexed user,uint256 amount);


// change burn to accept and hold; use the allowance approve transfer structure built for the NFTs


 	function exchangeToken(uint256 _amount) public {
    	require(block.timestamp < end, "too late");
    	uint256 tokenBalance = IERC20(bank).balanceOf(address(this));
		require(tokenBalance > _amount, "not enough in pool, check remaining contract balance");
		IERC20(bon).transferFrom(
      		address(msg.sender), 
      		0x000000000000000000000000000000000000dEaD, 
      		_amount);
    	bool success = IERC20(bank).transfer(msg.sender, _amount);
    	require(success == true, "transfer failed!");
    	emit MigrateToBANK(msg.sender,_amount);
 	}

	// onlyOwners
// add an only owner that BURNS any remaining BANK tokens after time limit

  	function changeBonAddr(address _newAddr) external onlyOwner{
    	bon = IERC20(_newAddr);
  	}

  	function changeBankAddr(address _newAddr) external onlyOwner{
    	bank = IERC20(_newAddr);
  	}

	function changeEndTime(uint _secondsTillEnd) external onlyOwner{
    	end = block.timestamp + _secondsTillEnd;
  	}

  	function closeExchangePool() external payable onlyOwner {
        uint256 tokenBalance = IERC20(bank).balanceOf(address(this));
        uint256 gasBalance = address(this).balance;
        if(tokenBalance > 0){
            bool success1 = IERC20(bank).transfer(msg.sender, tokenBalance);
            require(success1 == true, "transfer failed!");
        }
        if(gasBalance > 0){
            (bool success2,) = payable(msg.sender).call{value: gasBalance}("");
            require(success2 == true, "transfer failed!");
        }
  	}
}
