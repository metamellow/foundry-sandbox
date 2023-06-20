// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Q2E.sol";

contract Q2EFactory {
    Q2E[] public quizzes;
    event QuizCreated(Q2E indexed quiz);

    constructor(){
    }

    function createQuiz(string memory question, bytes32 answer) public{
        Q2E quiz = new Q2E(question, answer);
        quizzes.push(quiz);
        emit QuizCreated(quiz);
    }

    function getQuizzes() public view returns (Q2E[] memory){
        return quizzes;
    }

}
