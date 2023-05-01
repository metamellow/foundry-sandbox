// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-. BANK OF NOWHERE $BON to $BANK EXCHANGE -.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

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

  	event MigrateToBANK(address indexed user, uint256 amountExchanged, uint newBankBalance);

 	function exchangeToken(uint256 _amount) public {
    	require(block.timestamp < end, "sorry exchange has ended");
    	uint256 tokenBalance = IERC20(bank).balanceOf(address(this));
		require(tokenBalance > _amount, "not enough in pool check contract balances");
		bool success1 = IERC20(bon).transferFrom(msg.sender, address(this), _amount);
        require(success1 == true, "transfer failed!");
    	bool success2 = IERC20(bank).transfer(msg.sender, _amount);
    	require(success2 == true, "transfer failed!");
        uint256 newBankBalance = IERC20(bank).balanceOf(address(msg.sender));
    	emit MigrateToBANK(msg.sender, _amount, newBankBalance);
 	}

	// onlyOwners

  	function changeBonAddr(address _newAddr) external onlyOwner{
    	bon = IERC20(_newAddr);
  	}

  	function changeBankAddr(address _newAddr) external onlyOwner{
    	bank = IERC20(_newAddr);
  	}

	function changeEndTime(uint _secondsTillEnd) external onlyOwner{
    	end = block.timestamp + _secondsTillEnd;
  	}

  	function pullBONtoBurn() external payable onlyOwner {
        uint256 bonBalance = IERC20(bon).balanceOf(address(this));
        require(bonBalance > 0, "no BON remaining");
		bool success1 = IERC20(bon).transfer(msg.sender, bonBalance);
        require(success1 == true, "transfer failed!");
			// burned on Polygon after unwrapping process
  	}
	
	function closeExchangePool() external payable onlyOwner {
        uint256 bankBalance = IERC20(bank).balanceOf(address(this));
		uint256 bonBalance = IERC20(bon).balanceOf(address(this));
        uint256 gasBalance = address(this).balance;
        if(bankBalance > 0){
            bool success1 = IERC20(bank).transfer(msg.sender, bankBalance);
            require(success1 == true, "transfer failed!");
			// burned on Modulus if not claimed
        }
		if(bonBalance > 0){
            bool success2 = IERC20(bon).transfer(msg.sender, bonBalance);
            require(success2 == true, "transfer failed!");
			// burned on Polygon after unwrapping process
        }
        if(gasBalance > 0){
            (bool success3,) = payable(msg.sender).call{value: gasBalance}("");
            require(success3 == true, "transfer failed!");
        }
  	}
}
