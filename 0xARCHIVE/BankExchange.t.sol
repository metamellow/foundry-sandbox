// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/BankExchange.sol";
import "../src/BankToken.sol";
import "../src/BonToken.sol";

contract contractTest is Test {
    bankExchange public exchange;
    bankToken public bank;
    bonToken public bon;

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
        bank = new bankToken(
            "BON GOVERNANCE TOKEN", 
            "BANK", 
            address(70), 
            address(71), 
            address(72), 
            4, 
            testAddresses
        );

        bon = new bonToken(
            "Bank of Nowhere", 
            "BON", 
            21_000_000
        );

        exchange = new bankExchange(
            address(bank),
            address(bon),
            69,
            40,
            address(666)
        );

        // --- INITIALIZE --
        bank.setWhitelistAddress(address(exchange));
        bank.transfer(address(exchange), 10000000000000000000000000);
        bon.transfer(address(exchange), 10000000000000000000000000);
    }

    function testFail_0xSetUpLogs() public{
        console.log("EXCHNG ADDR: ", address(exchange));
        console.log("BON ADDR: ", address(bon));
        console.log("BANK ADDR: ", address(bank));
        console.log("OWNR BON: ", ERC20(bon).balanceOf(address(69)));
        console.log("OWNR BANK: ", ERC20(bank).balanceOf(address(69)));
        console.log("EXCHNG BON BAL: ", ERC20(bon).balanceOf(address(exchange)));
        console.log("EXCHNG BANK BAL: ", ERC20(bank).balanceOf(address(exchange)));
        assertFalse(0 == 0);
    }

    function test_1exchange() public{
        // --- SETUP ---
        bank.transfer(address(700), 50000000000000000000);
        console.log("EXCHNG BON BAL b4: ", ERC20(bon).balanceOf(address(exchange)));
        console.log("EXCHNG BANK BAL b4: ", ERC20(bank).balanceOf(address(exchange)));
        console.log("USER700 BON BAL b4: ", ERC20(bon).balanceOf(address(700)));
        console.log("USER700 BANK BAL b4: ", ERC20(bank).balanceOf(address(700)));
        console.log("taxHolder BON BAL b4: ", ERC20(bon).balanceOf(address(666)));

        // --- TESTING ---
        vm.stopPrank();
        vm.startPrank(address(700));
        bank.approve(address(exchange), 1_000_000_000_000_000 ether);
        exchange.exchangeToken(5000000000000000000);

        console.log("EXCHNG BON BAL aft: ", ERC20(bon).balanceOf(address(exchange)));
        console.log("EXCHNG BANK BAL aft: ", ERC20(bank).balanceOf(address(exchange)));
        console.log("USER700 BON BAL aft: ", ERC20(bon).balanceOf(address(700)));
        console.log("USER700 BANK BAL aft: ", ERC20(bank).balanceOf(address(700)));
        console.log("taxHolder BON BAL aft: ", ERC20(bon).balanceOf(address(666)));
    }
}