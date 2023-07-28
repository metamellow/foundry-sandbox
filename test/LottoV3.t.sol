// SPDX-License-Identifier: GNU
pragma solidity ^0.8.17;

/*
NOTES:
- test needs to be run via Alchemy rpc:
    "forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi -vvv"
*/

import "forge-std/Test.sol";
import "../src/LottoV3.sol";

contract contractTest is Test {
    LottoV3 public LottoV3Contract;
    address public ERC20token = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F; //USDT

    function setUp() public{
        // --- WALLETS ---
        address user = address(69);
        vm.startPrank(user);

        // --- TOKENS ---
        vm.deal(user, 1_000_000 ether);

        deal(ERC20token, user, 1_000_000_000_069 ether);
        require(IERC20(ERC20token).approve(
            0x8fA079a96cE08F6E8A53c1C00566c434b248BFC4, 
            115792089237316195423570985008687907853269984665640564039457584007913129639935), 
            "Approve failed!"
        );

        // contract setup
        LottoV3Contract = new LottoV3(
            ERC20token,
            address(1001),
            address(1002),
            address(1003),
            10000000000000000,
            0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd //polymain airnode
        );
    }

}