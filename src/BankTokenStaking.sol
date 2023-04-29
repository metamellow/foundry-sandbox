// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/* 
NOTES:
a. tokens for rewards transfered via token tax to this contract address
b. every 7 days, stakers can claim X% of Y% of rewards pool
b. X = users % of THEIR tokens staked over TOTAL staked
b. Y = adjustable % of rewards pool
c. balances held in actual amounts; minus 18 zeros for easy reading

TODO:
- MUST whitelist stakingContract on token to avoid accounting discrepencies
- send BANK to stakingContract ASAP for rewardsCalc to work
- stake as many wallets as possible to decrease the reward proportion ratio
- Add emits to EVERYTHING because this makes JS interaction way way easier; rewards timeLeft etc


*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract bonTokenStaking is Ownable{

    IERC20 public bonTokenAddress;

    uint256 public timerDuration; // "604800" == 7 days (7 * 24 * 60 * 60)
    uint256 public rwdRate; // "50" ==  5% of rwdpool
    uint256 public stakedPoolSupply;

    mapping(address => bool) public isStaked;
    mapping(address => uint256) public withdrawTimer;
    mapping(address => uint256) public stakedPoolBalances;

    event ApproveEmit(address user);
    event DepositEmit(address user, uint256 amountDeposited, uint256 userBalance);
    event WithdrawEmit(address user, uint256 userBalance, uint256 userReward);

    constructor(
        address _bonTokenAddress, 
        uint256 _timerDuration, 
        uint256 _rwdRate){
        bonTokenAddress = IERC20(_bonTokenAddress);
        timerDuration = _timerDuration;
        rwdRate = _rwdRate;
    }
    
    function calculateRewards(address _user) public view returns (uint256) {
        require(isStaked[_user], "This address has not staked");
        uint256 totalTokenBalance = IERC20(bonTokenAddress).balanceOf(address(this));
        uint256 rwdPoolSupply = totalTokenBalance - stakedPoolSupply;
        uint256 userBalance = stakedPoolBalances[_user];
        uint256 rwdPoolAftrRate = (rwdPoolSupply * rwdRate / 1000); // remove brackets?
        uint256 userRewardsAmount =  rwdPoolAftrRate * userBalance / stakedPoolSupply;
        //require(userRewardsAmount > 0, "ERROR: Reward can not be zero");
        //this would lock stakers in after a pool close
        return userRewardsAmount;
    }

    function calculateTime(address _user) public view returns (uint256) {
        require(isStaked[_user], "This address has not staked");
        uint256 timeElapsed = block.timestamp - withdrawTimer[_user];
        return timeElapsed;
    }

    function depositToStaking(uint256 _amount) public{
        require(_amount > 0, "Deposit must be > 0");
        // all users must APPROVE staking contract to use erc20 before v-this-v can work
        bool success = IERC20(bonTokenAddress).transferFrom(msg.sender, address(this), _amount);
        require(success == true, "transfer failed!");
        
        isStaked[msg.sender] = true;
        withdrawTimer[msg.sender] = block.timestamp;
        stakedPoolBalances[msg.sender] += _amount;
        stakedPoolSupply += _amount;

        emit DepositEmit(msg.sender, _amount, stakedPoolBalances[msg.sender]);
    }


    function withdrawAll() public{
        require(isStaked[msg.sender], "This address has not staked");

        uint256 userBalance = stakedPoolBalances[msg.sender];
        uint256 userReward = calculateRewards(msg.sender);
        uint256 timeElapsed = calculateTime(msg.sender);

        require(userBalance > 0, 'insufficient balance');
        require(userReward > 0, 'insufficient reward');
        require(timeElapsed >= timerDuration, 'Minimum required staking time not met');

        delete isStaked[msg.sender];
        delete withdrawTimer[msg.sender];
        delete stakedPoolBalances[msg.sender];
        stakedPoolSupply -= userBalance;

        bool success = IERC20(bonTokenAddress).transfer(msg.sender, userBalance + userReward);
        require(success == true, "transfer failed!");

        emit WithdrawEmit(msg.sender, userBalance, userReward);
    }

    function withdrawRewards() public{
        require(isStaked[msg.sender], "This address has not staked");

        uint256 userBalance = stakedPoolBalances[msg.sender];
        uint256 userReward = calculateRewards(msg.sender);
        uint256 timeElapsed = calculateTime(msg.sender);

        require(userBalance > 0, 'insufficient balance');
        require(userReward > 0, 'insufficient reward');
        require(timeElapsed >= timerDuration, 'Minimum required staking time not met');

        withdrawTimer[msg.sender] = block.timestamp;

        bool success = IERC20(bonTokenAddress).transfer(msg.sender, userReward);
        require(success == true, "transfer failed!");

        emit WithdrawEmit(msg.sender, userBalance, userReward);
    }

    //onlyOwners
    function setTimer(uint256 _time) external onlyOwner {
        timerDuration = _time;
    }

    function setRate(uint256 _rwdRate) external onlyOwner {
        require(_rwdRate > 0 && _rwdRate < 1000, "Rate must be > 0 and < 1000");
        rwdRate = _rwdRate;
    }

    function setTokenAddress(address _newTokenAddress) external onlyOwner {
        bonTokenAddress = IERC20(_newTokenAddress);
    }

    function closeRewardsPool() external payable onlyOwner {
        uint256 tokenBalance = IERC20(bonTokenAddress).balanceOf(address(this));
        uint256 gasBalance = address(this).balance;
        if(tokenBalance > 0){
            bool success1 = IERC20(bonTokenAddress).transfer(msg.sender, tokenBalance - stakedPoolSupply);
            require(success1 == true, "transfer failed!");
        }
        if(gasBalance > 0){
            (bool success2,) = payable(msg.sender).call{value: gasBalance}("");
            require(success2 == true, "transfer failed!");
        }
    }
}
