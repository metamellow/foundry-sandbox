/*
- focus on the 1v1 deposit then trigger a API3 airnode call
    - see below for how to do the airnode call: https://docs.api3.org/guides/qrng/lottery-guide/#_1-coding-the-lottery-contract
    - just have ONE (of each) lotto per time shown on the website and each finish calls up the lottoFactory
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
/* -.-.-.-.-.    BANK OF NOWHERE LOTTO  V2    .-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY REBEL LABS ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
//import "@Uniswap/v2-periphery/contracts/UniswapV2Router02.sol";
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";

contract LottoV2 is Ownable{
    address public erc20token;
    //address public erc20LP;
    address public treasury;

    address public player1W;
    address public player2W;

    bool public lottoOpen;

    uint256 public betPrice;

    mapping(uint256 => address) public pastLottoTxns;

    constructor(
        address _erc20token,
        //address _erc20LP,
        address _treasury,
        bool _lottoOpen,
        uint256 _betPrice
        ){
        erc20token = _erc20token;       // "0x47E53f0Ddf71210F2C45dc832732aA188F78AA4f" (BON)
        //erc20LP = _erc20LP;           // "0x26432f7cf51e644c0adcaf3574216ee1c0a9af6d" (BON/WMATIC)
        treasury = _treasury;           // "0xb1a23cD1dcB4F07C9d766f2776CAa81d33fa0Ede" (DevsMultiS)
        player1W = address(0);          // "address(0)" (player slot is empty)
        player2W = address(0);          // "address(0)" (player slot is empty)
        lottoOpen = _lottoOpen;         // "true" (lotto is open to play)
        betPrice = _betPrice;           // "30000000000000000000" (30 MATIC)
    }

    // --- PUBLIC FUNCTIONS ---

    function bet() external payable{
        // REQUIREMENTS STAGE
        require(betPrice <= msg.value, "Need more gas to cover the current price");
        require(lottoOpen, "Lotto is not accepting bets");
        
        // PAYMENTS STAGE
        uint256 tax = betPrice * 10 / 100;
        (bool transfer1, )  = payable(treasury).call{value: tax}("tax");
        require(transfer1, "Transfer failed");

        /*
        uint256 lottoFunds = betPrice - tax;
        require(uniswapConvertToBase(lottoFunds), "ERC20 conversion failed");
        */

        // EVALUATE STAGE
        if (player1W == address(0)){
            // PLAYER'S 1 TURN
            player1W = msg.sender;
        }
        else{
            // PLAYER'S 2 TURN
            player2W = msg.sender;

            uint256 chosenWinner = api3CallResults;
        }
    }

    function currentRewardsValue() public view returns(uint256 valueBON, uint valueMATIC){
        // return both values
        // one from the balanceOf
        // one from a uniswap price quote based on the pool
        valueBON = IERC20(erc20token).balanceOf(address(this));
        // valueMATIC = uniswapFunction(valueBON);
        valueMATIC = 696969696969696969696969696969;
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