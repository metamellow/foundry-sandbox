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
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";

contract LottoV3 is Ownable, RrpRequesterV0 {
    
    // LOTTO VARS
    address private treasury;
    address private dev1;
    address private dev2;
    address public erc20Token;  // 0x47e53f0ddf71210f2c45dc832732aa188f78aa4f
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
    event ApprovalDetails (bool approvalSuccess);

    // API3 VARS
    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorWallet;
    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

    constructor(
        address _erc20Token,
        address _treasury,
        address _dev1,
        address _dev2,
        uint256 _betPrice,
        address _airnodeRrp            // ETH MAIN (0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd) POLY MAIN (0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd) POLY TEST (0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd)
        ) RrpRequesterV0(_airnodeRrp){
        erc20Token = _erc20Token;
        treasury = _treasury;
        dev1 = _dev1;
        dev2 = _dev2;
        player1W = address(0);
        player2W = address(0);
        betPrice = _betPrice;
        counter = 0;
        lottoOpen = true;
        taxSwitch = true;
    }

    // --- PUBLIC FUNCTIONS ---

    function bet() public payable{
        // --- REQUIREMENTS STAGE ---
        require(lottoOpen == true, "Lotto is not accepting bets");
        require(player1W != msg.sender, "Can not bet twice");

        // --- PAYMENT STAGE ---
        if(erc20Token != address(0)){
            // ERC20 PAYMENT
            uint256 userAllowance = IERC20(erc20Token).allowance(msg.sender, address(this));
            if(userAllowance < betPrice){
                _approveERC20Tokens();
                return;
            }
            IERC20(erc20Token).transferFrom(msg.sender, address(this), betPrice);
            if(taxSwitch == true){_sendERC20Taxes();}
        } else {
            // GAS PAYMENT
            require(betPrice <= msg.value, "Need more gas to pay the betPrice");
            if(taxSwitch == true){_sendGasTaxes();}
        }
        
        // --- EVALUATE STAGE ---
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
        if(erc20Token != address(0)){
            IERC20(erc20Token).transfer(msg.sender, rewards);
        } else {
            (bool transfer1, )  = payable(msg.sender).call{value: rewards}("rewards");
            require(transfer1, "Transfer failed");
        }

        emit ClaimDetails(_counter, rewards);
        return (rewards);
    }
    
    // --- DEV FUNCTIONS ---
    function _approveERC20Tokens() internal {
        uint256 totalAmount = IERC20(erc20Token).totalSupply();
        if (IERC20(erc20Token).approve(address(this), totalAmount)) {
            emit ApprovalDetails(true);
        } else {
            emit ApprovalDetails(false);
        }
    }

    function _sendERC20Taxes() internal{
        uint256 tax1 = betPrice * 6 / 100;
        uint256 tax2 = betPrice * 2 / 100;
        uint256 tax3 = betPrice * 2 / 100;
        IERC20(erc20Token).transfer(treasury, tax1);
        IERC20(erc20Token).transfer(dev1, tax2);
        IERC20(erc20Token).transfer(dev2, tax3);
    }

    function _sendGasTaxes() internal{
        uint256 tax1 = betPrice * 6 / 100;
        uint256 tax2 = betPrice * 2 / 100;
        uint256 tax3 = betPrice * 2 / 100;
        payable(treasury).transfer(tax1);
        payable(dev1).transfer(tax2);
        payable(dev2).transfer(tax3);
    }
    
    function resetLotto(
        address _erc20token, 
        address _treasury, 
        address _dev1, 
        address _dev2, 
        address _player1W, 
        address _player2W, 
        uint256 _betPrice, 
        uint256 _counter,
        bool _lottoOpen,
        bool _taxSwitch,
        bool _resetFunds 
        ) external onlyOwner{
        erc20Token = _erc20token;
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