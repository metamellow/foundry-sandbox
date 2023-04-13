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
    }

    function testFail_0xSetUpLogs() public{
        console.log("CNRT ADDR: ", address(contractTested));
        console.log("TIMER DUR: ", contractTested.timerDuration());
        console.log("RWD RATE: ", contractTested.rwdRate());
        console.log("STKD SUPPL: ", contractTested.stakedPoolSupply());
        //console.log("xxx: ", );
        //console.log("xxx: ", );
        console.log("TKN ADDR: ", address(testedToken));
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

    // check rewards

    // check time

    // withdraw rewards

    // withdraw all

    // only owners

    // close pool

}