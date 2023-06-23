
// - https://blog.chain.link/how-to-build-a-crypto-game/#connecting_your_wallet  

/*
- after thinking about this, I realized that people can easily look at my code to find the salt 
    and then combine it with 1 to 100 in their own computers to see which one makes 
    a combination the same as the hashed answer.

    So the answer to this is I should focus on the 1v1 deposit then trigger a API3 airnode call
    see below for how to do the airnode call

    https://docs.api3.org/guides/qrng/lottery-guide/#_1-coding-the-lottery-contract

    just have ONE lotto per time shown on the website and each finish calls up the lottoFactory
    and the lotto factory can use quasi randomness to choose betAmount and numPlayers
    this website could use something similar to the Svelte page earlier

- Make another that takes all bets and then releases the funds once its done
    - make the betAmount variable
    - make it 2 player and 3 player and 4 player
    - P1 send a payment of 5 MATIC, dev gets 0.5, 4.5 goes into the pot
    - then wait for P2 to also pay 5, 0.5 to dev, 4.5 in
    - so total pot equals 9.0 matic
    - then after all deposits trigger a API3 airnode call for a RNG ranged based on player numbers

- figure out the uniswap conversions last 
    (and just prank stock it with the erc20 for testing)
*/

// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.-. BANK OF NOWHERE LOTTO v0.1 -.-.-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@Uniswap/v2-periphery/contracts/UniswapV2Router02.sol";

contract Q2E is Ownable{
    address public erc20token;
    //address public erc20LP;
    address public treasury;

    uint256 public baseCost;
    uint256 public taxRate;
    uint256 public maxRounds;
    uint256 public counter;
    bool public lottoOpen;

    string public question;
    bytes32 private salt = bytes32("changeThisBeforeDeploying"); // --- CHANGE THIS BEFORE DEPOLY ---
    bytes32 public hashedAnswer;

    mapping(uint256 => string) public pastGuesses;
    
    event GuessResults(bool success, string guess, uint winnings);

    constructor(
        address _erc20token, 
        //address _erc20LP,
        address _treasury, 
        uint256 _baseCost, 
        uint256 _taxRate,
        uint256 _maxRounds,
        bool _lottoOpen,
        string memory _question, 
        bytes32 _hashedAnswer
        ){
        lottoOpen = _lottoOpen;         // true
        question = _question;           // "xx?"
        hashedAnswer = _hashedAnswer;   // "xx"
        treasury = _treasury;           // "0xb1a23cD1dcB4F07C9d766f2776CAa81d33fa0Ede" DevsMultiS
        erc20token = _erc20token;       // "0x47E53f0Ddf71210F2C45dc832732aA188F78AA4f" BON
        //erc20LP = _erc20LP;           // "0x26432f7cf51e644c0adcaf3574216ee1c0a9af6d" BON/WMATIC
        baseCost = _baseCost;           // "5000000000000000000" 5 Matic ~$3.50
        taxRate = _taxRate;             // "1000" 10% of baseFee (1,000/10,000)
        maxRounds = _maxRounds;         // 100 rounds
        counter = 1;                    //
    }

    // --- PUBLIC FUNCTIONS ---

    function currentPrice() public view returns(uint256){
        require(lottoOpen, "Lotto closed");
        uint price = (counter * baseCost);
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
        require(price <= msg.value, "Need more gas to cover the current price");
        
        uint256 tax = price * taxRate / 10000;
        ( bool transfer1, ) = payable(treasury).call{value: tax}("tax");
        require(transfer1, "Transfer failed");

        /*
        uint256 lottoFunds = price - tax;
        require(uniswapConvertToBase(lottoFunds), "ERC20 conversion failed");
        */

        pastGuesses[counter] = answer;
        counter++;
        
        uint256 winnings = IERC20(erc20token).balanceOf(address(this));
        success = false;
        if(keccak256(abi.encodePacked(salt, answer)) == hashedAnswer){
            success = true;
            lottoOpen = !lottoOpen;
            require(IERC20(erc20token).transferFrom(address(this), msg.sender, winnings), "transfer failed!");
        } else {
            if(counter==(maxRounds-1)){
                lottoOpen = !lottoOpen;
        }}
        emit GuessResults(success, answer, winnings);
        return success;
    }

    // --- DEV FUNCTIONS ---

    function closeLotto() external onlyOwner{
        uint256 erc20Balance = IERC20(erc20token).balanceOf(address(this));
        uint256 gasBalance = address(this).balance;
        if(erc20Balance > 0){
            bool transferAOne = IERC20(erc20token).transfer(treasury, erc20Balance);
            require(transferAOne, "transfer failed!");
        }
        if(gasBalance > 0){
            ( bool transferBOne, ) = payable(treasury).call{value: gasBalance}("");
            require(transferBOne, "Transfer failed.");
        }
        lottoOpen = false;
    }
    
    /*

    // this works for V2 pools https://etherscan.io/address/0x639aedc161d4f2a9a399100efbf294bed1432c0f#code
    // https://docs.uniswap.org/contracts/v2/reference/smart-contracts/router-02#swapexactethfortokens

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
