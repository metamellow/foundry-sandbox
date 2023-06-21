
// users pay in matic, tax is taken, remainder is uniswapped to BON and held in contract as reward
// -^- this will create steady upward value and then a drop on rewards sale, but volume is volume
// - https://blog.chain.link/how-to-build-a-crypto-game/#connecting_your_wallet  

/*
NOTES
- Lets just build everything and then add the converter system later
*/


// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.-. BANK OF NOWHERE LOTTO v0.1 -.-.-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@Uniswap/v2-periphery/contracts/UniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Router.sol";

contract Q2E is Ownable{
    bool public lottoOpen;
    bytes32 private salt = bytes32("changeThisBeforeDeploying"); // --- CHANGE THIS BEFORE DEPOLY ---
    bytes32 public hashedAnswer;
    string public question;
    address public devsW;
    address public erc20token;
    //address public erc20LP;
    uint256 public baseFee;
    uint256 public taxFee;
    uint256 public counter;

    mapping(uint256 => string) public pastGuesses;
    
    event GuessResults(bool success, string guess, uint winnings);

// maybe have two vars above to specify the main the two tokens and then use those in theuniswap incase the LP order is not what is expected

    constructor(
        string memory _question, 
        bytes32 _hashedAnswer,
        address _devsW, 
        address _erc20token, 
        //address _erc20LP,
        uint256 _baseFee, 
        uint256 _taxFee
        ){
        lottoOpen = true;               // true
        question = _question;           // "xx?"
        hashedAnswer = _hashedAnswer;   // "xx"
        devsW = _devsW;                 // "0xb1a23cD1dcB4F07C9d766f2776CAa81d33fa0Ede" DevsMultiS
        erc20token = _erc20token;       // "0x47E53f0Ddf71210F2C45dc832732aA188F78AA4f" BON
        //erc20LP = _erc20LP;           // "0x26432f7cf51e644c0adcaf3574216ee1c0a9af6d" BON/WMATIC
        baseFee = _baseFee;             // "5000000000000000000" 5 Matic ~$3.50
        taxFee = _taxFee;               // "1000" 10% of baseFee (1,000/10,000)
        counter = 1;
    }

    // --- PUBLIC FUNCTIONS ---

    function currentPrice() public view returns(uint256){
        require(lottoOpen, "Lotto closed");
        uint price = (counter * baseFee);
        return price;
    }

    function currentRewardsValue() public view returns(uint256 valueBON, uint valueMATIC){
        // return both values
        // one from the balanceOf
        // one from a uniswap price quote based on the pool
        valueBON = IERC20(erc20token).balanceOf(address(this));
        valueMATIC = 696969696969696969696969696969;
    }

    function guess(string calldata answer) external payable returns(bool success){
        require(lottoOpen, "Lotto closed");

        uint256 price = currentPrice();
        require(price <= msg.value, "Must send enough gas to cover the current price");
        
        uint256 tax = price * taxFee / 10000;
        ( bool transfer1, ) = payable(devsW).call{value: tax}("tax");
        require(transfer1, "Transfer failed");

        /*
        uint256 lottoFunds = price - tax;
        require(uniswapConvertToBase(lottoFunds), "ERC20 conversion failed");
        */

        counter++;
        pastGuesses[counter] = answer;
        
        uint256 winnings = IERC20(erc20token).balanceOf(address(this));
        success = false;
        if(keccak256(abi.encodePacked(salt, answer)) == hashedAnswer){
            success = true;
            lottoOpen = !lottoOpen;
            require(IERC20(erc20token).transferFrom(address(this), msg.sender, winnings), "transfer failed!");
        }

        emit GuessResults(success, answer, winnings);
        return success;
    }

    // --- DEV FUNCTIONS ---

    function closeLotto() external onlyOwner{
        uint256 erc20Balance = IERC20(erc20token).balanceOf(address(this));
        uint256 gasBalance = address(this).balance;
        if(erc20Balance > 0){
            bool transferAOne = IERC20(erc20token).transfer(devsW, erc20Balance);
            require(transferAOne, "transfer failed!");
        }
        if(gasBalance > 0){
            ( bool transferBOne, ) = payable(devsW).call{value: gasBalance}("");
            require(transferBOne, "Transfer failed.");
        }
        lottoOpen = false;
    }
    
    /*

    // this works for V2 pools https://etherscan.io/address/0x639aedc161d4f2a9a399100efbf294bed1432c0f#code

    // @dev --- contract(this) must have APPROVEd uniswap to use 'token0' before v-this-v can work
    function uniswapConvertToBase(uint256 amountIn) internal returns(bool){
        // tax token swap payment process
        address[] memory path = new address[](2);
        path[0] = erc20LP.token0();
        path[1] = erc20LP.token1();
        oracleData[] = erc20LP.getReserves();
        amountOutMinBeforeSlip = (oracleData[0] / oracleData[1] * amountIn);
        amountOutMin = amountOutMinBeforeSlip - (amountOutMinBeforeSlip * 30/1000);
        require(UniswapV2Router02.swapExactTokensForETH(amountIn, amountOutMin, path, address(this), block.timestamp), "transfer failed!");
        return true;
    }

    function approveUni() external onlyOwner{
        // maybe this APPROVAL is needed to let the LOTTO CONTRACT approve Uni to transfer tokens?
        uint256 blah = 2;
    }
    */

    fallback() external payable{
    }
    receive() external payable{
    }

}
