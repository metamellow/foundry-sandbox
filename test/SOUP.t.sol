// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/SOUP.sol";


contract contractTest is Test {
    SOUP public contractTested;

    function setUp() public{
        // --- WALLETS ---
        vm.startPrank(address(69));
        address[] memory testAddresses = new address[](5);
            testAddresses[0] = address(101);
            testAddresses[1] = address(102);
            testAddresses[2] = address(103);
            testAddresses[3] = address(104);
            testAddresses[4] = address(105);
            /* 
                ["0x3645eA6c6C47034c556C5A03bB61Ede3123b40bD",
                "0xCff8339DA421c465d4325268799300952B55FAd0",
                "0x0cCC6d80204809C0AE67eA74dA087277300aD469",
                "0xF441eA0cE8BB80849216bB614137563bE3f86248",
                "0xEF538a11FB3441eB9b5444654a8075cd63afDdfF"]
            */

        // --- TOKENS ---
        vm.deal(address(69), 1_000_000 ether);
        
        // --- CONTRACTS ---
        contractTested = new GAYG(
            "Gay Gary Gensler", 
            "GAYG",
            address(420), 
            450, 
            testAddresses
        );
    }

    function testFail_0xSetUpLogs() public{
        console.log("NAME: ", contractTested.name());
        console.log("SYMBOL: ", contractTested.symbol());
        console.log("TTL SPPL: ", contractTested.totalSupply());
        console.log("DECIML: ", contractTested.decimals());
        console.log("TAX: ", contractTested.tax());
        console.log("CNRT ADDR: ", address(contractTested));
        console.log("OWNR: ", contractTested.owner());
        console.log("OWNR BAL: ", IERC20(contractTested).balanceOf(address(69)));
        console.log("DEVS: ", contractTested.devs());
        console.log("DEVS BAL: ", IERC20(contractTested).balanceOf(address(420)));
        console.log("AD1 BAL: ", IERC20(contractTested).balanceOf(address(101)));
        console.log("AD2 BAL: ", IERC20(contractTested).balanceOf(address(102)));
        console.log("AD3 BAL: ", IERC20(contractTested).balanceOf(address(103)));
        console.log("AD4 BAL: ", IERC20(contractTested).balanceOf(address(104)));
        console.log("AD5 BAL: ", IERC20(contractTested).balanceOf(address(105)));
        assertFalse(0 == 0);
    }

    function test_5TransferNEW() public{
        contractTested.transfer(address(1001), 1_000_000);
        console.log("Supply b4: ", contractTested.totalSupply());
        console.log("DEV WLLT b4: ", IERC20(contractTested).balanceOf(address(420)));
        console.log("1001 b4: ", IERC20(contractTested).balanceOf(address(1001)));
        console.log("1002 b4: ", IERC20(contractTested).balanceOf(address(1002)));

        vm.stopPrank();
        vm.startPrank(address(1001));
        contractTested.transfer(address(1002), 1_000_000);

        console.log("Supply af: ", contractTested.totalSupply());
        console.log("DEV WLLT af: ", IERC20(contractTested).balanceOf(address(420)));
        console.log("1001 af: ", IERC20(contractTested).balanceOf(address(1001)));
        console.log("1002 af: ", IERC20(contractTested).balanceOf(address(1002)));
    }
}