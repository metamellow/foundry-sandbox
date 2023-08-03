// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/BankToken.sol";


contract contractTest is Test {
    bankToken public contractTested;
    address tempMsgSender = address(69);

    function setUp() public{
        // --- WALLETS ---
        vm.startPrank(tempMsgSender);
        address[] memory testAddresses = new address[](3);
            testAddresses[0] = address(70);
            testAddresses[1] = address(71);
            testAddresses[2] = address(72);

        // --- TOKENS ---
        vm.deal(tempMsgSender, 1_000_000 ether);
        
        // --- CONTRACTS ---
        contractTested = new bankToken(
            "Bank of Nowhere", 
            "BANK",
            address(70), 
            address(71), 
            address(72), 
            4, 
            testAddresses
        );
    }

    function testFail_0xSetUpLogs() public{
        console.log("NAME: ", contractTested.name());
        console.log("SYMBOL: ", contractTested.symbol());
        console.log("TTL SPPL: ", contractTested.totalSupply());
        console.log("DECIML: ", contractTested.decimals());
        console.log("BONTAX: ", contractTested.bonTax());
        console.log("CNRT ADDR: ", address(contractTested));
        console.log("OWNR: ", contractTested.owner());
        console.log("OWNR BAL: ", IERC20(contractTested).balanceOf(address(69)));
        console.log("TRES: ", contractTested.bonTreasury());
        console.log("TRES BAL: ", IERC20(contractTested).balanceOf(address(70)));
        console.log("STAKER: ", contractTested.bonStakers());
        console.log("STAKER BAL: ", IERC20(contractTested).balanceOf(address(71)));
        console.log("DEVS: ", contractTested.bonDevs());
        console.log("DEVS BAL: ", IERC20(contractTested).balanceOf(address(72)));
        assertFalse(0 == 0);
    }

    function testFail_1CheckOnlyOwner() public{
        vm.stopPrank();
        vm.startPrank(address(71));
        contractTested.setTreasuryAddress(address(71));
        contractTested.setStakersAddress(address(72));
        contractTested.setDevAddress(address(70));
    }
    
    function test_2CheckOnlyOwners() public{
        vm.stopPrank();
        vm.startPrank(tempMsgSender);
        contractTested.setTreasuryAddress(address(71));
        contractTested.setStakersAddress(address(72));
        contractTested.setDevAddress(address(70));
        contractTested.setWhitelistAddress(address(700));
        contractTested.setTax(69);
        
        console.log("TREASURY AFTER:", contractTested.bonTreasury());
        console.log("STAKERS AFTER:", contractTested.bonStakers());
        console.log("DEVS AFTER:", contractTested.bonDevs());
        console.log("WALLT WL AFTER:", contractTested.whitelistedAddress(address(700)));
        console.log("TAX AFTER:", contractTested.bonTax());
    }



    function test_3TransferFrom() public{
        console.log("OWNR WLLT B4 BAL: ", IERC20(contractTested).balanceOf(address(69)));
        IERC20(address(contractTested)).approve(
            address(69), 
            115792089237316195423570985008687907853269984665640564039457584007913129639935);
        IERC20(address(contractTested)).transfer(address(700), 69_000);
        
        vm.stopPrank();
        vm.startPrank(address(700));
        IERC20(address(contractTested)).approve(
            address(700), 
            115792089237316195423570985008687907853269984665640564039457584007913129639935);
        console.log("TTL SPPL B4: ", contractTested.totalSupply());
        console.log("700 WLLT B4 BAL: ", IERC20(contractTested).balanceOf(address(700)));
        console.log("701 WLLT B4 BAL: ", IERC20(contractTested).balanceOf(address(701)));
        //console.log("NEW WLLT APPRVL: ", IERC20(contractTested).allowance(address(700), address(contractTested)));
        IERC20(address(contractTested)).transferFrom(address(700), address(701), 9_000);
        console.log("TTL SPPL AFT: ", contractTested.totalSupply());
        console.log("700 WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(700)));
        console.log("701 WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(701)));
        console.log("OWNR WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(69)));
        console.log("TRES WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(70)));
        console.log("STKR WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(71)));
        console.log("DEV WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(72)));
    }

    function test_4Transfer() public{
        console.log("OWNR WLLT B4 BAL: ", IERC20(contractTested).balanceOf(address(69)));
        IERC20(address(contractTested)).approve(
            address(69), 
            115792089237316195423570985008687907853269984665640564039457584007913129639935);
        IERC20(address(contractTested)).transfer(address(700), 69_000);
        
        vm.stopPrank();
        vm.startPrank(address(700));
        IERC20(address(contractTested)).approve(
            address(700), 
            115792089237316195423570985008687907853269984665640564039457584007913129639935);
        console.log("700 WLLT B4 BAL: ", IERC20(contractTested).balanceOf(address(700)));
        console.log("701 WLLT B4 BAL: ", IERC20(contractTested).balanceOf(address(701)));
        //console.log("NEW WLLT APPRVL: ", IERC20(contractTested).allowance(address(700), address(contractTested)));
        IERC20(address(contractTested)).transfer(address(701), 9_000);
        console.log("700 WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(700)));
        console.log("701 WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(701)));
        console.log("OWNR WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(69)));
        console.log("TRES WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(70)));
        console.log("STKR WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(71)));
        console.log("DEV WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(72)));
    }

    function test_5TransferNEW() public{
        contractTested.transfer(address(1001), 1_000_000);
        console.log("Supply b4: ", contractTested.totalSupply());
        console.log("TRES WLLT b4: ", IERC20(contractTested).balanceOf(address(70)));
        console.log("STKR WLLT b4: ", IERC20(contractTested).balanceOf(address(71)));
        console.log("DEV WLLT b4: ", IERC20(contractTested).balanceOf(address(72)));
        console.log("1001 b4: ", IERC20(contractTested).balanceOf(address(1001)));
        console.log("1002 b4: ", IERC20(contractTested).balanceOf(address(1002)));

        vm.stopPrank();
        vm.startPrank(address(1001));
        contractTested.transfer(address(1002), 1_000_000);

        console.log("Supply af: ", contractTested.totalSupply());
        console.log("TRES WLLT af: ", IERC20(contractTested).balanceOf(address(70)));
        console.log("STKR WLLT af: ", IERC20(contractTested).balanceOf(address(71)));
        console.log("DEV WLLT af: ", IERC20(contractTested).balanceOf(address(72)));
        console.log("1001 af: ", IERC20(contractTested).balanceOf(address(1001)));
        console.log("1002 af: ", IERC20(contractTested).balanceOf(address(1002)));
    }
}