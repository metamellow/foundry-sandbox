// SPDX-License-Identifier: GNU
pragma solidity ^0.8.0;

// _______________________________________________________
/*
// --- GENERATE SPONSOR WALLET PROCESS ---
// run in terminal, after entering data ( https://docs.api3.org/reference/qrng/chains.html#anu )
// deployed contract == sponsor-address
// Examples:

// Eth Mainnet
npx @api3/airnode-admin derive-sponsor-wallet-address \
--airnode-xpub xpub6DXSDTZBd4aPVXnv6Q3SmnGUweFv6j24SK77W4qrSFuhGgi666awUiXakjXruUSCDQhhctVG7AQt67gMdaRAsDnDXv23bBRKsMWvRzo6kbf \
--airnode-address 0x9d3C147cA16DB954873A498e0af5852AB39139f2 \
--sponsor-address 0x14b43F1b22b47c401dEC863883B32e715313061E

// Poly Mainnet ANU
npx @api3/airnode-admin derive-sponsor-wallet-address \
--airnode-xpub xpub6DXSDTZBd4aPVXnv6Q3SmnGUweFv6j24SK77W4qrSFuhGgi666awUiXakjXruUSCDQhhctVG7AQt67gMdaRAsDnDXv23bBRKsMWvRzo6kbf \
--airnode-address 0x9d3C147cA16DB954873A498e0af5852AB39139f2 \
--sponsor-address 0xbfac8df3fa1c2c1478b5afe4137564b54b0dbbf4
// Sponsor wallet address: 0x2008dB89D2f64e20DE344F3BaA080D84b4E1F861

// Poly Mainnet Quintessence
npx @api3/airnode-admin derive-sponsor-wallet-address \
--airnode-xpub xpub6CyZcaXvbnbqGfqqZWvWNUbGvdd5PAJRrBeAhy9rz1bbnFmpVLg2wPj1h6TyndFrWLUG3kHWBYpwacgCTGWAHFTbUrXEg6LdLxoEBny2YDz \
--airnode-address 0x224e030f03Cd3440D88BD78C9BF5Ed36458A1A25 \
--sponsor-address 0x14d1e21657557ac43a94f2ffbd104c8dadce1b9a

// Poly Mumbai
npx @api3/airnode-admin derive-sponsor-wallet-address \
--airnode-xpub xpub6CuDdF9zdWTRuGybJPuZUGnU4suZowMmgu15bjFZT2o6PUtk4Lo78KGJUGBobz3pPKRaN9sLxzj21CMe6StP3zUsd8tWEJPgZBesYBMY7Wo \
--airnode-address 0x6238772544f029ecaBfDED4300f13A3c4FE84E1D \
--sponsor-address 0x78a7406e89159594670B7E4dA0b76b2C3276234d
// Sponsor wallet address: 0xe2105726a2c6e97c5c5eC87043d7fDb62741BAD7
	
*/
// _______________________________________________________


