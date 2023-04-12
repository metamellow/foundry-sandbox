// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/bonToken.sol";

contract contractTest is Test {
    bonToken public contractTested;
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
        contractTested = new bonToken(
            "Bank_of_Nowhere", 
            "BON", 
            //21000000, 
            address(70), 
            address(71), 
            address(72), 
            4, 
            testAddresses
        );

        // ---SETUP LOGS ---
        emit log_array(testAddresses);
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
    }

    function test_CheckOnlyOwners() public{
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

    function testFail_CheckOnlyOwner() public{
        vm.stopPrank();
        vm.startPrank(address(71));
        contractTested.setTreasuryAddress(address(71));
        contractTested.setStakersAddress(address(72));
        contractTested.setDevAddress(address(70));
    }

    function test_Transfers() public{
        IERC20(address(contractTested)).transfer(address(700), 69_000);
        
        vm.stopPrank();
        vm.startPrank(address(700));
        IERC20(address(contractTested)).approve(
            address(contractTested), 
            115792089237316195423570985008687907853269984665640564039457584007913129639935);
        console.log("700 WLLT B4 BAL: ", IERC20(contractTested).balanceOf(address(700)));
        console.log("701 WLLT B4 BAL: ", IERC20(contractTested).balanceOf(address(701)));
        //console.log("NEW WLLT APPRVL: ", IERC20(contractTested).allowance(address(700), address(contractTested)));
        IERC20(address(contractTested)).transfer(address(701), 9_000);
        console.log("700 WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(700)));
        console.log("701 WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(701)));
        console.log("TRES WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(70)));
        console.log("STKR WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(71)));
        console.log("DEV WLLT AFT BAL: ", IERC20(contractTested).balanceOf(address(72)));
    }
}