// SPDX-License-Identifier: GNU
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Standard721.sol";
import "../src/CustomERC20.sol";

contract contractTest is Test {
    NFT public NFTcontract;
    Token public CustomERC20;

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
        CustomERC20 = new Token(
            "Test Token",
            "T20",
            treasury,
            dev1,
            dev2,
            200,
            200,
            200,
            1000,
            testAddresses
        );
        
        NFTcontract = new NFT(
            1,
            0,
            //0x0000000000000000000000000000000000000000,
            address(CustomERC20),
            address(cnctOwner),
            5,
            "Test NFT Collection",
            "T721"
        );

        // --- TOKENS ---
        vm.deal(user1, 1_000_000 ether);
        vm.deal(user2, 1_000_000 ether);
        vm.deal(user3, 1_000_000 ether);

        vm.stopPrank();
        vm.startPrank(user1);
        //deal(CustomERC20, user1, 1_000_000_000_069 ether);
        require(IERC20(CustomERC20).approve(
            address(NFTcontract), 
            maxtokens), 
            "Approve failed!"
        );

        vm.stopPrank();
        vm.startPrank(user2);
        //deal(CustomERC20, user2, 1_000_000_000_069 ether);
        require(IERC20(CustomERC20).approve(
            address(NFTcontract), 
            maxtokens), 
            "Approve failed!"
        );

        vm.stopPrank();
        vm.startPrank(user3);
        //deal(CustomERC20, user3, 1_000_000_000_069 ether);
        require(IERC20(CustomERC20).approve(
            address(NFTcontract), 
            maxtokens), 
            "Approve failed!"
        );
    }

    function consoleLogs() public view{
        console.log("_____________________TOKENS_INFOM_____________________");
        console.log("TOKN ADDR: ", address(NFTcontract));
        console.log("NFTS NAME: ", NFTcontract.name());
        console.log("NFTS SYMB: ", NFTcontract.symbol());
        console.log("NFTS TOTS: ", NFTcontract.totalSupply());
        console.log("NFTS BURI: ", NFTcontract.baseUri());

        console.log("_____________________WALLET_INFOM_____________________");
        console.log("OWNR GASB: ", address(cnctOwner).balance);
        console.log("USR1 GASB: ", address(user1).balance);
        console.log("USR2 GASB: ", address(user2).balance);
        console.log("USR3 GASB: ", address(user3).balance);
        console.log("OWNR ERC2: ", CustomERC20.balanceOf(cnctOwner));
        console.log("USR1 ERC2: ", CustomERC20.balanceOf(user1));
        console.log("USR2 ERC2: ", CustomERC20.balanceOf(user2));
        console.log("USR3 ERC2: ", CustomERC20.balanceOf(user3));
        console.log("OWNR NFTB: ", NFTcontract.balanceOf(cnctOwner));
        console.log("USR1 NFTB: ", NFTcontract.balanceOf(user1));
        console.log("USR2 NFTB: ", NFTcontract.balanceOf(user2));
        console.log("USR3 NFTB: ", NFTcontract.balanceOf(user3));
    }

    function devActions(
        bool _pullFunds, 
        uint256 _walletMax, 
        uint256 _mintPrice, 
        address _paymentToken) public {
        NFTcontract.devActions(
            _pullFunds, 
            _walletMax, 
            _mintPrice, 
            _paymentToken
        );
    }

    function freeMint() public {
        NFTcontract.mint();
    }

    function gasMint(uint cost) public {
        NFTcontract.mint{value: cost}();
    }
    
    function ercMint() public {
        NFTcontract.mint();
    }

    function burn(uint tokid) public {
        NFTcontract.burn(tokid);
    }

    function test() public {
        consoleLogs();
        vm.stopPrank();
        vm.startPrank(cnctOwner);
        //devActions(false, 1, 1000000000000000000, address(0));
        devActions(false, 1, 1000000000000000000, address(CustomERC20));
        vm.stopPrank();
        vm.startPrank(user1);
        //gasMint(1000000000000000000);
        ercMint();
        consoleLogs();
        //ercMint();
        //burn(6);
        //consoleLogs();
    }

    // TEST: devActions (make it reusable for the other tests)
    // TEST: mintOverMax
    // TEST: mintWithoutGasPrice
    // TEST: mintWithoutERC20Price
    // TEST: burn

}