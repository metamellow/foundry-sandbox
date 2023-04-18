// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/BonExchange.sol";
import "../src/BankToken.sol";
import "../src/OldBonToken.sol";

contract contractTest is Test {
    bonExchange public exchange;
    bankToken public bank;
    bonToken public bon;

    function setUp() public{
        // --- WALLETS ---
        address user = address(69);
        vm.startPrank(user);
        address[] memory testAddresses = new address[](3);
            testAddresses[0] = address(70);
            testAddresses[1] = address(71);
            testAddresses[2] = address(72);

        // --- TOKENS ---
        vm.deal(user, 1_000_000 ether);
        
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
    }

    function testFail_0xSetUpLogs() public{
        console.log("EXCHNG ADDR: ", address(exchange));
        console.log("BON ADDR: ", address(bon));
        console.log("BANK ADDR: ", address(bank));
        console.log("OWNR BON: ", ERC20(bon).balanceOf(address(69)));
        console.log("OWNR BANK: ", ERC20(bank).balanceOf(address(69)));
        assertFalse(0 == 0);
    }

}