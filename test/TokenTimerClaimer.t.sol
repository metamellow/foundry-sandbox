// SPDX-License-Identifier: GNU
pragma solidity ^0.8.17;

/*
NOTES:
- test needs to be run via Alchemy rpc:
forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/v4B-uiSecIHqGvzHRN21NJaX1Z87jtli --via-ir -vv
*/

import "forge-std/Test.sol";
import "../src/TokenTimerClaimer.sol";
import "../src/SOUP.sol";
import "../src/Standard721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract contractTest is Test {
    // hard coded testing vars
    Claimer public ClaimerContract;
    SOUP public TokenContract;
    NFT public NftContract;

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

        address[] memory testAddresses = new address[](3);
            testAddresses[0] = user1;
            testAddresses[1] = user2;
            testAddresses[2] = user3;
        //
        
        // --- CONTRACTS ---
        TokenContract = new SOUP(
            "SOUP KITCHEN", 
            "SOUP",
            treasury,
            dev1,
            dev2,
            18,
            2,
            20,
            150_000_000_000,
            testAddresses
        );
        
        NftContract = new NFT(
            /* reciever */      cnctOwner,
            /* reserved */      10,
            /* NFT name */      "Boobies",
            /* NFT symb */      "BOOB",
            /* freeMint */      true
        );

        ClaimerContract = new Claimer(
            /* token */ address(TokenContract),
            /* nft */   address(NftContract),
            /* pace */  604800,
            /* claim */ 5,
            /* burn */  5,
            /* brnOn*/  true,
            /* burnWal*/ 0x000000000000000000000000000000000000dEaD
        );

        // --- TOKENS ---
        vm.stopPrank();
        vm.startPrank(cnctOwner);
        NftContract.transferFrom(cnctOwner, user1, 1);
        NftContract.transferFrom(cnctOwner, user2, 2);
        NftContract.transferFrom(cnctOwner, user3, 3);
        uint256 totalAmount = TokenContract.balanceOf(cnctOwner);
        TokenContract.transfer(address(ClaimerContract), totalAmount);
        TokenContract.setWhitelistAddress(address(ClaimerContract)); /* ************remember********** */

        vm.stopPrank();
        vm.startPrank(user1);
        vm.deal(user1, 1_000_000 ether);
        require(IERC20(TokenContract).approve(address(ClaimerContract), maxtokens), "Approve failed!");

        vm.stopPrank();
        vm.startPrank(user2);
        vm.deal(user2, 1_000_000 ether);
        require(IERC20(TokenContract).approve(address(ClaimerContract), maxtokens), "Approve failed!");

        vm.stopPrank();
        vm.startPrank(user3);
        vm.deal(user3, 1_000_000 ether);
        require(IERC20(TokenContract).approve(address(ClaimerContract), maxtokens), "Approve failed!");
    }

    function consoleLogs() public view{
        console.log("_____________________CONTRT_INFOM_____________________");
        console.log("CNCT OWNR: ", address(cnctOwner));
        console.log("TOKN ADDR: ", address(TokenContract));
        console.log("TOKN SUPL: ", TokenContract.totalSupply());
        console.log("TOKN OWNR: ", TokenContract.balanceOf(cnctOwner));
        console.log("NFTS ADDR: ", address(NftContract));
        console.log("NFTS SUPL: ", NftContract.totalSupply());
        console.log("DAPP ADDR: ", address(ClaimerContract));
        console.log("DAPP TOKN: ", TokenContract.balanceOf(address(ClaimerContract)));

        console.log("_____________________WALLET_INFOM_____________________");
        console.log("USR1 WLLT: ", address(user1));
        console.log("USR1 GASB: ", address(user1).balance);
        console.log("USR1 ERCB: ", TokenContract.balanceOf(address(user1)));
        console.log("USR1 NFTS: ", NftContract.balanceOf(address(user1)));
        console.log("USR2 WLLT: ", address(user2));
        console.log("USR2 GASB: ", address(user2).balance);
        console.log("USR2 ERCB: ", TokenContract.balanceOf(address(user2)));
        console.log("USR2 NFTS: ", NftContract.balanceOf(address(user2)));
        console.log("USR3 WLLT: ", address(user3));
        console.log("USR3 GASB: ", address(user3).balance);
        console.log("USR3 ERCB: ", TokenContract.balanceOf(address(user3)));
        console.log("USR3 NFTS: ", NftContract.balanceOf(address(user3)));
    }

    function test_0_ConsoleLogs() public view{
        consoleLogs();
    }

    function transfer() public {
        vm.stopPrank();
        vm.startPrank(user1);

        uint256 totalBal = TokenContract.balanceOf(user1);
        uint amount = totalBal / 2;
        TokenContract.transfer(user2, amount);
        TokenContract.transfer(user3, amount);
        
        vm.stopPrank();
        vm.startPrank(cnctOwner);
    }

    function claim() public {
        vm.stopPrank();
        vm.startPrank(user1);
        ClaimerContract.claim(1);

        vm.stopPrank();
        vm.startPrank(user2);
        ClaimerContract.claim(2);

        vm.stopPrank();
        vm.startPrank(user3);
        ClaimerContract.claim(3);
    }

    function test_1_RunNormalProcedure() public{
        transfer();
        consoleLogs();
        claim();
        consoleLogs();
    }
}