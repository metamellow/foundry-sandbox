// SPDX-License-Identifier: GNU-3.0
pragma solidity ^0.8.0;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.   BANK OF NOWHERE LOTTO  V3.01  .-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY REBEL LABS ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

/* .---------------------- setup ---------------------. //
- (1) Deploy contract
- (2) Create 'sponsor wallet' for API3 QRNG system
    - For details, see: https://docs.api3.org/reference/qrng/chains.html#anu
- (3) Fund sponsor wallet with MATIC
- (4) Call address(this).setRequestParameters()
// .--------------------------------------------------. */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";

contract LottoV3 is Ownable, RrpRequesterV0, ERC721, ERC721Burnable {
    
    // LOTTO VARS
    address private treasury;
    address private staking;
    address private dev1;
    address private dev2;
    address public erc20Token;
    address public player1W;
    address public player2W;
    uint256 public betBase;
    uint256 public betPrice;
    uint256 public counter;
    uint256 public restartDuration;
    uint256 public restartTimer;
    uint256 public taxRate;
    bool public lottoOpen;
    bool public taxSwitch;

    mapping(uint256 => bool) public pastLottoClaimed;
    mapping(uint256 => address) public pastLottoPlayer1;
    mapping(uint256 => address) public pastLottoPlayer2;
    mapping(uint256 => uint256) public pastLottoRewards;
    mapping(bytes32 => uint256) public pastLottoAPI3CallCounter;
    mapping(uint256 => uint256) public pastLottoAPI3CallResult;

    event APICallDetails (uint256 callSent);
    event ApprovalDetails (bool approvalSuccess);
    event BetDetails (uint256 playersCounter, uint256 counterReward);
    event ClaimDetails (uint256 claimedCounter, uint256 claimedRewards);
    event WinnerResults (uint256 counterNumber, address winnerWallet);


    // API3 VARS
    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorWallet;
    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

    constructor(
        address _erc20Token, // "0x47e53f0ddf71210f2c45dc832732aa188f78aa4f" or "0x0000000000000000000000000000000000000000"
        address _treasury, // 
        address _staking, // 
        address _dev1, // "0xc70C1a847EE38883179A2eC0767868257B18BD67" (s0c)
        address _dev2, // "0x2B5fF8Cba8ED3A6E7813CD5e55ecd95B87791cee" (MERP)
        uint256 _betBase, // "10000000000000000" (0.01 MATIC)
        uint256 _restartDuration, // "1209600" or two weeks
        uint256 _taxRate, //"10" over 100 or 10%
        address _airnodeRrp // ETH MAIN "0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd" POLY MAIN "0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd" POLY TEST "0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd"
        ) RrpRequesterV0(_airnodeRrp)
        ERC721("BON.Lotto.V3 Winner Voucher", "LOTTOv3"){
        erc20Token = _erc20Token;
        treasury = _treasury;
        staking = _staking;
        dev1 = _dev1;
        dev2 = _dev2;
        player1W = address(0);
        player2W = address(0);
        betBase = _betBase;
        betPrice = betBase;
        restartDuration = _restartDuration;
        restartTimer = block.timestamp;
        taxRate = _taxRate;
        counter = 0;
        lottoOpen = true;
        taxSwitch = true;
    }

    // --- PUBLIC FUNCTIONS ---

    // @Dev Returns: 0 approve, 1 player one, 2 player two, 3 error
    // @Dev Turn JS listener on on bet() call
    function bet() public payable returns(uint8 betData){
        // --- REQUIREMENTS STAGE ---
        require(lottoOpen == true, "Lotto is not accepting bets");
        require(player1W != msg.sender, "Can not bet twice");

        // --- PAYMENT STAGE ---
        uint256 payment;
        if(erc20Token == address(0)){
            // GAS PAYMENT
            require(betPrice <= msg.value, "Need more gas to pay the betPrice");
            payment = betPrice;

            // TAX
            if(taxSwitch){_sendGas(payment);}
        } else {
            // ERC20 ALLOWANCE
            uint256 userAllowance = IERC20(erc20Token).allowance(msg.sender, address(this));
            if(userAllowance < betPrice){/* END */ return betData = 0;}
            
            // ERC20 PAYMENT
            uint256 beforeBal = IERC20(erc20Token).balanceOf(address(this));
            IERC20(erc20Token).transferFrom(msg.sender, address(this), betPrice);
            payment = IERC20(erc20Token).balanceOf(address(this)) - beforeBal;

            // TAX
            if(taxSwitch){ _sendERC20(payment);}
        }
        
        // --- EVALUATE STAGE ---
        if ((player1W == address(0)) && (player2W == address(0))){
            // PLAYER'S 1 TURN
            counter++;
            player1W = msg.sender;
            pastLottoPlayer1[counter] = player1W;
            pastLottoRewards[counter] = (payment - (payment * 10 / 100)) *2;

            /* END */
            emit BetDetails(counter, pastLottoRewards[counter]);
            return betData = 1;
        } else if ((player1W != address(0)) && (player2W == address(0))){
            // PLAYER'S 2 TURN
            player2W = msg.sender;
            pastLottoPlayer2[counter] = player2W;

            // API3 QRNG CALL
            //_makeAPICall();
            // -----------------------------------------temp--------------------------------------------------
            _mint(player2W, counter);

            // RESET LOTTO
            player1W = address(0);
            player2W = address(0);
            betPrice = betPrice * 11 / 10;

            // LOTTO RESTART CHECK
            // ----------------------------------------------------------------- maybe move this out to another function
            uint256 timePast = block.timestamp - restartTimer;
            if(timePast >= restartDuration){
            restartTimer = block.timestamp;
            betPrice = betBase;
            }

            /* END */
            emit BetDetails(counter, pastLottoRewards[counter]);
            return betData = 2;
        } else {
            // ERROR
            return betData = 3;
        }
    }

    function checkLotto(uint256 _counter) public view returns(
        address winner, 
        uint256 rewards, 
        bool claimed){
        require(lottoOpen, "Lotto is not open");
        winner = ownerOf(_counter);
        rewards = pastLottoRewards[_counter];
        claimed = pastLottoClaimed[_counter];
        return (winner, rewards, claimed);
    }
    
    // @Dev Turn JS listener on on claimLotto() call
    function claimLotto(uint256 _counter) public returns(uint256 rewards){
        require(ownerOf(_counter) == msg.sender, "You do not hold the NFT bet receipt");
        require(pastLottoClaimed[_counter] != true, "This reward has already been claimed");
        require(lottoOpen, "Lotto is not open");

        pastLottoClaimed[_counter] = true;
        rewards = pastLottoRewards[_counter];
        _burn(_counter);

        if(erc20Token != address(0)){
            IERC20(erc20Token).transfer(msg.sender, rewards);
        } else {
            payable(msg.sender).transfer(rewards);
        }

        emit ClaimDetails(_counter, rewards);
        return (rewards);
    }
    
    // --- DEV FUNCTIONS ---
    function _sendERC20(uint256 _payment) internal {
        uint256 tt = _payment * taxRate / 100;
        uint256 t1 = tt * 40 / 1000;
        uint256 t2 = tt * 30 / 1000;
        uint256 t3 = tt * 15 / 1000;
        uint256 t4 = tt * 15 / 1000;
        IERC20(erc20Token).transfer(treasury, t1);
        IERC20(erc20Token).transfer(staking, t2);
        IERC20(erc20Token).transfer(dev1, t3);
        IERC20(erc20Token).transfer(dev2, t4);
    }

    function _sendGas(uint256 _payment) internal {
        uint256 tt = _payment * taxRate / 100;
        uint256 t1 = tt * 40 / 1000;
        uint256 t2 = tt * 30 / 1000;
        uint256 t3 = tt * 15 / 1000;
        uint256 t4 = tt * 15 / 1000;
        payable(treasury).transfer(t1);
        payable(staking).transfer(t2);
        payable(dev1).transfer(t3);
        payable(dev2).transfer(t4);
    }

    function resetLotto(
        address _erc20token, 
        address _treasury, 
        address _staking, 
        address _dev1, 
        address _dev2, 
        address _player1W, 
        address _player2W, 
        uint256 _betPrice, 
        uint256 _counter,
        uint256 _taxRate,
        bool _lottoOpen,
        bool _taxSwitch,
        bool _resetFunds 
        ) external onlyOwner{
        erc20Token = _erc20token;
        treasury = _treasury;
        staking = _staking;
        dev1 = _dev1;
        dev2 = _dev2;
        player1W = _player1W;
        player2W = _player2W;
        betPrice = _betPrice; 
        counter = _counter;
        taxRate = _taxRate;
        lottoOpen = _lottoOpen;
        taxSwitch = _taxSwitch;
        
        if(_resetFunds == true){
            uint256 erc20Balance = IERC20(erc20Token).balanceOf(address(this));
            if(erc20Balance > 0){
                bool transferAOne = IERC20(erc20Token).transfer(treasury, erc20Balance);
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
        //
        pastLottoAPI3CallCounter[requestId] = counter;
        emit APICallDetails(counter);
    }

    // AirnodeRrp will call back with a response
    function fulfillUint256(bytes32 requestId, bytes calldata data) external onlyAirnodeRrp{
        require(expectingRequestWithIdToBeFulfilled[requestId],"Request ID not known");
        expectingRequestWithIdToBeFulfilled[requestId] = false;
        uint256 qrngUint256 = abi.decode(data, (uint256));
        //
        uint256 requestIdCounter = pastLottoAPI3CallCounter[requestId];
        pastLottoAPI3CallResult[requestIdCounter] = qrngUint256;
        if(qrngUint256 % 2 == 0){
            _mint(pastLottoPlayer2[requestIdCounter], requestIdCounter);
            emit WinnerResults(requestIdCounter, pastLottoPlayer2[requestIdCounter]);
        } else{
            _mint(pastLottoPlayer1[requestIdCounter], requestIdCounter);
            emit WinnerResults(requestIdCounter, pastLottoPlayer1[requestIdCounter]);
        }
    }
    
    fallback() external payable{
    }
    receive() external payable{
    }
}
