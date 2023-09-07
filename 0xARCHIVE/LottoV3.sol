// SPDX-License-Identifier: GNU-3.0
pragma solidity ^0.8.0;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.   BANK OF NOWHERE LOTTO  V3.01  .-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY REBEL LABS ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

/* PS. We love you all! Stay happy, healthy, and wealthy!*/

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

    string public baseUri = "ipfs://bafybeiep3p2qvgvxnivrihmkvmfnphg2md3xntsvp63dzxfcekehblles4/";
    string public baseExtension = ".json";

    mapping(uint256 => address) public pastLottoPlayer1;
    mapping(uint256 => address) public pastLottoPlayer2;
    mapping(uint256 => uint256) public pastLottoRewards;
    mapping(bytes32 => uint256) public pastLottoAPI3CallCounter;

    event BetDetails (
        uint256 bd_counter,
        address bd_wallet,
        uint256 bd_reward
    );
    event ClaimDetails (
        uint256 cd_counter, 
        address cd_wallet, 
        uint256 cd_rewards
    );
    event WinnerDetails (
        uint256 wd_counter, 
        address wd_playerOne, 
        address wd_playerTwo, 
        address wd_winner, 
        uint256 wd_winAmount,
        uint256 wd_qrng
    );

    // API3 VARS
    address public airnode;
    bytes32 public endpointIdUint256;
    address public sponsorWallet;
    mapping(bytes32 => bool) public expectingRequestWithIdToBeFulfilled;

    constructor(
        address _erc20Token,
        address _treasury,
        address _staking,
        address _dev1,
        address _dev2,
        uint256 _betBase,
        uint256 _restartDuration,
        uint256 _taxRate,
        address _airnodeRrp
        ) RrpRequesterV0(_airnodeRrp)
        ERC721("BON.Lotto - Infinity Winner", "LOTTO"){
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
        counter = 1;
        lottoOpen = true;
        taxSwitch = true;
    }

    // --- PUBLIC FUNCTIONS ---

    function bet() public payable {
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
            // ERC20 PAYMENT
            uint256 beforeBal = IERC20(erc20Token).balanceOf(address(this));
            IERC20(erc20Token).transferFrom(msg.sender, address(this), betPrice);
            payment = IERC20(erc20Token).balanceOf(address(this)) - beforeBal;
        }

        // --- TAX STAGE ---
        if(taxSwitch){_sendTaxes(payment);}
        
        // --- EVALUATE STAGE ---
        if ((player1W == address(0)) && (player2W == address(0))){
            // PLAYER'S 1 TURN
            player1W = msg.sender;
            pastLottoPlayer1[counter] = player1W;
            uint256 paymentAfterTax = payment * taxRate / 1000;
            pastLottoRewards[counter] = (payment - paymentAfterTax) *2;

            /* END */
            emit BetDetails(counter, msg.sender, pastLottoRewards[counter]);

        } else if ((player1W != address(0)) && (player2W == address(0))){
            // PLAYER'S 2 TURN
            player2W = msg.sender;
            pastLottoPlayer2[counter] = player2W;
            _makeAPICall();

            // UPDATE LOTTO
            counter++;
            player1W = address(0);
            player2W = address(0);
            betPrice = betPrice * 12 / 10;
            _checkRestartTimer();

            /* END */
            uint256 ctr = counter-1;
            emit BetDetails(ctr, msg.sender, pastLottoRewards[ctr]);
        }
    }

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

        emit ClaimDetails(_counter, msg.sender, rewards);
    }
    
    // --- DEV FUNCTIONS ---
    function _sendTaxes(uint256 _payment) internal {
        uint256 tt = _payment * taxRate / 1000;
        uint256 t1 = tt * 50 / 100;
        uint256 t2 = tt * 40 / 100;
        uint256 t3 = tt * 5 / 100;
        uint256 t4 = tt * 5 / 100;
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

    function _checkRestartTimer() internal{
        uint256 timePast = block.timestamp - restartTimer;
        if(timePast >= restartDuration){
            restartTimer = block.timestamp;
            betPrice = betBase;
        }
    }

    function resetGame(
        address _player1W, 
        address _player2W, 
        uint256 _betPrice, 
        uint256 _betBase, 
        uint256 _counter,
        uint256 _restartDuration,
        uint256 _restartTimer
        ) external onlyOwner{
        player1W = _player1W;
        player2W = _player2W;
        betPrice = _betPrice; 
        betBase = _betBase;
        counter = _counter;
        restartDuration = _restartDuration;
        restartTimer = _restartTimer;
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
                IERC20(erc20Token).transfer(treasury, erc20Balance);
            }
            uint256 gasBalance = address(this).balance;
            if(gasBalance > 0){
                payable(treasury).transfer(gasBalance);
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
        address _airnode,
        bytes32 _endpointIdUint256,
        address _sponsorWallet
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
        address winner;
        if(qrngUint256 % 2 == 0){winner = pastLottoPlayer2[requestIdCounter];}
        else {winner = pastLottoPlayer1[requestIdCounter];}
        _mint(winner, requestIdCounter);
        emit WinnerDetails(
            requestIdCounter, 
            pastLottoPlayer1[requestIdCounter], 
            pastLottoPlayer2[requestIdCounter], 
            winner, 
            pastLottoRewards[requestIdCounter],
            qrngUint256
        );
    }
    
    // --- OTHER ---
    fallback() external payable{
    }
    receive() external payable{
    }
}
