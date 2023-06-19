// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/*
NOTES:
- test needs to be run via Alchemy rpc:
    "forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi -vvv"
*/

import "forge-std/Test.sol";
import "../src/MV3D.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract contractTest is Test {
    NFT public NFTcontract;
    address public USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;

    function setUp() public{
        // --- WALLETS ---
        address user = address(69);
        vm.startPrank(user);

        address[] memory testAddresses = new address[](5);
            testAddresses[0] = address(1);
            testAddresses[1] = address(2);
            testAddresses[2] = address(3);
            testAddresses[3] = address(4);
            testAddresses[4] = address(5);

        // --- TOKENS ---
        vm.deal(user, 1_000_000 ether);
        deal(USDT, user, 1_000_000_000_069 ether);
        require(IERC20(USDT).approve(
            0x8fA079a96cE08F6E8A53c1C00566c434b248BFC4, 
            115792089237316195423570985008687907853269984665640564039457584007913129639935), 
            "Approve failed!");
        
        // contract setup
        NFTcontract = new NFT(
            testAddresses,
            USDT,
            50000000000000000000,
            1000000000000000,
            380,
            100,
            false,
            "Modulusverse 3D",
            "MV3D"
        );
    }

    function consoleLogs() public view{
        console.log("_____________________TOKENS_INFOM_____________________");
        console.log("TOKN ADDR: ", address(NFTcontract));
        console.log("TOKN TSUP: ", NFTcontract.totalSupply());
        console.log("ERC2 ADDR: ", NFTcontract.erc20contract());
        console.log("ERC2 NAME: ", ERC20(USDT).name());
        console.log("ERC2 TSUP: ", ERC20(USDT).totalSupply());
        console.log("ERC2 PRCE: ", NFTcontract.erc20Price());
        console.log("GAS  PRCE: ", NFTcontract.gasPrice());
        console.log("MAX  TKNS: ", NFTcontract.maxTokens());
        console.log("MAX  MINT: ", NFTcontract.maxMintAmount());
        console.log("SALE ACTV: ", NFTcontract.isSaleActive());
        console.log("BASE  URI: ", NFTcontract.baseUri());
        console.log("BASE EXTN: ", NFTcontract.baseExtension());


        console.log("_____________________WALLET_INFOM_____________________");
        console.log("CNRT GASB: ", address(NFTcontract).balance);
        console.log("CNRT ERCB: ", ERC20(USDT).balanceOf(address(NFTcontract)));
        console.log("OWNR ERCB: ", ERC20(USDT).balanceOf(address(69)));
        console.log("OWNR TBAL: ", NFTcontract.balanceOf(address(69)));
        console.log("WLT1 TBAL: ", NFTcontract.balanceOf(address(1)));
        console.log("WLT2 TBAL: ", NFTcontract.balanceOf(address(2)));
        console.log("WLT3 TBAL: ", NFTcontract.balanceOf(address(3)));
        console.log("WLT4 TBAL: ", NFTcontract.balanceOf(address(4)));
        console.log("WLT5 TBAL: ", NFTcontract.balanceOf(address(5)));

    }

    function test_0_ConsoleLogs() public view{
        consoleLogs();
    }

    function mint() public{
        NFTcontract.flipSaleState();
        NFTcontract.mint{value: 2000000000000000}(2);
    }

    function test_1_mint() public{
        mint();
        consoleLogs();
        console.log("NFT  TURI: ", ERC721(NFTcontract).tokenURI(7));
    }

    function withdrawAll() public{
        mint();
        NFTcontract.withdrawAll(address(696969));
    }

    function test_2_withdraw() public{
        withdrawAll();
        consoleLogs();
        console.log("DEVS GASB: ", address(696969).balance);
        console.log("DEVS ERCB: ", ERC20(USDT).balanceOf(address(696969)));
    }

}