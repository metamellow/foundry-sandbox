




// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DiceGame {
    uint256 public constant MAX_SCORE = 24;
    uint256 public constant MAX_PLAYERS = 3;
    uint256 public constant DICE_SIDES = 6;
    uint256 public constant BET_AMOUNT = 10;

    struct Player {
        address playerAddress;
        uint256 score;
        bool qualified;
        bool finished;
        uint256[] dice;
    }

    Player[MAX_PLAYERS] public players;
    uint256 public currentPlayerIndex;
    bool public gameActive;
    uint256 public totalBets;

    event GameFinished(address winner, uint256 winnings);

    constructor() {
        currentPlayerIndex = 0;
        gameActive = false;
        totalBets = 0;
    }

    function startGame() public payable {
        require(!gameActive, "Game is already active");
        require(msg.value == BET_AMOUNT, "Incorrect bet amount");
        require(currentPlayerIndex < MAX_PLAYERS, "Maximum players reached");

        players[currentPlayerIndex] = Player({
            playerAddress: msg.sender,
            score: 0,
            qualified: false,
            finished: false,
            dice: new uint256[](6)
        });

        totalBets += msg.value;
        currentPlayerIndex++;

        if (currentPlayerIndex == MAX_PLAYERS) {
            gameActive = true;
            currentPlayerIndex = 0;
            distributeDice();
        }
    }

    function distributeDice() private {
        for (uint256 i = 0; i < 6; i++) {
            players[currentPlayerIndex].dice[i] = getRandomNumber();
        }
    }

    function getRandomNumber() private view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, currentPlayerIndex))) % DICE_SIDES + 1;
        return randomNumber;
    }

    function chooseDice(uint256[] memory selectedDice) public {
        require(gameActive, "Game is not active");
        require(msg.sender == players[currentPlayerIndex].playerAddress, "Not your turn");
        require(selectedDice.length > 0 && selectedDice.length <= 6, "Invalid number of dice");

        Player storage currentPlayer = players[currentPlayerIndex];

        for (uint256 i = 0; i < selectedDice.length; i++) {
            require(selectedDice[i] >= 1 && selectedDice[i] <= DICE_SIDES, "Invalid dice value");
            currentPlayer.score += selectedDice[i];
        }

        for (uint256 i = 0; i < 6; i++) {
            if (!contains(selectedDice, currentPlayer.dice[i])) {
                currentPlayer.dice[i] = getRandomNumber();
            }
        }

        if (currentPlayer.score >= MAX_SCORE) {
            currentPlayer.qualified = true;
        }

        currentPlayer.finished = true;
        currentPlayerIndex++;

        if (currentPlayerIndex == MAX_PLAYERS) {
            endGame();
        }
    }

    function contains(uint256[] memory array, uint256 element) private pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == element) {
                return true;
            }
        }
        return false;
    }

    function endGame() private {
        uint256 highestScore = 0;
        address winner;

        for (uint256 i = 0; i < MAX_PLAYERS; i++) {
            Player storage player = players[i];

            if (player.qualified && player.score > highestScore) {
                highestScore = player.score;
                winner = player.playerAddress;
            }

            player.score = 0;
            player.qualified = false;
            player.finished = false;
        }

        gameActive = false;
        totalBets = 0;

        if (winner != address(0)) {
            uint256 winnings = totalBets;
            emit GameFinished(winner, winnings);
            payable(winner).transfer(winnings);
        }
    }
}
```













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