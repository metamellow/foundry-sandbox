// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/BankTokenStaking.sol";
import "../src/BankToken.sol";

contract contractTest is Test {
    bankTokenStaking public staking;
    bankToken public token;

    function setUp() public{
        // --- WALLETS ---
        vm.startPrank(address(69));
        address[] memory testAddresses = new address[](3);
            testAddresses[0] = address(10001); // vvvvv all BONNFT holders
            testAddresses[1] = address(10002); //
            testAddresses[2] = address(10003); // ...

        // --- TOKENS ---
        vm.deal(address(69), 1_000_000 ether);
        
        // --- CONTRACTS ---
        token = new bankToken(
            "Bank of Nowhere", 
            "BANK", 
            address(70), // treasury
            address(71), // staker (swapped to contract address below)
            address(72), // dev
            4, 
            testAddresses
        );

        staking = new bankTokenStaking(
            address(token),
            604800,
            50
        );
        token.setStakersAddress(address(staking));
        token.setWhitelistAddress(address(staking));
        // add some seed tokens
    }

    // deposit to staking
    function test_1depositToStaking() public{
        // --- setup stuff ---
        ERC20(address(token)).transfer(address(700), 50000000000000000000000);
        ERC20(address(token)).transfer(address(701), 50000000000000000000000);
        ERC20(address(token)).transfer(address(staking), 69000000000000000000000); //get a little fake tax in there
        staking.setStakingOpen(true); // turn on/off to test lock
        
        // --- start testing here ---
        vm.stopPrank();
        vm.startPrank(address(700));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        console.log("ADDR700 B4sTK BAL: ", ERC20(token).balanceOf(address(700)));
        staking.depositToStaking(10000000000000000000000);
        vm.warp(696969); //8 days
       
        console.log("ADDR700 AFTsTK BAL: ", ERC20(token).balanceOf(address(700)));
        console.log("STKD SUPPL: ", staking.stakedPoolSupply());
        console.log("STK CNT TOTAL erc20 BAL: ", ERC20(token).balanceOf(address(staking)));
        console.log("ADDR700 isSTKed: ", staking.isStaked(address(700)));
        console.log("ADDR700 STKD AMT: ", staking.stakedPoolBalances(address(700)));
        console.log("ADDR700 STKD TME: ", staking.withdrawTimer(address(700)));
        console.log("ADDR700 calcTME: ", staking.calculateTime(address(700)));
        console.log("ADDR700 calcRWD: ", staking.calculateRewards(address(700)));

        vm.stopPrank();
        vm.startPrank(address(701));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(10000000000000000000000);
        vm.warp(1696969);
        console.log("ADDR700 calcRWD +STK: ", staking.calculateRewards(address(700)));
    }

    // withdraw all staked tokens
    function test_2withdrawAll() public{
        // --- setup stuff ---
        ERC20(address(token)).transfer(address(700), 50000000000000000000000);
        ERC20(address(token)).transfer(address(701), 50000000000000000000000);
        ERC20(address(token)).transfer(address(staking), 69000000000000000000000); //get a little fake tax in there
        staking.setStakingOpen(true); // turn on/off to test lock
        
        vm.stopPrank();
        vm.startPrank(address(700));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(10000000000000000000000);
        
        vm.stopPrank();
        vm.startPrank(address(701));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(10000000000000000000000);

        console.log("STKD SUPPL b4: ", staking.stakedPoolSupply());
        console.log("STK CNT TOTAL erc20 BAL b4: ", ERC20(token).balanceOf(address(staking)));
        console.log("ADDR700 TOTAL erc20 BAL b4: ", ERC20(token).balanceOf(address(700)));
        console.log("ADDR701 TOTAL erc20 BAL b4: ", ERC20(token).balanceOf(address(701)));
        console.log("ADDR700 STKD AMT b4: ", staking.stakedPoolBalances(address(700)));
        console.log("ADDR701 STKD AMT b4: ", staking.stakedPoolBalances(address(701)));
        
        // --- start testing stuff ---
        //vm.warp(696969); (test toggle)
        
        vm.stopPrank();
        vm.startPrank(address(700));
        staking.withdrawAll();

        vm.stopPrank();
        vm.startPrank(address(701));
        staking.withdrawAll();

        console.log("STKD SUPPL af: ", staking.stakedPoolSupply());
        console.log("STK CNT TOTAL erc20 BAL af: ", ERC20(token).balanceOf(address(staking)));
        console.log("ADDR700 TOTAL erc20 BAL af: ", ERC20(token).balanceOf(address(700)));
        console.log("ADDR701 TOTAL erc20 BAL af: ", ERC20(token).balanceOf(address(701)));
        console.log("ADDR700 STKD AMT af: ", staking.stakedPoolBalances(address(700)));
        console.log("ADDR701 STKD AMT af: ", staking.stakedPoolBalances(address(701)));
    }

        // withdraw rewards
    function test_2withdrawRewards() public{
        // --- setup stuff ---
        ERC20(address(token)).transfer(address(700), 50000000000000000000000);
        ERC20(address(token)).transfer(address(701), 50000000000000000000000);
        ERC20(address(token)).transfer(address(staking), 69000000000000000000000); //get a little fake tax in there
        staking.setStakingOpen(true); // turn on/off to test lock
        
        vm.stopPrank();
        vm.startPrank(address(700));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(10000000000000000000000);
        
        vm.stopPrank();
        vm.startPrank(address(701));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(10000000000000000000000);

        vm.warp(696969); // (test toggle)

        console.log("STKD SUPPL b4: ", staking.stakedPoolSupply());
        console.log("STK CNT TOTAL erc20 BAL b4: ", ERC20(token).balanceOf(address(staking)));
        console.log("ADDR700 TOTAL erc20 BAL b4: ", ERC20(token).balanceOf(address(700)));
        console.log("ADDR701 TOTAL erc20 BAL b4: ", ERC20(token).balanceOf(address(701)));
        console.log("ADDR700 STKD AMT b4: ", staking.stakedPoolBalances(address(700)));
        console.log("ADDR701 STKD AMT b4: ", staking.stakedPoolBalances(address(701)));
        console.log("ADDR700 calcRWD: b4", staking.calculateRewards(address(700)));
        console.log("ADDR701 calcRWD: b4", staking.calculateRewards(address(701)));
        console.log("ADDR700 calcTME b4: ", staking.calculateTime(address(700)));
        console.log("ADDR701 calcTME b4: ", staking.calculateTime(address(701)));

        // --- start testing stuff ---
        vm.stopPrank();
        vm.startPrank(address(700));
        staking.withdrawRewards();

        vm.stopPrank();
        vm.startPrank(address(701));
        staking.withdrawRewards();

        console.log("STKD SUPPL af: ", staking.stakedPoolSupply());
        console.log("STK CNT TOTAL erc20 BAL af: ", ERC20(token).balanceOf(address(staking)));
        console.log("ADDR700 TOTAL erc20 BAL af: ", ERC20(token).balanceOf(address(700)));
        console.log("ADDR701 TOTAL erc20 BAL af: ", ERC20(token).balanceOf(address(701)));
        console.log("ADDR700 STKD AMT af: ", staking.stakedPoolBalances(address(700)));
        console.log("ADDR701 STKD AMT af: ", staking.stakedPoolBalances(address(701)));
        console.log("ADDR700 calcRWD: af", staking.calculateRewards(address(700)));
        console.log("ADDR700 calcTME af: ", staking.calculateTime(address(700)));
        console.log("ADDR701 calcTME af: ", staking.calculateTime(address(701)));
    }
    
    // only owners
    function test_3onlyOwners() public{
        // --- set up ---
        console.log("P0 TIMER DUR: ", staking.timerDuration());
        console.log("P0 RWD RATE: ", staking.rwdRate());

        // --- test ---
        staking.setTimer(694200);
        staking.setRate(69);
        staking.setTokenAddress(address(420));
        console.log("P1 TIMER DUR: ", staking.timerDuration());
        console.log("P1 RWD RATE: ", staking.rwdRate());
    }

    // close pool
    function test_4closePool() public{
        // --- setup stuff ---
        vm.deal(address(staking), 69_420 ether);
        ERC20(address(token)).transfer(address(700), 50000000000000000000000);
        ERC20(address(token)).transfer(address(701), 50000000000000000000000);
        ERC20(address(token)).transfer(address(staking), 69000000000000000000000); //get a little fake tax in there
        staking.setStakingOpen(true); // turn on/off to test lock

        vm.stopPrank();
        vm.startPrank(address(700));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(10000000000000000000000);

        vm.stopPrank();
        vm.startPrank(address(701));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(10000000000000000000000);
        
        vm.warp(696969);

        console.log("P0 STKD SUPPL: ", staking.stakedPoolSupply());
        console.log("P0 STK CNT TOTAL erc20 BAL: ", ERC20(token).balanceOf(address(staking)));
        console.log("P0 ADDR069 TOTAL erc20 BAL: ", ERC20(token).balanceOf(address(69)));
        console.log("P0 STK CNT TOTAL gas BAL: ", address(staking).balance);
        console.log("P0 ADDR069 TOTAL gas BAL: ", address(69).balance);
        console.log("P0 ADDR700 TOTAL erc20 BAL: ", ERC20(token).balanceOf(address(700)));
        console.log("P0 ADDR701 TOTAL erc20 BAL: ", ERC20(token).balanceOf(address(701)));
        console.log("P0 ADDR700 STKD AMT: ", staking.stakedPoolBalances(address(700)));
        console.log("P0 ADDR701 STKD AMT: ", staking.stakedPoolBalances(address(701)));
        
        // --- start testing ---
        vm.stopPrank();
        vm.startPrank(address(69));
        staking.closeRewardsPool();

        console.log("P1 STKD SUPPL: ", staking.stakedPoolSupply());
        console.log("P1 STK CNT TOTAL erc20 BAL: ", ERC20(token).balanceOf(address(staking)));
        console.log("P1 ADDR069 TOTAL erc20 BAL: ", ERC20(token).balanceOf(address(69)));
        console.log("P1 STK CNT TOTAL gas BAL: ", address(staking).balance);
        console.log("P1 ADDR069 TOTAL gas BAL: ", address(69).balance);
        console.log("P1 ADDR700 TOTAL erc20 BAL: ", ERC20(token).balanceOf(address(700)));
        console.log("P1 ADDR701 TOTAL erc20 BAL: ", ERC20(token).balanceOf(address(701)));
        console.log("P1 ADDR700 STKD AMT: ", staking.stakedPoolBalances(address(700)));
        console.log("P1 ADDR701 STKD AMT: ", staking.stakedPoolBalances(address(701)));
    }

    // withdraw all staked tokens
    function test_5stkBANKTest() public{
        // --- setup stuff ---
        ERC20(address(token)).transfer(address(700), 50000000000000000000000);
        ERC20(address(token)).transfer(address(701), 50000000000000000000000);
        ERC20(address(token)).transfer(address(staking), 69000000000000000000000); //get a little fake tax in there
        staking.setStakingOpen(true); // turn on/off to test lock
        
        vm.stopPrank();
        vm.startPrank(address(700));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(10000000000000000000000);
        
        vm.stopPrank();
        vm.startPrank(address(701));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(10000000000000000000000);

        console.log("stkBANK name: ", ERC20(staking).name());
        console.log("stkBANK symbol: ", ERC20(staking).symbol());
        console.log("stkBANK symbol: ", ERC20(staking).totalSupply());
        console.log("ADDR700 stkBANK: ", ERC20(staking).balanceOf(address(700)));
        console.log("ADDR701 stkBANK: ", ERC20(staking).balanceOf(address(701)));

        /*
        //to test transfer block 
        staking.transfer(address(700), 5000000000000000000000);
        console.log("ADDR700 stkBANK: ", ERC20(staking).balanceOf(address(700)));
        console.log("ADDR701 stkBANK: ", ERC20(staking).balanceOf(address(701)));
        */
        
        // --- start testing stuff ---
        //vm.warp(696969); (test toggle)
        
        vm.stopPrank();
        vm.startPrank(address(700));
        staking.withdrawAll();

        vm.stopPrank();
        vm.startPrank(address(701));
        staking.withdrawAll();

        console.log("stkBANK symbol: ", ERC20(staking).totalSupply());
        console.log("ADDR700 stkBANK: ", ERC20(staking).balanceOf(address(700)));
        console.log("ADDR701 stkBANK: ", ERC20(staking).balanceOf(address(701)));
    }
}