




















// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DiceGame {

    struct Player {
        address payable addr;
        uint256 bet;
        uint256 diceKept; 
        uint256[] dice;
    }

    uint256 public constant NUM_DICE = 6;
    uint256 public constant NUM_PLAYERS = 3;
    uint256 public pot;

    Player[NUM_PLAYERS] public players;

    constructor() {
        // Initialize players
        for(uint i = 0; i < NUM_PLAYERS; i++) {
            players[i].addr = payable(msg.sender);
        }
    }

    function joinGame() public payable {
        require(msg.value > 0, "Must send Ether to join game");

        for(uint i = 0; i < NUM_PLAYERS; i++) {
            if(players[i].addr == msg.sender) {
                // Already joined, add to existing bet
                players[i].bet += msg.value;
                return;
            }
            if(players[i].addr == address(0)) {
                // Join as new player
                players[i].addr = payable(msg.sender);
                players[i].bet = msg.value;
                return;
            }
        }

        revert("Game is full");
    }

    function rollDice() public {
        require(players[0].addr != address(0), "Game not started yet");

        // Roll dice for each player
        for(uint i = 0; i < NUM_PLAYERS; i++) {
            for(uint j = 0; j < NUM_DICE; j++) {
                players[i].dice.push(uint256(keccak256(abi.encodePacked(i, j, block.timestamp))) % 6 + 1); 
            }
        }
    }

    function keepDice(uint8[] calldata _keptDice) external {
        for(uint i = 0; i < NUM_PLAYERS; i++) {
            if(players[i].addr == msg.sender) {
                require(_keptDice.length >= 1, "Must keep at least 1 dice");
                require(_keptDice.length <= NUM_DICE - players[i].diceKept, "Can't keep more dice");

                // Update kept dice
                for(uint j = 0; j < _keptDice.length; j++) {
                    players[i].diceKept++;
                    players[i].dice[_keptDice[j]-1] = 0; 
                }
                return;
            }
        }

        revert("Not a player");
    }

    function endGame() public {
        require(players[0].diceKept == NUM_DICE, "Game not over yet");

        // Calculate winner
        uint256 bestScore = 0;
        uint256 winnerIndex;
        for(uint i = 0; i < NUM_PLAYERS; i++) {
            uint256 score = calculateScore(players[i].dice);
            if(score > bestScore) {
                bestScore = score;
                winnerIndex = i;
            }
        }

        // Send pot to winner
        players[winnerIndex].addr.transfer(pot);

        // Reset game
        delete players;
        pot = 0;
    }

    function calculateScore(uint256[] memory dice) public pure returns (uint256) {
        // Calculate score based on kept dice
        uint256 score = 0;
        for(uint i = 0; i < dice.length; i++) {
            if(dice[i] != 0) {
                score += dice[i]; 
            }
        }
        return score;
    }
}














// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DiceGame {
    struct Player {
        address payable addr;
        uint256 bet;
        uint256 score;
        uint256 diceKept;
        uint256[] dice;
    }

    uint256 public constant NUM_DICE = 6;
    uint256 public constant NUM_PLAYERS = 3;
    uint256 public pot;

    Player[NUM_PLAYERS] public players;
    uint256 public currentPlayer;

    constructor() {
        currentPlayer = 0;
    }

    function joinGame() public payable {
        require(msg.value > 0, "Must send Ether to join game");
        require(currentPlayer < NUM_PLAYERS, "Game is full");

        players[currentPlayer].addr = payable(msg.sender);
        players[currentPlayer].bet = msg.value;
        currentPlayer++;
    }

    function rollDice() public {
        require(currentPlayer == NUM_PLAYERS, "Not all players have joined");

        for(uint i = 0; i < NUM_PLAYERS; i++) {
            for(uint j = 0; j < NUM_DICE; j++) {
                players[i].dice.push(uint256(keccak256(abi.encodePacked(i, j, block.timestamp))) % 6 + 1);
            }
        }
    }

    function keepDice(uint8[] calldata _keptDice) external {
        for(uint i = 0; i < NUM_PLAYERS; i++) {
            if(players[i].addr == msg.sender) {
                require(_keptDice.length >= 1, "Must keep at least 1 dice");
                require(_keptDice.length <= NUM_DICE - players[i].diceKept, "Can't keep more dice");

                for(uint j = 0; j < _keptDice.length; j++) {
                    players[i].score += players[i].dice[_keptDice[j]-1];
                    players[i].dice[_keptDice[j]-1] = 0;
                    players[i].diceKept++;
                }
                return;
            }
        }

        revert("Not a player");
    }

    function endGame() public {
        require(players[0].diceKept == NUM_DICE, "Game not over yet");

        uint256 bestScore = 0;
        uint256 winnerIndex;
        for(uint i = 0; i < NUM_PLAYERS; i++) {
            if(players[i].score > bestScore && checkQualification(players[i].dice)) {
                bestScore = players[i].score;
                winnerIndex = i;
            }
        }

        players[winnerIndex].addr.transfer(pot);

        delete players;
        pot = 0;
        currentPlayer = 0;
    }

    function checkQualification(uint256[] memory dice) public pure returns (bool) {
        bool hasFour = false;
        bool hasSix = false;
        for(uint i = 0; i < dice.length; i++) {
            if(dice[i] == 4) hasFour = true;
            if(dice[i] == 6) hasSix = true;
        }
        return hasFour && hasSix;
    }
}