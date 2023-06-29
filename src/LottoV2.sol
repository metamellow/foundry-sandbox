// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;


//-//-//-//-//-//-//-//-//-//-//-//-//-//-//-//-//-//-//
// ----------------------  NOTES  ----------------------
// --- contract ---
// - ((1)) should split off 1% merp and 1% soc
// - ((2)) should add a qrng results log
// --- website ---
// - should add some cool wallet reading features on site with ethersJS
// - should display last rounds results above the current rounds options; like darts or
//-//-//-//-//-//-//-//-//-//-//-//-//-//-//-//-//-//-//


/* v2.04
// GENERATE SPONSOR WALLET MUMBAI
	
npx @api3/airnode-admin derive-sponsor-wallet-address \
--airnode-xpub xpub6CuDdF9zdWTRuGybJPuZUGnU4suZowMmgu15bjFZT2o6PUtk4Lo78KGJUGBobz3pPKRaN9sLxzj21CMe6StP3zUsd8tWEJPgZBesYBMY7Wo \
--airnode-address 0x6238772544f029ecaBfDED4300f13A3c4FE84E1D \
--sponsor-address 0x1dc47D2ec5FAD3E9D744D437eE5eb2f2A8A0F498
	
# // >> Sponsor wallet address: 0xA0F82e86C2025e61797EfA2541C0373eA71149B8
# // >> lotto contract: 0x1dc47D2ec5FAD3E9D744D437eE5eb2f2A8A0F498

*/






// _______________________________________________________
// _______________________________________________________
// _______________________________________________________
// _______________________________________________________
// _______________________________________________________
// _______________________________________________________
// _______________________________________________________
// _______________________________________________________
// _______________________________________________________
// $PDX-License-Identifier: GNU
// pragma solidity ^0.8.0;

// --- TESTING VERSION ---

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.   BANK OF NOWHERE LOTTO  V2.04  .-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY REBEL LABS ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

/* .---------------------- setup ---------------------. //
- (1) Deploy contract
- (2) Create 'sponsor wallet' for API3 QRNG system
    - For details, see: https://docs.api3.org/reference/qrng/chains.html#anu
    - For tutorial, see: https://blog.developerdao.com/create-a-random-generated-number-on-chain-using-api3-tools-for-free
- (3) Fund sponsor wallet with MATIC
- (4) Call address(this).setRequestParameters()
// .--------------------------------------------------. */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";