/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.   BANK OF NOWHERE LOTTO  V2.07  .-.-.-.-. */
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
    address private dev1;
    address private dev2;
    address public player1W;
    address public player2W;
    uint256 public betPrice;
    uint256 public counter;
    bool public lottoOpen;
    bool public taxSwitch;

    mapping(uint256 => bool) public pastLottoClaimed;
    mapping(uint256 => address) public pastLottoPlayer1;
    mapping(uint256 => address) public pastLottoPlayer2;
    mapping(uint256 => address) public pastLottoResults;
    mapping(uint256 => uint256) public pastLottoRewards;
    mapping(bytes32 => uint256) public pastLottoAPI3CallCounter;
    mapping(uint256 => uint256) public pastLottoAPI3CallResult;

    event BetDetails (uint256 playersCounter, uint256 counterReward);
    event ClaimDetails (uint256 claimedCounter, uint256 claimedRewards);

    // API3 VARS
    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorWallet;
    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

    constructor(
        address _treasury,
        address _dev1,
        address _dev2,
        uint256 _betPrice,
        address _airnodeRrp            // ETH MAIN (0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd) POLY MAIN (0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd) POLY TEST (0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd)
        ) RrpRequesterV0(_airnodeRrp){
        treasury = _treasury;           // ETH MAIN "0xCff8339DA421c465d4325268799300952B55FAd0" POLY MAIN "0xb1a23cD1dcB4F07C9d766f2776CAa81d33fa0Ede" (DevsMultiS)
        dev1 = _dev1;                   // "0xc70C1a847EE38883179A2eC0767868257B18BD67" (s0c)
        dev2 = _dev2;                   // "0x2B5fF8Cba8ED3A6E7813CD5e55ecd95B87791cee" (MERP)
        player1W = address(0);          // "address(0)" (player slot is empty) - technically this is unneeded in constr
        player2W = address(0);          // "address(0)" (player slot is empty) - technically this is unneeded in constr
        betPrice = _betPrice;           // "10000000000000000" (0.01 MATIC)
        counter = 0;                    // "0" (counts the total new games)
        lottoOpen = true;              // "true" (unlocked)
        taxSwitch = true;               // "true" (taxes on)
    }

    // --- PUBLIC FUNCTIONS ---

    function bet() public payable{
        // REQUIREMENTS STAGE
        require(betPrice <= msg.value, "Need more gas to pay the betPrice");
        require(lottoOpen == true, "Lotto is not accepting bets");
        require(player1W != msg.sender, "Can not bet twice");

        // PAYMENT STAGE
        if(taxSwitch == true){
            _sendTaxes();
        }

        // EVALUATE STAGE
        if ((player1W == address(0)) && (player2W == address(0))){
            // PLAYER'S 1 TURN
            counter++;
            player1W = msg.sender;
            pastLottoPlayer1[counter] = player1W;
            pastLottoRewards[counter] = (betPrice - (betPrice * 10 / 100)) *2;
        }
        else if ((player1W != address(0)) && (player2W == address(0))){
            // PLAYER'S 2 TURN
            player2W = msg.sender;
            pastLottoPlayer2[counter] = player2W;

            // API3 QRNG CALL
            _makeAPICall();

            // RESET LOTTO
            player1W = address(0);
            player2W = address(0);
            betPrice = betPrice * 11 / 10;
        }

        emit BetDetails(counter, pastLottoRewards[counter]);
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
        require(pastLottoResults[_counter] == msg.sender, "This wallet is not the winner");
        require(pastLottoClaimed[_counter] != true, "This reward has already been claimed");
        require(lottoOpen, "Lotto is not open");

        pastLottoClaimed[_counter] = true;
        rewards = pastLottoRewards[_counter];
        (bool transfer1, )  = payable(msg.sender).call{value: rewards}("rewards");
        require(transfer1, "Transfer failed");

        emit ClaimDetails(_counter, rewards);
        return (rewards);
    }
    
    // --- DEV FUNCTIONS ---
    function _sendTaxes() internal{
        uint256 tax1 = betPrice * 6 / 100;
        uint256 tax2 = betPrice * 2 / 100;
        uint256 tax3 = betPrice * 2 / 100;
        payable(treasury).transfer(tax1);
        payable(dev1).transfer(tax2);
        payable(dev2).transfer(tax3);
    }
    
    function resetLotto(
        address _treasury, 
        address _dev1, 
        address _dev2, 
        address _player1W, 
        address _player2W, 
        uint256 _betPrice, 
        uint256 _counter,
        bool _lottoOpen,
        bool _taxSwitch,
        bool _resetFunds, 
        address _erc20token
        ) external onlyOwner{
        treasury = _treasury;
        dev1 = _dev1;
        dev2 = _dev2;
        player1W = _player1W;
        player2W = _player2W;
        betPrice = _betPrice; 
        counter = _counter;
        lottoOpen = _lottoOpen;
        taxSwitch = _taxSwitch;
        
        if(_resetFunds == true){
            uint256 erc20Balance = IERC20(_erc20token).balanceOf(address(this));
            if(erc20Balance > 0){
                bool transferAOne = IERC20(_erc20token).transfer(treasury, erc20Balance);
                require(transferAOne, "transfer failed!");
            }
            uint256 gasBalance = address(this).balance;
            if(gasBalance > 0){
                ( bool transferBOne, ) = payable(treasury).call{value: gasBalance}("");
                require(transferBOne, "Transfer failed.");
            }
        }

    }

    function pauseLotto(bool _lottoOpen) external onlyOwner{
        lottoOpen = _lottoOpen;
    }
    
    // --- API3 FUNCTIONS ---
    function setRequestParameters(
        address _airnode,               // ETH MAIN (0x9d3C147cA16DB954873A498e0af5852AB39139f2) POLY MAIN (0x9d3C147cA16DB954873A498e0af5852AB39139f2) POLY TEST (0x6238772544f029ecaBfDED4300f13A3c4FE84E1D)
        bytes32 _endpointIdUint256,     // ETH MAIN (0xfb6d017bb87991b7495f563db3c8cf59ff87b09781947bb1e417006ad7f55a78) POLY MAIN (0xfb6d017bb87991b7495f563db3c8cf59ff87b09781947bb1e417006ad7f55a78) POLY TEST (0xfb6d017bb87991b7495f563db3c8cf59ff87b09781947bb1e417006ad7f55a78)
        address _sponsorWallet          // Created after contract deploy and filled with some gas
        ) external onlyOwner {
        airnode = _airnode;
        endpointIdUint256 = _endpointIdUint256;
        sponsorWallet = _sponsorWallet;
    }

    function _makeAPICall() private{
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
    }

    // AirnodeRrp will call back with a response
    function fulfillUint256(bytes32 requestId, bytes calldata data) external onlyAirnodeRrp{
        require(expectingRequestWithIdToBeFulfilled[requestId],"Request ID not known");
        expectingRequestWithIdToBeFulfilled[requestId] = false;
        uint256 qrngUint256 = abi.decode(data, (uint256));

        uint256 requestIdCounter = pastLottoAPI3CallCounter[requestId];
        pastLottoAPI3CallResult[requestIdCounter] = qrngUint256;
        if(qrngUint256 % 2 == 0){
            pastLottoResults[requestIdCounter] = pastLottoPlayer2[requestIdCounter];
        } else{
            pastLottoResults[requestIdCounter] = pastLottoPlayer1[requestIdCounter];
        }
    }
    
    fallback() external payable{
    }
    receive() external payable{
    }
}