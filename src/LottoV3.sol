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
    using Strings for uint256;

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

    string public baseUri = "ipfs://xxx/";
    string public baseExtension = ".json";

    mapping(uint256 => address) public pastLottoPlayer1;
    mapping(uint256 => address) public pastLottoPlayer2;
    mapping(uint256 => uint256) public pastLottoRewards;
    mapping(bytes32 => uint256) public pastLottoAPI3CallCounter;
    mapping(uint256 => uint256) public pastLottoAPI3CallResult;

    event BetDetails (uint256 playersCounter, uint256 counterReward);
    event ClaimDetails (uint256 claimedCounter, uint256 claimedRewards);
    event WinnerResults (uint256 counterNumber, address winnerWallet);


    // API3 VARS
    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorWallet;
    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

    // "0x0000000000000000000000000000000000000000"

    constructor(
        /* "0x47e53f0ddf71210f2c45dc832732aa188f78aa4f" (BON) */        address _erc20Token,
        /* xxx */                                                       address _treasury,
        /* xxx */                                                       address _staking,
        /* "0xc70C1a847EE38883179A2eC0767868257B18BD67" (s0c) */        address _dev1,
        /* "0x2B5fF8Cba8ED3A6E7813CD5e55ecd95B87791cee" (MERP) */       address _dev2,
        /* "10000000000000000" (0.01 MATIC) */                          uint256 _betBase,
        /* "1209600" or two weeks */                                    uint256 _restartDuration,
        /* "100" over 1000 or 10% */                                    uint256 _taxRate,
        /* "0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd" */              address _airnodeRrp
        ) RrpRequesterV0(_airnodeRrp)
        ERC721("BON.Lotto Winner Voucher [1]", "LOTTO"){
        erc20Token = _erc20Token;
        treasury = _treasury;
        staking = _staking;
        dev1 = _dev1;
        dev2 = _dev2;
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
    // @Dev Turn JS listener on return (1 or 2)
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
        } else {
            // ERC20 ALLOWANCE
            uint256 userAllowance = IERC20(erc20Token).allowance(msg.sender, address(this));
            if(userAllowance < betPrice){/* END */ return betData = 0;}
            
            // ERC20 PAYMENT (erc20 token tax compatible)
            uint256 beforeBal = IERC20(erc20Token).balanceOf(address(this));
            IERC20(erc20Token).transferFrom(msg.sender, address(this), betPrice);
            payment = IERC20(erc20Token).balanceOf(address(this)) - beforeBal;
        }

        // --- TAX STAGE ---
        if(taxSwitch){_sendTaxes(payment);}
        
        // --- EVALUATE STAGE ---
        if ((player1W == address(0)) && (player2W == address(0))){
            // PLAYER'S 1 TURN
            counter++;
            player1W = msg.sender;
            pastLottoPlayer1[counter] = player1W;
            uint256 paymentAfterTax = payment * taxRate / 1000;
            pastLottoRewards[counter] = (payment - paymentAfterTax) *2;

            /* END */
            emit BetDetails(counter, pastLottoRewards[counter]);
            return betData = 1;
        } else if ((player1W != address(0)) && (player2W == address(0))){
            // PLAYER'S 2 TURN
            player2W = msg.sender;
            pastLottoPlayer2[counter] = player2W;

            /*
            // API3 QRNG CALL
            _makeAPICall();
            */
            _mint(player2W, counter);


            // RESET LOTTO
            player1W = address(0);
            player2W = address(0);
            betPrice = betPrice * 11 / 10;

            // LOTTO RESTART CHECK
            uint256 timePast = block.timestamp - restartTimer;
            _checkLottoTimer(timePast);

            /* END */
            emit BetDetails(counter, pastLottoRewards[counter]);
            return betData = 2;
        } else {
            // ERROR
            return betData = 3;
        }
    }

    // @Dev Turn JS listener on returns (numb > 0)
    function claim(uint256 _counter) public returns(uint256 rewards){
        require(ownerOf(_counter) == msg.sender, "You do not hold the NFT bet receipt");
        require(lottoOpen, "Lotto is not open");

        rewards = pastLottoRewards[_counter];
        _burn(_counter);

        if(erc20Token == address(0)){
            payable(msg.sender).transfer(rewards);
        } else {
            IERC20(erc20Token).transfer(msg.sender, rewards);
        }

        emit ClaimDetails(_counter, rewards);
        return (rewards);
    }
    
    // --- DEV FUNCTIONS ---
    function _sendTaxes(uint256 _payment) internal {
        uint256 tt = _payment * taxRate / 1000;
        uint256 t1 = tt * 40 / 100;
        uint256 t2 = tt * 40 / 100;
        uint256 t3 = tt * 10 / 100;
        uint256 t4 = tt * 10 / 100;
        if(erc20Token == address(0)){
            payable(treasury).transfer(t1);
            payable(staking).transfer(t2);
            payable(dev1).transfer(t3);
            payable(dev2).transfer(t4);
        } else {
            IERC20(erc20Token).transfer(treasury, t1);
            IERC20(erc20Token).transfer(staking, t2);
            IERC20(erc20Token).transfer(dev1, t3);
            IERC20(erc20Token).transfer(dev2, t4);
        }
    }

    function _checkLottoTimer(uint256 timePast) internal{
        if(timePast >= restartDuration){
        restartTimer = block.timestamp;
        betPrice = betBase;
        }
    }

    function resetGame(
        address _player1W, 
        address _player2W, 
        uint256 _betPrice, 
        uint256 _counter
        ) external onlyOwner{
        player1W = _player1W;
        player2W = _player2W;
        betPrice = _betPrice; 
        counter = _counter;
    }

    function resetLotto(
        bool _lottoOpen,
        address _erc20token, 
        address _treasury, 
        address _staking, 
        address _dev1, 
        address _dev2, 
        uint256 _taxRate,
        bool _taxSwitch,
        bool _resetFunds 
        ) external onlyOwner{
        lottoOpen = _lottoOpen;
        erc20Token = _erc20token;
        treasury = _treasury;
        staking = _staking;
        dev1 = _dev1;
        dev2 = _dev2;
        taxRate = _taxRate;
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

    // --- NFT FUNCTIONS ---
    function setBaseUri(string memory _baseUri) external onlyOwner {
        baseUri = _baseUri;
    }

	function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
 
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }
 
    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
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
    }

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
    
    // --- OTHER ---
    fallback() external payable{
    }
    receive() external payable{
    }
}