contract LottoV2 is Ownable, RrpRequesterV0 {
    
    // LOTTO VARS
    address private treasury;
    // ------------------------------------------------------------ ((1)) should split off 1% merp and 1% soc
    address public player1W;
    address public player2W;
    uint256 public betPrice;
    uint256 public counter;
    bool public lottoOpen;

    mapping(uint256 => bool) public pastLottoClaimed;
    mapping(uint256 => address) public pastLottoPlayer1;
    mapping(uint256 => address) public pastLottoPlayer2;
    mapping(uint256 => address) public pastLottoResults;
    mapping(uint256 => uint256) public pastLottoRewards;
    mapping(bytes32 => uint256) public pastLottoAPI3CallCounter;
    // ------------------------------------------------------------ ((2)) should add a qrng results log

    event BetDetails (uint256 playersCounter, uint256 counterReward);

    // API3 VARS
    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorWallet;
    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

    constructor(
        address _treasury,
        uint256 _betPrice,
        address _airnodeRrp             // POLY MAIN (0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd) POLY TEST (0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd)
        ) RrpRequesterV0(_airnodeRrp){
        treasury = _treasury;           // "0xb1a23cD1dcB4F07C9d766f2776CAa81d33fa0Ede" (DevsMultiS)
        // ------------------------------------------------------------ ((1)) should split off 1% merp and 1% soc
        player1W = address(0);          // "address(0)" (player slot is empty)
        player2W = address(0);          // "address(0)" (player slot is empty)
        betPrice = _betPrice;           // "10000000000000000" (0.01 MATIC)
        counter = 0;                    // "0" (counts the total new games)
        lottoOpen = true;              // "true" (unlocked)
    }

    // --- PUBLIC FUNCTIONS ---

    function bet() public payable returns(bool success){
        // REQUIREMENTS STAGE
        require(betPrice <= msg.value, "Need more gas to cover the current price");
        require(lottoOpen, "Lotto is not accepting bets");
        
        // EVALUATE STAGE
        if ((player1W == address(0)) && (player2W == address(0))){
            // PAYMENT STAGE
            uint256 tax = betPrice * 10 / 100;
            (bool transfer1, )  = payable(treasury).call{value: tax}("tax");
            require(transfer1, "Transfer failed");
            // ------------------------------------------------------------ ((1)) should split off 1% merp and 1% soc

            // PLAYER'S 1 TURN
            counter++;
            player1W = msg.sender;
            pastLottoPlayer1[counter] = player1W;
            pastLottoRewards[counter] = (betPrice - (betPrice * 10 / 100)) *2;

            emit BetDetails(counter, pastLottoRewards[counter]);
            return success = true;
        }
        else if ((player1W != address(0)) && (player2W == address(0))){
            require(msg.sender != player1W, "You shall not pass");

            // PAYMENT STAGE
            uint256 tax = betPrice * 10 / 100;
            (bool transfer1, )  = payable(treasury).call{value: tax}("tax");
            require(transfer1, "Transfer failed");
            // ------------------------------------------------------------ ((1)) should split off 1% merp and 1% soc
            
            // PLAYER'S 2 TURN
            player2W = msg.sender;
            pastLottoPlayer2[counter] = player2W;

            // API3 CALL
            bytes32 requestId = airnodeRrp.makeFullRequest(
                airnode,
                endpointIdUint256,
                address(this),
                sponsorWallet,
                address(this),
                this.fulfillUint256.selector,
                ""
            );
            expectingRequestWithIdToBeFulfilled[requestId] = true;
            pastLottoAPI3CallCounter[requestId] = counter;

            // RESET LOTTO
            player1W = address(0);
            player2W = address(0);
            betPrice = betPrice * 11 / 10;

            emit BetDetails(counter, pastLottoRewards[counter]);
            return success = true;
        }
    }

    function checkLotto(uint256 _counter) public view returns(
        address winner, 
        uint256 rewards, 
        bool claimed){
        require(lottoOpen, "Lotto is not open");
        winner = pastLottoResults[_counter];
        rewards = pastLottoRewards[_counter];
        claimed = pastLottoClaimed[_counter];
        return (winner, rewards, claimed);
    }
    
    function claimLotto(uint256 _counter) public returns(uint256 rewards){
        require(pastLottoResults[_counter] == msg.sender);
        require(pastLottoClaimed[_counter] != true);
        require(lottoOpen, "Lotto is not open");

        pastLottoClaimed[_counter] = true;
        rewards = pastLottoRewards[_counter];
        (bool transfer1, )  = payable(msg.sender).call{value: rewards}("rewards");
        require(transfer1, "Transfer failed");

        return (rewards);
    }
    
    // --- DEV FUNCTIONS ---
    function resetLotto(
        address _treasury, 
        address _player1W, 
        address _player2W, 
        uint256 _betPrice, 
        uint256 _counter,
        bool _lottoOpen,
        address _erc20token
        ) external onlyOwner{
        treasury = _treasury;
        player1W = _player1W;
        player2W = _player2W;
        betPrice = _betPrice; 
        counter = _counter;
        lottoOpen = _lottoOpen;
        
        uint256 erc20Balance = IERC20(_erc20token).balanceOf(address(this));
        uint256 gasBalance = address(this).balance;
        if(erc20Balance > 0){
            bool transferAOne = IERC20(_erc20token).transfer(treasury, erc20Balance);
            require(transferAOne, "transfer failed!");
        }
        if(gasBalance > 0){
            ( bool transferBOne, ) = payable(treasury).call{value: gasBalance}("");
            require(transferBOne, "Transfer failed.");
        }
    }

    function openLotto(bool _lottoOpen ) external onlyOwner{
        lottoOpen = _lottoOpen;
    }
    
    // --- API3 FUNCTIONS ---
    function setRequestParameters(
        address _airnode,               // POLY MAIN (0x9d3C147cA16DB954873A498e0af5852AB39139f2) POLY TEST (0x6238772544f029ecaBfDED4300f13A3c4FE84E1D)
        bytes32 _endpointIdUint256,     // POLY MAIN (0xfb6d017bb87991b7495f563db3c8cf59ff87b09781947bb1e417006ad7f55a78) POLY TEST (0xfb6d017bb87991b7495f563db3c8cf59ff87b09781947bb1e417006ad7f55a78)
        address _sponsorWallet          // POLY MAIN (xxx) POLY TEST (xxx)
        ) external onlyOwner {
        airnode = _airnode;
        endpointIdUint256 = _endpointIdUint256;
        sponsorWallet = _sponsorWallet;
    }

    // AirnodeRrp will call back with a response
    function fulfillUint256(bytes32 requestId, bytes calldata data) external onlyAirnodeRrp{
        require(expectingRequestWithIdToBeFulfilled[requestId],"Request ID not known");
        expectingRequestWithIdToBeFulfilled[requestId] = false;
        uint256 qrngUint256 = abi.decode(data, (uint256));

        // ------------------------------------------------------------ ((2)) should add a qrng results log
        uint256 requestIdCounter = pastLottoAPI3CallCounter[requestId];
        if(qrngUint256 % 2 == 0){pastLottoResults[requestIdCounter] = pastLottoPlayer2[requestIdCounter];}
        else{pastLottoResults[requestIdCounter] = pastLottoPlayer1[requestIdCounter];}
    }
    
    fallback() external payable{
    }
    receive() external payable{
    }

}