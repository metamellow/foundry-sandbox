// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-. BANK OF NOWHERE $BANK to $BON EXCHANGE -.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract bankExchange is Ownable {

  	IERC20 public bank;
  	IERC20 public bon;
  	uint256 public end;
	uint256 public tax;
	address public taxHolder;

  	constructor(
		address _bank,
		address _bon,
		uint256 _secondsTillEnd,
		uint256 _tax,
		address _taxHolder
		){
		bank = IERC20(_bank);
		bon = IERC20(_bon);
		end = block.timestamp + _secondsTillEnd;
		tax = _tax; //40 = 4%
		taxHolder = _taxHolder;
  	}

  	event MigrateToBON(address indexed user, uint256 amountExchanged, uint newBonBalance);

 	function exchangeToken(uint256 _amount) public {
    	require(block.timestamp < end, "sorry exchange has ended");
    	uint256 tokenBalance = IERC20(bon).balanceOf(address(this));
		require(tokenBalance > _amount, "not enough in pool check contract balances");
		bool success1 = IERC20(bank).transferFrom(msg.sender, address(this), _amount);
        require(success1 == true, "transfer failed!");

		uint256 taxAmount = (_amount * tax) / 1000;
		bool success2 = IERC20(bon).transfer(taxHolder, taxAmount);
    	require(success2 == true, "transfer failed!");

    	bool success3 = IERC20(bon).transfer(msg.sender, (_amount - taxAmount));
    	require(success3 == true, "transfer failed!");
        uint256 newBonBalance = IERC20(bon).balanceOf(address(msg.sender));
    	emit MigrateToBON(msg.sender, _amount, newBonBalance);
 	}

	// onlyOwners

  	function changeBankAddr(address _newAddr) external onlyOwner{
    	bank = IERC20(_newAddr);
  	}

  	function changeBonAddr(address _newAddr) external onlyOwner{
    	bon = IERC20(_newAddr);
  	}

	function changeEndTime(uint _secondsTillEnd) external onlyOwner{
    	end = block.timestamp + _secondsTillEnd;
  	}

  	function pullBANKpool() external payable onlyOwner {
        uint256 bankBalance = IERC20(bank).balanceOf(address(this));
        require(bankBalance > 0, "no BANK remaining");
		bool success1 = IERC20(bank).transfer(msg.sender, bankBalance);
        require(success1 == true, "transfer failed!");
  	}
	
	function closeExchangePool() external payable onlyOwner {
        uint256 bonBalance = IERC20(bon).balanceOf(address(this));
		uint256 bankBalance = IERC20(bank).balanceOf(address(this));
        uint256 gasBalance = address(this).balance;
        if(bonBalance > 0){
            bool success1 = IERC20(bon).transfer(msg.sender, bonBalance);
            require(success1 == true, "transfer failed!");
			// burned on Modulus if not claimed
        }
		if(bankBalance > 0){
            bool success2 = IERC20(bank).transfer(msg.sender, bankBalance);
            require(success2 == true, "transfer failed!");
			// burned on Polygon after unwrapping process
        }
        if(gasBalance > 0){
            (bool success3,) = payable(msg.sender).call{value: gasBalance}("");
            require(success3 == true, "transfer failed!");
        }
  	}
}
