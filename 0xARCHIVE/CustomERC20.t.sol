// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/CustomERC20.sol";


contract contractTest is Test {
    // hard coded testing vars
    Token public contractTested;

    //address public ERC20token = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F; //USDT
    address public cnctOwner = address(420);
    address public user1 = address(69);
    address public user2 = address(70);
    address public user3 = address(71);
    address public treasury = address(1001);
    address public staking = address(1002);
    address public dev1 = address(1003);
    address public dev2 = address(1004);
    uint256 public maxtokens = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    function setUp() public{
        // --- WALLETS ---
        vm.startPrank(cnctOwner);
        address[] memory testAddresses = new address[](3);
            testAddresses[0] = user1;
            testAddresses[1] = user2;
            testAddresses[2] = user3;
        //

        // --- CONTRACTS ---
        contractTested = new Token(
            "SOUP KITCHEN", 
            "SOUP",
            treasury,
            dev1,
            dev2,
            18,
            2,
            20,
            150_000_000_000,
            testAddresses
        );

        // --- TOKENS ---
        vm.deal(user1, 1_000_000 ether);
        vm.deal(user2, 1_000_000 ether);
        vm.deal(user3, 1_000_000 ether);
    }

    function consoleLogs() public view{
        console.log("_____________________CONTRT_INFOM_____________________");
        console.log("CNCT OWNR: ", address(cnctOwner));
        console.log("CNCT ADDR: ", address(contractTested));
        console.log("CNCT CNTR: ", contractTested.totalSupply());
        console.log("OWNR TBAL: ", address(cnctOwner).balance);

        console.log("_____________________WALLET_INFOM_____________________");
        console.log("TRSY WLLT: ", address(treasury));
        console.log("TRSY ERCB: ", contractTested.balanceOf(treasury));
        console.log("DEV1 WLLT: ", address(dev1));
        console.log("DEV1 ERCB: ", contractTested.balanceOf(dev1));
        console.log("DEV2 WLLT: ", address(dev2));
        console.log("DEV2 ERCB: ", contractTested.balanceOf(dev2));
        console.log("USR1 WLLT: ", address(user1));
        console.log("USR1 ERCB: ", contractTested.balanceOf(user1));
        console.log("USR2 WLLT: ", address(user2));
        console.log("USR2 ERCB: ", contractTested.balanceOf(user2));
        console.log("USR3 WLLT: ", address(user3));
        console.log("USR3 ERCB: ", contractTested.balanceOf(user3));

    }

    function test_0_ConsoleLogs() public view{
        consoleLogs();
    }

    function transfer() public {
        vm.stopPrank();
        vm.startPrank(user1);
        contractTested.transfer(user2, 10_000_000_000_000_000_000_000_000_000);
    }

    function test_1_RunNormalProcedure() public{
        transfer();
        consoleLogs();
    }
}