// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/BonExchange.sol";
import "../src/BankToken.sol";
import "../src/BonToken.sol";

contract contractTest is Test {
    bonExchange public exchange;
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

        exchange = new bonExchange(
            address(bon),
            address(bank),
            69
        );

        // --- INITIALIZE --
        bank.setWhitelistAddress(address(exchange));
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
        bank.transfer(address(exchange), 10500000000000000000000000);
        bon.transfer(address(700), 50000000000000000000);
        console.log("EXCHNG BON BAL b4: ", ERC20(bon).balanceOf(address(exchange)));
        console.log("EXCHNG BANK BAL b4: ", ERC20(bank).balanceOf(address(exchange)));
        console.log("USER700 BON BAL b4: ", ERC20(bon).balanceOf(address(700)));
        console.log("USER700 BANK BAL b4: ", ERC20(bank).balanceOf(address(700)));

        // --- TESTING ---
        vm.stopPrank();
        vm.startPrank(address(700));
        bon.approve(address(exchange), 1_000_000_000_000_000 ether);
        exchange.exchangeToken(40000000000000000000);

        console.log("EXCHNG BON BAL aft: ", ERC20(bon).balanceOf(address(exchange)));
        console.log("EXCHNG BANK BAL aft: ", ERC20(bank).balanceOf(address(exchange)));
        console.log("USER700 BON BAL aft: ", ERC20(bon).balanceOf(address(700)));
        console.log("USER700 BANK BAL aft: ", ERC20(bank).balanceOf(address(700)));
    }

    function test_2OnlyOwners() public{
        // --- SETUP ---
        console.log("time b4: ", exchange.end());
        exchange.changeEndTime(6969);
        console.log("time aft: ", exchange.end());
    }

    function test_3closeExchangePool() public{
        bank.transfer(address(exchange), 10500000000000000000000000);
        bon.transfer(address(exchange), 10500000000000000000000000);
        vm.deal(address(exchange), 69 ether);

        
        console.log("EXCHNG BON BAL b4: ", ERC20(bon).balanceOf(address(exchange)));
        console.log("EXCHNG BANK BAL b4: ", ERC20(bank).balanceOf(address(exchange)));
        console.log("EXCHNG ETH BAL b4: ", address(exchange).balance);
        console.log("OWNR BON BAL b4: ", ERC20(bon).balanceOf(address(69)));
        console.log("OWNR BANK BAL b4: ", ERC20(bank).balanceOf(address(69)));
        console.log("OWNR ETH BAL b4: ", address(exchange).balance);

        exchange.closeExchangePool();

        console.log("EXCHNG BON BAL aft: ", ERC20(bon).balanceOf(address(exchange)));
        console.log("EXCHNG BANK BAL aft: ", ERC20(bank).balanceOf(address(exchange)));
        console.log("EXCHNG ETH BAL aft: ", address(exchange).balance);
        console.log("OWNR BON BAL aft: ", ERC20(bon).balanceOf(address(69)));
        console.log("OWNR BANK BAL aft: ", ERC20(bank).balanceOf(address(69)));
        console.log("OWNR ETH BAL aft: ", address(69).balance);
    }

    //////////// IT doesnt seem that the token tax is working?
    
    function test_4banktransfertest() public{
        bank.transfer(address(700), 1000);
        console.log("700 BANK BAL b4: ", ERC20(bank).balanceOf(address(700)));
        console.log("701 BANK BAL b4: ", ERC20(bank).balanceOf(address(701)));
        console.log("70 BANK BAL b4: ", ERC20(bank).balanceOf(address(70)));
        console.log("71 BANK BAL b4: ", ERC20(bank).balanceOf(address(71)));
        console.log("72 BANK BAL b4: ", ERC20(bank).balanceOf(address(70)));
       
        vm.stopPrank();
        vm.startPrank(address(700));
        bank.transfer(address(701), 500);

        console.log("700 BANK BAL b4: ", ERC20(bank).balanceOf(address(700)));
        console.log("701 BANK BAL b4: ", ERC20(bank).balanceOf(address(701)));
        console.log("70 BANK BAL aft: ", ERC20(bank).balanceOf(address(70)));
        console.log("71 BANK BAL aft: ", ERC20(bank).balanceOf(address(71)));
        console.log("72 BANK BAL aft: ", ERC20(bank).balanceOf(address(70)));
    }
}