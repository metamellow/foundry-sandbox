// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.- BANK OF NOWHERE $BANK STAKING POOL v0.1 -.-.-. */
/* -.-.-.-.-.    [[ BUILT BY METAMELLOW ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

/* .---------------------- setup ---------------------. //
- (1) 
// .--------------------------------------------------. */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract bankTokenStaking is ERC20, Ownable{

    IERC20 public bankTokenAddress;

    uint256 public timerDuration;
    uint256 public rwdRate;
    uint256 public stakedPoolSupply;
    bool public stakingOpen;

    mapping(address => bool) public isStaked;
    mapping(address => uint256) public withdrawTimer;
    mapping(address => uint256) public stakedPoolBalances;

    event DepositEmit(address user, uint256 amountDeposited, uint256 userBalance);
    event WithdrawEmit(address user, uint256 userBalance);
    event RewardsEmit(address user, uint256 userBalance, uint256 userReward);

    constructor(
        address _bankTokenAddress, 
        uint256 _timerDuration, 
        uint256 _rwdRate) 
        ERC20("BANK Staking", "stkBANK"){
        bankTokenAddress = IERC20(_bankTokenAddress);
        timerDuration = _timerDuration;
        rwdRate = _rwdRate;
        stakingOpen = false;
    }
    
    function calculateRewards(address _user) public view returns (uint256) {
        require(stakingOpen == true, "Staking pool is closed");
        require(isStaked[_user], "This address has not staked");
        uint256 totalTokenBalance = IERC20(bankTokenAddress).balanceOf(address(this));
        uint256 rwdPoolSupply = totalTokenBalance - stakedPoolSupply;
        uint256 rwdPoolAftrRate = rwdPoolSupply * rwdRate / 1000;
        uint256 userBalance = stakedPoolBalances[_user];
        uint256 userRewardsAmount =  rwdPoolAftrRate * userBalance / stakedPoolSupply;
        return userRewardsAmount;
    }

    function calculateTime(address _user) public view returns (uint256) {
        require(isStaked[_user], "This address has not staked");
        uint256 timeElapsed = block.timestamp - withdrawTimer[_user];
        return timeElapsed;
    }

    function depositToStaking(uint256 _amount) public{
        require(stakingOpen == true, "Staking pool is closed");
        require(_amount > 0, "Deposit must be > 0");
        // all users must APPROVE staking contract to use erc20 before v-this-v can work
        bool success = IERC20(bankTokenAddress).transferFrom(msg.sender, address(this), _amount);
        require(success == true, "transfer failed!");
        
        isStaked[msg.sender] = true;
        withdrawTimer[msg.sender] = block.timestamp;
        stakedPoolBalances[msg.sender] += _amount;
        stakedPoolSupply += _amount;

        _mint(msg.sender, _amount); //stkBANK

        emit DepositEmit(msg.sender, _amount, stakedPoolBalances[msg.sender]);
    }

    function withdrawAll() public{
        require(isStaked[msg.sender], "This address has not staked");

        uint256 userBalance = stakedPoolBalances[msg.sender];
        require(userBalance > 0, 'insufficient balance');
        
        uint256 timeElapsed = calculateTime(msg.sender);
        require(timeElapsed < timerDuration, 'withdraw rewards first');

        delete isStaked[msg.sender];
        delete withdrawTimer[msg.sender];
        delete stakedPoolBalances[msg.sender];
        stakedPoolSupply -= userBalance;

        bool success = IERC20(bankTokenAddress).transfer(msg.sender, userBalance);
        require(success == true, "transfer failed!");

        _burn(msg.sender, userBalance); //stkBANK

        emit WithdrawEmit(msg.sender, userBalance);
    }

    function withdrawRewards() public{
        require(stakingOpen == true, "Staking pool is closed");
        require(isStaked[msg.sender], "This address has not staked");
        
        uint256 timeElapsed = calculateTime(msg.sender);
        require(timeElapsed >= timerDuration, 'Minimum required staking time not met');

        uint256 userBalance = stakedPoolBalances[msg.sender];
        require(userBalance > 0, 'insufficient balance');

        uint256 userReward = calculateRewards(msg.sender);
        require(userReward > 0, 'insufficient reward');
        
        withdrawTimer[msg.sender] = block.timestamp;
        bool success = IERC20(bankTokenAddress).transfer(msg.sender, userReward);
        require(success == true, "transfer failed!");

        emit RewardsEmit(msg.sender, userBalance, userReward);
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
        bankTokenAddress = IERC20(_newTokenAddress);
    } 

    function setStakingOpen(bool _trueOrFalse) external onlyOwner {
        stakingOpen =  _trueOrFalse;
    } 
    
    function closeRewardsPool() external payable onlyOwner {
        uint256 tokenBalance = IERC20(bankTokenAddress).balanceOf(address(this));
        uint256 gasBalance = address(this).balance;
        if(tokenBalance > 0){
            bool success1 = IERC20(bankTokenAddress).transfer(msg.sender, tokenBalance - stakedPoolSupply);
            require(success1 == true, "transfer failed!");
        }
        if(gasBalance > 0){
            (bool success2,) = payable(msg.sender).call{value: gasBalance}("");
            require(success2 == true, "transfer failed!");
        }
    }

    // stkBANK overrides
    function transfer(address to, uint256 amount) public override onlyOwner returns (bool success) {
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override onlyOwner returns (bool success) {
        return super.transferFrom(from, to, amount);
    }
}
