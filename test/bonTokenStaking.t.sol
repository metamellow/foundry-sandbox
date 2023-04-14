// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/bonTokenStaking.sol";
import "../src/bonToken.sol";

contract contractTest is Test {
    bonTokenStaking public contractTested;
    bonToken public testedToken;

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
        testedToken = new bonToken(
            "Bank_of_Nowhere", 
            "BON", 
            //21000000, 
            address(70), 
            address(71), 
            address(72), 
            4, 
            testAddresses
        );

        contractTested = new bonTokenStaking(
            address(contractTested),
            604800,
            50
        );
        testedToken.setWhitelistAddress(address(contractTested));
    }

    function testFail_0xSetUpLogs() public{
        console.log("MSG.SENDER: ", address(msg.sender));
        console.log("CNRT ADDR: ", address(contractTested));
        console.log("TIMER DUR: ", contractTested.timerDuration());
        console.log("RWD RATE: ", contractTested.rwdRate());
        console.log("STKD SUPPL: ", contractTested.stakedPoolSupply());
        console.log("TKN ADDR: ", address(testedToken));
        console.log("STKR CNT WHTLSTD ON TKN: ", testedToken.whitelistedAddress(address(contractTested)));
        console.log("OWNR: ", testedToken.owner());
        console.log("OWNR BAL: ", IERC20(testedToken).balanceOf(address(69)));
        console.log("TRES: ", testedToken.bonTreasury());
        console.log("TRES BAL: ", IERC20(testedToken).balanceOf(address(70)));
        console.log("STAKER: ", testedToken.bonStakers());
        console.log("STAKER BAL: ", IERC20(testedToken).balanceOf(address(71)));
        console.log("DEVS: ", testedToken.bonDevs());
        console.log("DEVS BAL: ", IERC20(testedToken).balanceOf(address(72)));
        assertFalse(0 == 0);
    }

    // deposit to staking
    function test_depositToStaking() public{
        IERC20(address(testedToken)).approve(
            address(69), 
            115792089237316195423570985008687907853269984665640564039457584007913129639935);
        IERC20(address(testedToken)).transfer(address(700), 50000000000000000000000);
        console.log("TST WLLT B4 BAL: ", IERC20(testedToken).balanceOf(address(700)));


        /*
        vm.stopPrank();
        vm.startPrank(address(700));
        IERC20(address(testedToken)).approve(
            address(700), 
            115792089237316195423570985008687907853269984665640564039457584007913129639935);
        IERC20(address(testedToken)).approve(
            address(contractTested), 
            115792089237316195423570985008687907853269984665640564039457584007913129639935);
        IERC20(address(testedToken)).approve(
            0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38, 
            115792089237316195423570985008687907853269984665640564039457584007913129639935);
        contractTested.depositToStaking(10000000000000000000000);
        */

        console.log("TST WLLT AFT BAL: ", IERC20(testedToken).balanceOf(address(700)));
        //console.log("STKD SUPPL: ", contractTested.stakedPoolSupply());
        //console.log("ADDR700 RWD: ", contractTested.calculateRewards(address(700)));
        //console.log("ADDR700 TME: ", contractTested.calculateTime(address(700)));
    }

    // check rewards

    // check time

    // withdraw rewards

    // withdraw all

    // only owners

    // close pool

}