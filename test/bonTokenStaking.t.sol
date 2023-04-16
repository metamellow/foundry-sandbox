// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/BonTokenStaking.sol";
import "../src/BonToken.sol";

contract contractTest is Test {
    bonTokenStaking public staking;
    bonToken public token;

    function setUp() public{
        // --- WALLETS ---
        vm.startPrank(address(69));
        address[] memory testAddresses = new address[](3);
            testAddresses[0] = address(70);
            testAddresses[1] = address(71);
            testAddresses[2] = address(72);

        // --- TOKENS ---
        vm.deal(address(69), 1_000_000 ether);
        
        // --- CONTRACTS ---
        token = new bonToken(
            "BON GOVERNANCE TOKEN", 
            "BANK", 
            address(70), 
            address(71), 
            address(72), 
            4, 
            testAddresses
        );

        staking = new bonTokenStaking(
            address(token),
            604800,
            50
        );
        token.setWhitelistAddress(address(staking));
        // add some seed tokens
    }

    function testFail_0xSetUpLogs() public{
        console.log("MSG.SENDER: ", address(msg.sender));
        console.log("CNRT ADDR: ", address(staking));
        console.log("TIMER DUR: ", staking.timerDuration());
        console.log("RWD RATE: ", staking.rwdRate());
        console.log("STKD SUPPL: ", staking.stakedPoolSupply());
        console.log("TKN ADDR: ", address(token));
        console.log("STKR CNT WHTLSTD ON TKN: ", token.whitelistedAddress(address(staking)));
        console.log("OWNR: ", token.owner());
        console.log("OWNR BAL: ", ERC20(token).balanceOf(address(69)));
        console.log("TRES: ", token.bonTreasury());
        console.log("TRES BAL: ", ERC20(token).balanceOf(address(70)));
        console.log("STAKER: ", token.bonStakers());
        console.log("STAKER BAL: ", ERC20(token).balanceOf(address(71)));
        console.log("DEVS: ", token.bonDevs());
        console.log("DEVS BAL: ", ERC20(token).balanceOf(address(72)));
        assertFalse(0 == 0);
    }

    // deposit to staking
    function test_depositToStaking() public{
        // --- setup stuff ---
        ERC20(address(token)).transfer(address(700), 50000000000000000000000);
        ERC20(address(token)).transfer(address(701), 50000000000000000000000);
        ERC20(address(token)).transfer(address(staking), 69000000000000000000000); //get a little fake tax in there

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

    // withdraw rewards
    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    // withdraw all

    // only owners

    // close pool

}