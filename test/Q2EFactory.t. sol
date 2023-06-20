// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Q2EFactory.sol";

contract Q2EFactoryTest is Test {

    Q2EFactory public factory;

    function setUp() public {
        factory = new Q2EFactory();
    }

    function test_CreateQuiz() public{
        string memory question = "3 * 3 =";
        string memory answer = "9";
        bytes32 salt = bytes32("420420420");
        bytes32 hashedAnswer = keccak256(abi.encodePacked(salt, answer));
        factory.createQuiz(question, hashedAnswer);
        Q2E quiz = factory.quizzes(0);
        assertEq(
            keccak256(abi.encodePacked(quiz.question())), 
            keccak256(abi.encodePacked(question))
        );
    }

    function test_CountQuizzes() public{
        string memory question = "3 * 3 =";
        string memory answer = "9";
        bytes32 salt = bytes32("420420420");
        bytes32 hashedAnswer = keccak256(abi.encodePacked(salt, answer));
        factory.createQuiz(question, hashedAnswer);
        factory.createQuiz(question, hashedAnswer);

        Q2E[] memory quizzes = factory.getQuizzes();
        assertEq(quizzes.length, 2);
    }

}
