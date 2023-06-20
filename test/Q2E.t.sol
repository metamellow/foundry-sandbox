// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Q2E.sol";

contract Q2ETest is Test {
    Q2E public lotto;

    function setUp() public {
        // create a question
        string memory _question = "BON LOTTO #0.1";
        string memory _answer = "69";
        // salt is needed bc need to hash answer provided
        bytes32 _salt = bytes32("changeThisBeforeDeploying");
        bytes32 _hashedAnswer = keccak256(abi.encodePacked(_salt, _answer));
        console.log("setUp _hashedAnswer: ", log_bytes32(_hashedAnswer));

        lotto = new Q2E(
            _question,                                  // string memory _question
            _hashedAnswer,                              // bytes32 _hashedAnswer
            0x47E53f0Ddf71210F2C45dc832732aA188F78AA4f, // address _erc20contract
            0x26432f7cf51e644c0adcaf3574216ee1c0a9af6d, // address _erc20LP
            750000000000000000000,                      // uint256 _erc20Base
            1000                                        // uint256 _erc20Fee
        );
        console.log("lotto.question(): ", lotto.question());
    }

    function consoleLogs() public view{
        console.log("_____________________CONRCT_INFOM_____________________");
        console.log("CNRT ADDR: ", address(lotto));

        console.log("_____________________WALLET_INFOM_____________________");
    }

    function test_0_ConsoleLogs() public view{
        consoleLogs();
    }


/*
    function testPass() public {
        assertTrue(true);
    }

    function testFail() public{
        game.guess("1");
    }

    function test_QuizPass() public{
        uint256 beginBalance = address(this).balance;
        vm.deal(address(game), 1_000 ether);
        game.guess("4");
        assertEq(address(this).balance, beginBalance + 1_000 ether);
    }
*/
}
