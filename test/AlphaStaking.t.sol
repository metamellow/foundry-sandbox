// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/AlphaStaking.sol";
import "../src/ChadGPT.sol";

contract contractTest is Test {
    alphaStaking public staking;
    ChadGPT public token;

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
        token = new ChadGPT(
            "ChadGPT Alpha Meme", 
            "ChadGPT",
            address(420), //dev address
            42, //tax
            testAddresses //AD
        );

        staking = new alphaStaking(
            address(token),
            248400, //69 hours
            42 //percent of pool
        );

        // --- NEED TODOs AFTER DEPLOY ---
        token.transfer(address(staking), 1_000_000); // put some tokens in the pool
        staking.setStakingOpen(true); // open the pool for deposits
    }

    function runConsolLogs() public view{
        
        console.log("_____________________TOKENS_INFOM_____________________");
        console.log("TOKN ADDR: ", address(token));
        console.log("TOKN TSUP: ", ERC20(token).totalSupply());
        console.log("STKG ADDR: ", address(staking));
        console.log("STKG TBAL: ", ERC20(token).balanceOf(address(staking)));

        console.log("_____________________WALLET_INFOM_____________________");
        console.log("OWRW TBAL: ", token.balanceOf(address(69)));
        console.log("TAXW TBAL: ", token.balanceOf(address(420)));
        console.log("AD1W TBAL: ", token.balanceOf(address(10001)));
        console.log("AD2W TBAL: ", token.balanceOf(address(10002)));
        console.log("AD3W TBAL: ", token.balanceOf(address(10003)));
    }
    
    function testFail_0xSetUpLogs() public{
        runConsolLogs();
        assertFalse(0 == 0);
    }

    function test_1_depositToStaking() public{
        staking.setStakingOpen(true);

        vm.stopPrank();
        vm.startPrank(address(10001));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(1_000_000_000 ether);
        
        vm.stopPrank();
        vm.startPrank(address(10002));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(1_000_000_000 ether);

        vm.stopPrank();
        vm.startPrank(address(10003));
        ERC20(address(token)).approve(address(staking), 1_000_000_000 ether);
        staking.depositToStaking(1_000_000_000 ether);

    }
}