// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-. BANK OF NOWHERE $BON token (**MOCK UP) -.-.-. */
/* -.-.-.-.-.    [[ BUILT BY METAMELLOW ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
 
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
 
contract bonToken is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 _supply
    ) ERC20(name, symbol) {
        _mint(msg.sender, _supply * (10 ** decimals()));
    }
}