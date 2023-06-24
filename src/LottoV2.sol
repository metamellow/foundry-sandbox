// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;










// --- contract ---
// need to test
// need to finish up claim process
// the payment stage needs a look through
// consider adding in a parabolic cost feature; betPrice * 11 / 10
// closeLotto need a lot of work now
// --- website ---
// should add some cool wallet reading features on site with ethersJS
// should display last rounds results above the current rounds options; like darts or
// ...













/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.   BANK OF NOWHERE LOTTO  V2.01  .-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY REBEL LABS ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

/* .--------------------------------------------------. //
- (1) Create 'sponsor wallet' for API3 QRNG system
    - For details, see: https://docs.api3.org/reference/qrng/chains.html#anu
    - For tutorial, see: https://.developerdao.com/create-a-random-generated-number-on-chain-using-api3-tools-for-free 
- (2) Call (this).setRequestParameters()
- (3) Set lottoOpen to 'true'
// .--------------------------------------------------. */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";

contract LottoV2 is Ownable, RrpRequesterV0 {
    
    // LOTTO VARS
    address private treasury;
    address public player1W;
    address public player2W;
    uint256 public betPrice;
    uint256 public counter;
    bool public lottoOpen;

    mapping(uint256 => address) public pastLottoPlayer1;
    mapping(uint256 => address) public pastLottoPlayer2;
    mapping(uint256 => address) public pastLottoResults;
    mapping(bytes32 => uint256) public pastLottoAPI3CallCounter;
    mapping(uint256 => bool) public pastLottoClaimed;

    event BetDetails (uint256 playersCounter);

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
        player1W = address(0);          // "address(0)" (player slot is empty)
        player2W = address(0);          // "address(0)" (player slot is empty)
        betPrice = _betPrice;           // "10000000000000000000" (10 MATIC)
        counter = 0;                    // "0" (counts the total new games)
        lottoOpen = false;                // "false" (lotto is locked until admin setup)
    }

    // --- PUBLIC FUNCTIONS ---

    function bet() external payable returns(uint256){
        // REQUIREMENTS STAGE
        require(betPrice <= msg.value, "Need more gas to cover the current price");
        require(lottoOpen, "Lotto is not accepting bets");
        
        // EVALUATE STAGE
        if ((player1W == address(0)) && (player2W == address(0))){
            // PAYMENT STAGE
            uint256 tax = betPrice * 10 / 100;
            (bool transfer1, )  = payable(treasury).call{value: tax}("tax");
            require(transfer1, "Transfer failed");
            
            // PLAYER'S 1 TURN
            counter++;
            player1W = msg.sender;
            pastLottoPlayer1[counter] = player1W;

            emit BetDetails(counter);
        }
        else if ((player1W != address(0)) && (player2W == address(0))){
            // PAYMENT STAGE
            uint256 tax = betPrice * 10 / 100;
            (bool transfer1, )  = payable(treasury).call{value: tax}("tax");
            require(transfer1, "Transfer failed");
            
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
            
            emit BetDetails(counter);

            // RESET LOTTO
            player1W = address(0);
            player2W = address(0);
// betPrice = betPrice * 11 / 10
        }
    }

    function claimLottoRewards(uint256 _counter) public returns(bool winner, uint256 rewards){
        winner = false;
        rewards = 0;
        if(){

        }
        else{

        }

        return (winner, rewards);
    }
    
    // --- DEV FUNCTIONS ---

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
        
        uint256 requestIdCounter = pastLottoAPI3CallCounter[requestId];
        if(qrngUint256 % 2 == 0){pastLottoResults[requestIdCounter] = pastLottoPlayer2[requestIdCounter];}
        else{pastLottoResults[requestIdCounter] = pastLottoPlayer1[requestIdCounter];}
    }

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

    fallback() external payable{
    }
    receive() external payable{
    }

}