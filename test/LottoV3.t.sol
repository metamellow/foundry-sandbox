// SPDX-License-Identifier: GNU
pragma solidity ^0.8.17;

/*
NOTES:
- test needs to be run via Alchemy rpc:
forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/v4B-uiSecIHqGvzHRN21NJaX1Z87jtli -vvv
-

*/

import "forge-std/Test.sol";
import "../src/LottoV3.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract contractTest is Test {
    LottoV3 public LottoV3Contract;
    address public ERC20token = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F; //USDT
    address public user1 = address(69);
    address public user2 = address(70);
    address public user3 = address(71);

    function setUp() public{
        // --- WALLETS ---
        vm.startPrank(user1);

        // --- TOKENS ---
        vm.deal(user1, 1_000_000 ether);

        deal(ERC20token, user1, 1_000_000_000_069 ether);
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

    function consoleLogs() public view{
        console.log("_____________________CONTRT_INFOM_____________________");
        console.log("CNCT ADDR: ", address(LottoV3Contract));
        console.log("CNCT CNTR: ", LottoV3Contract.counter());

        console.log("_____________________WALLET_INFOM_____________________");
        console.log("USR1 GASB: ", address(user1).balance);
        console.log("USR1 ERCB: ", ERC20(ERC20token).balanceOf(address(user1)));

    }

    function test_0_ConsoleLogs() public view{
        consoleLogs();
    }

    function test_1_Bet() public {
        vm.startPrank(user1);
        LottoV3Contract.bet();
        consoleLogs();
        vm.startPrank(user2);
        LottoV3Contract.bet();
        consoleLogs();

        address results;
        results = LottoV3Contract.pastLottoResults(1);
        console.log("RESULTS: ", results);

    }
}