// SPDX-License-Identifier: GNU
pragma solidity ^0.8.17;


import "forge-std/Test.sol";
import "../src/Standard721.sol";

contract contractTest is Test {
    NFT public NFTcontract;

    function setUp() public{
        // --- WALLETS ---
        address user = address(69);
        vm.startPrank(user);

        // --- TOKENS ---
        vm.deal(user, 1_000_000 ether);

        // contract setup
        NFTcontract = new NFT(
            address(69),        // receiving wallet
            380,                // reserved amount
            "Modulusverse 3D",  // name
            "MV3D"              // symbol
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
        console.log("OWNR NFTB: ", NFTcontract.balanceOf(address(69)));
    }

    function test_0_ConsoleLogs() public view{
        consoleLogs();
    }

}