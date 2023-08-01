// SPDX-License-Identifier: GNU
pragma solidity ^0.8.17;

/*
NOTES:
- test needs to be run via Alchemy rpc:
forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/v4B-uiSecIHqGvzHRN21NJaX1Z87jtli --via-ir -vv
-

*/

import "forge-std/Test.sol";
import "../src/LottoV3.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract contractTest is Test {
    // hard coded testing vars
    LottoV3 public LottoV3Contract;
    address public ERC20token = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F; //USDT
    address public cnctOwner = address(420);
    address public user1 = address(69);
    address public user2 = address(70);
    address public user3 = address(71);
    address public treasury = address(1001);
    address public staking = address(1002);
    address public dev1 = address(1003);
    address public dev2 = address(1004);
    uint256 public maxtokens = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    function setUp() public{
        vm.startPrank(cnctOwner);

        // --- CONTRACTS ---
        LottoV3Contract = new LottoV3(
            /*ERC20token, */0x0000000000000000000000000000000000000000,
            treasury,
            staking,
            dev1,
            dev2,
            10000000000000000,
            1209600,
            10,
            0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd //polymain airnode
        );

        // --- TOKENS ---
        vm.deal(user1, 1_000_000 ether);
        vm.deal(user2, 1_000_000 ether);
        vm.deal(user3, 1_000_000 ether);

        vm.stopPrank();
        vm.startPrank(user1);
        deal(ERC20token, user1, 1_000_000_000_069 ether);
        require(IERC20(ERC20token).approve(
            address(LottoV3Contract), 
            maxtokens), 
            "Approve failed!"
        );

        vm.stopPrank();
        vm.startPrank(user2);
        deal(ERC20token, user2, 1_000_000_000_069 ether);
        require(IERC20(ERC20token).approve(
            address(LottoV3Contract), 
            maxtokens), 
            "Approve failed!"
        );

        vm.stopPrank();
        vm.startPrank(user3);
        deal(ERC20token, user3, 1_000_000_000_069 ether);
        require(IERC20(ERC20token).approve(
            address(LottoV3Contract), 
            maxtokens), 
            "Approve failed!"
        );
    }

    function consoleLogs() public view{
        console.log("_____________________CONTRT_INFOM_____________________");
        console.log("CNCT OWNR: ", address(cnctOwner));
        console.log("CNCT ADDR: ", address(LottoV3Contract));
        console.log("CNCT CNTR: ", LottoV3Contract.counter());
        console.log("CNCT CNTR: ", LottoV3Contract.betPrice());
        console.log("CNCT CNTR: ", LottoV3Contract.restartTimer());

        console.log("_____________________WALLET_INFOM_____________________");
        console.log("USR1 WLLT: ", address(user1));
        console.log("USR1 GASB: ", address(user1).balance);
        console.log("USR1 ERCB: ", ERC20(ERC20token).balanceOf(address(user1)));
        console.log("USR2 WLLT: ", address(user2));
        console.log("USR2 GASB: ", address(user2).balance);
        console.log("USR2 ERCB: ", ERC20(ERC20token).balanceOf(address(user2)));
        console.log("USR3 WLLT: ", address(user3));
        console.log("USR3 GASB: ", address(user3).balance);
        console.log("USR3 ERCB: ", ERC20(ERC20token).balanceOf(address(user3)));

    }

    function test_0_ConsoleLogs() public view{
        consoleLogs();
    }

    function bet() public {
        uint256 betPrice = LottoV3Contract.betPrice();
        
        vm.stopPrank();
        vm.startPrank(user1);
        //LottoV3Contract.bet();
        LottoV3Contract.bet{value: betPrice}();

        vm.stopPrank();
        // fail check // vm.startPrank(user1);
        vm.startPrank(user2);
        //LottoV3Contract.bet();
        LottoV3Contract.bet{value: betPrice}();

        (address winnerAddr, uint256 winnerAmnt, bool winnerClm) = LottoV3Contract.checkLotto(1);
        console.log("_____________________BETFNC_INFOM_____________________");
        console.log("winnerAddr: ", winnerAddr);
        console.log("winnerAmnt: ", winnerAmnt);
        console.log("winnerClm: ", winnerClm);
        console.log("USR2 NFTS: ", LottoV3Contract.ownerOf(1));
    }

    function claim() public {
        vm.stopPrank();
        // fail check // vm.startPrank(user1);
        vm.startPrank(user2);
        LottoV3Contract.claimLotto(1);

        console.log("_____________________CLAIM_INFOM_____________________");
        // fail check // console.log("USR2 NFTS: ", LottoV3Contract.ownerOf(1));
        console.log("USR2 GASB: ", address(user2).balance);
        console.log("USR2 ERCB: ", ERC20(ERC20token).balanceOf(address(user2)));

        // fail check // LottoV3Contract.claimLotto(1);
    }

    function test_1_RunNormalProcedure() public{
        consoleLogs();
        bet();
        claim();
    }
}