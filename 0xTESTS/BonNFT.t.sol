// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/*
NOTES:
- test needs to be run via Alchemy rpc
forge test --fork-url https://polygon-mainnet.g.alchemy.com/v2/elpiyNU3HOchYaeMMpCteXolAFqJYTEi -vvv
*/


import "forge-std/Test.sol";
import "../src/BonNFT.sol";

contract contractTest is Test {
    bonNFT public contractTested;
    address public RVLT = 0xf0f9D895aCa5c8678f706FB8216fa22957685A13;

    function setUp() public{
        // wallets setup
        address user = address(69);
        vm.startPrank(user);
        address[] memory testAddresses = new address[](3);
            testAddresses[0] = address(70);
            testAddresses[1] = address(71);
            testAddresses[2] = address(72);

        // token setup
        vm.deal(user, 1_000_000 ether);
        deal(RVLT, user, 1_000_000_000_000 ether);
        bool success = IERC20(RVLT).approve(
            0x8fA079a96cE08F6E8A53c1C00566c434b248BFC4, 
            115792089237316195423570985008687907853269984665640564039457584007913129639935);
        require(success, "Approve failed");
        
        // contract setup
        contractTested = new bonNFT(testAddresses);
    }

    function test_initialState() public{
        assertEq(contractTested.totalSupply(), 43);
    }

    function test_nftTokenTransferAndMinting() public{
        contractTested.flipSaleState();
        uint beforeErcBal = IERC20(RVLT).balanceOf(address(69));
        contractTested.mint{value: 1 ether}(2);
        uint afterErcBal = IERC20(RVLT).balanceOf(address(69));
        assertFalse(beforeErcBal == afterErcBal);
        assertEq(contractTested.totalSupply(), 45);
    }

    function testFail_mintingGasNotEnough() public{
        contractTested.flipSaleState();
        contractTested.mint{value: 1}(2);
    }

    function testFail_mintButSaleNotActive() public{
        contractTested.mint{value: 1 ether}(2);
    }
    
    function testFail_mintSurpassMax() public{
        contractTested.flipSaleState();
        contractTested.mint(11);
    }

    function test_withdrawAll() public{
        contractTested.flipSaleState();
        contractTested.mint{value: 1 ether}(2);
        uint b4Wallet70erc = IERC20(RVLT).balanceOf(address(70));
        uint b4Wallet71erc = IERC20(RVLT).balanceOf(address(71));
        uint b4Wallet72erc = IERC20(RVLT).balanceOf(address(72));
        uint b4Wallet70gas = address(70).balance;
        uint b4Wallet71gas = address(71).balance;
        uint b4Wallet72gas = address(72).balance;
        contractTested.withdrawAll(address(70), address(71), address(72));
        uint AftWallet70erc = IERC20(RVLT).balanceOf(address(70));
        uint AftWallet71erc = IERC20(RVLT).balanceOf(address(71));
        uint AftWallet72erc = IERC20(RVLT).balanceOf(address(72));
        uint AftWallet70gas = address(70).balance;
        uint AftWallet71gas = address(71).balance;
        uint AftWallet72gas = address(72).balance;
        assertTrue(b4Wallet70erc == 0);
        assertFalse(AftWallet70erc == 0);
        assertTrue(b4Wallet70gas == 0);
        assertFalse(AftWallet70gas == 0);
        assertFalse(b4Wallet70erc == AftWallet70erc);
        assertFalse(b4Wallet70gas == AftWallet70gas);
        assertFalse(b4Wallet71erc == AftWallet71erc);
        assertFalse(b4Wallet71gas == AftWallet71gas);
        assertFalse(b4Wallet72erc == AftWallet72erc);
        assertFalse(b4Wallet72gas == AftWallet72gas);
    }

}