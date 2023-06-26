// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/LottoV2.sol";

contract contractTest is Test {
    LottoV2 public lotto;

    function setUp() public{
        // --- WALLETS ---
        vm.startPrank(address(69));
        address[] memory testAddresses = new address[](3);
            testAddresses[0] = address(10001); // ad1
            testAddresses[1] = address(10002); // ad2
            testAddresses[2] = address(10003); // ad3

        // --- TOKENS ---
        vm.deal(address(69), 1_000_000 ether);
        
        // --- CONTRACTS ---
        lotto = new LottoV2(
            "0xb1a23cD1dcB4F07C9d766f2776CAa81d33fa0Ede",
            248400, //69 hours
            420, //percent of pool
            50, //burn rate
            true, //burn on
            true //pool open
        );

        // --- NEED TODOs AFTER DEPLOY ---
        token.transfer(address(staking), 30_000_000_000 ether); // put some tokens in the pool
        staking.setStakingOpen(true); // open the pool for deposits
    }

    function reuseable_ConsolLogs() public view{
        console.log("_____________________TOKENS_INFOM_____________________");
        console.log("TOKN ADDR: ", address(token));
        console.log("TOKN TSUP: ", ERC20(token).totalSupply());
        console.log("STKG ADDR: ", address(staking));
        console.log("STKG TBAL: ", ERC20(token).balanceOf(address(staking)));
        console.log("STKG SKPL: ", staking.stakedPoolSupply());

        console.log("_____________________WALLET_INFOM_____________________");
        console.log("OWRW TBAL: ", token.balanceOf(address(69)));
        console.log("TAXW TBAL: ", token.balanceOf(address(420)));
        console.log("AD1W TBAL: ", token.balanceOf(address(10001)));
        console.log("AD2W TBAL: ", token.balanceOf(address(10002)));
        console.log("AD3W TBAL: ", token.balanceOf(address(10003)));
    }

    function testFail_0xSetUpLogs() public{
        reuseable_ConsolLogs();
        assertFalse(0 == 0);
    }
    

    function reuseable_depositToStaking() public{
        console.log("_____________________DEPST_INFOM_____________________");
        vm.stopPrank();
        vm.startPrank(address(10001));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(1_000_000_000 ether);
        console.log("AD1W RWRD: ", staking.calculateRewards(address(10001)));
        console.log("AD1W TIME: ", staking.calculateTime(address(10001)));

        vm.stopPrank();
        vm.startPrank(address(10002));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(1_000_000_000 ether);
        console.log("AD2W RWRD: ", staking.calculateRewards(address(10002)));
        console.log("AD2W TIME: ", staking.calculateTime(address(10002)));

        vm.stopPrank();
        vm.startPrank(address(10003));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(1_000_000_000 ether);
        console.log("AD3W RWRD: ", staking.calculateRewards(address(10003)));
        console.log("AD3W TIME: ", staking.calculateTime(address(10003)));
    }

    function test_1_depositToStaking() public{
        reuseable_depositToStaking();
        reuseable_ConsolLogs();
    }

    function reusable_withdrawAllRewardsFrom3ADwallets() public{
        console.log("_____________________WTRWD_INFOM_____________________");
        vm.warp(248401);
        vm.stopPrank();
        vm.startPrank(address(10001));
        console.log("AD1W RWRD: ", staking.calculateRewards(address(10001)));
        console.log("AD1W TIME: ", staking.calculateTime(address(10001)));
        staking.withdrawRewards();

        vm.warp(248402);
        vm.stopPrank();
        vm.startPrank(address(10002));
        console.log("AD2W RWRD: ", staking.calculateRewards(address(10002)));
        console.log("AD2W TIME: ", staking.calculateTime(address(10002)));
        staking.withdrawRewards();

        vm.warp(248403);
        vm.stopPrank();
        vm.startPrank(address(10003));
        console.log("AD3W RWRD: ", staking.calculateRewards(address(10003)));
        console.log("AD3W TIME: ", staking.calculateTime(address(10003)));
        staking.withdrawRewards();
    }

    function test_2_withdrawRewards() public{
        reuseable_depositToStaking();
        reusable_withdrawAllRewardsFrom3ADwallets();
        reuseable_ConsolLogs();
    }

    function reusable_withdrawAllfrom3ADwallets() public{
        console.log("_____________________WTALL_INFOM_____________________");
        vm.stopPrank();
        vm.startPrank(address(10001));
        console.log("AD1W RWRD: ", staking.calculateRewards(address(10001)));
        console.log("AD1W TIME: ", staking.calculateTime(address(10001)));
        staking.withdrawAll();

        vm.stopPrank();
        vm.startPrank(address(10002));
        console.log("AD2W RWRD: ", staking.calculateRewards(address(10002)));
        console.log("AD2W TIME: ", staking.calculateTime(address(10002)));
        staking.withdrawAll();

        vm.stopPrank();
        vm.startPrank(address(10003));
        console.log("AD3W RWRD: ", staking.calculateRewards(address(10003)));
        console.log("AD3W TIME: ", staking.calculateTime(address(10003)));
        staking.withdrawAll();
    }
    
    function test_3_withdrawAll() public{
        reuseable_depositToStaking();
        reusable_withdrawAllRewardsFrom3ADwallets();
        reusable_withdrawAllfrom3ADwallets();
        reuseable_ConsolLogs();
    }


// test a nonburnable token
}