// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/* contract v1.0 by www.twitter.com/s0crates_eth */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract bonNFTStaking is ERC721Holder, Ownable {
    IERC721 public nft;
    IERC20 public erc20Token;
    
    mapping(uint256 => address) public tokenOwnerOf;
    mapping(uint256 => uint256) public tokenStakedAt;
    mapping(uint256 => bool) public isStaked;

    uint256 public minimumTime = 7 days;
    uint256 public price = 420000000000000000; // 0.42 matic tax  //!!!!!! change this price1 && add price2
	uint256 public rwdRate = 10; // 0.1% of the CURRENT $BON balance
    bool public isStakeActive;

    event newStaked(address sender, uint256 tokenId);
    event newUnstaked(address sender, uint256 tokenId, uint256 reward); //!!!!!!!this should be userReward

    constructor(address _nftAddress, address _tokenAddress){
        nft = IERC721(_nftAddress);
        erc20Token = IERC20(_tokenAddress);
    }

    function stake(uint256 tokenId) external payable{
        require(isStakeActive, "Staking is paused.");
        require(price <= msg.value, "Insufficient gas value");
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        // holderNFT mint should go here
        tokenOwnerOf[tokenId] = msg.sender;
        tokenStakedAt[tokenId] = block.timestamp;
        isStaked[tokenId] = true;

        emit newStaked(msg.sender, tokenId);
    }

    function calculateRewards(uint256 tokenId) public view returns (uint256) {
        require(isStaked[tokenId], "This Token id was never staked");
        uint erc20Balance = erc20Token.balanceOf(address(this)); 
        return erc20Balance * (rwdRate / 10000);
    }

    function calculateTime(uint256 tokenId) public view returns (uint256) {
        require(isStaked[tokenId], "This Token id was never staked");
        uint256 timeElapsed = block.timestamp - tokenStakedAt[tokenId];
        return timeElapsed;
    }

    function unstake(uint256 tokenId) external{
        uint256 userReward = calculateRewards(tokenId);
        uint256 timeElapsed = calculateTime(tokenId);

        require(tokenOwnerOf[tokenId] == msg.sender, "You can't unstake because you are not the owner");
        require(timeElapsed >= minimumTime, "You must wait the minimum time before claiming rewards");
        require(userReward > 0, "No rewards to claim");
        
        delete tokenOwnerOf[tokenId];
        delete tokenStakedAt[tokenId];
        delete isStaked[tokenId];

        // holderNFT burn should go here
        nft.transferFrom(address(this), msg.sender, tokenId);
        erc20Token.transferFrom(address(this), msg.sender, userReward);

        emit newUnstaked(msg.sender, tokenId, userReward);
    } //!!!!!!!!!!make this payable and include price2 (it will be set at suuuuper low cost)

    // onlyOwnerz
    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }
    function setTime(uint256 _minimumTime) external onlyOwner {
        minimumTime = _minimumTime;
    }
    function setRate(uint256 _rwdRate) external onlyOwner {
        rwdRate = _rwdRate;
    }
    function flipStakeState() external onlyOwner {
        isStakeActive = !isStakeActive;
    }
    function closePool() external payable onlyOwner {
        uint256 balance = address(this).balance;
        uint256 bonTreasury = balance * 70 / 100;
        uint256 bonStakers = balance * 20 / 100;
        uint256 bonDevs = balance - (bonTreasury + bonStakers);
        ( bool transferOne, ) = payable(0xd02b97b0B3439bf032a237f712a5fa5B161D89d3).call{value: bonTreasury}("");
        ( bool transferTwo, ) = payable(0xad87F2c6934e6C777D95aF2204653B2082c453de).call{value: bonStakers}("");
        ( bool transferThree, ) = payable(0xb1a23cD1dcB4F07C9d766f2776CAa81d33fa0Ede).call{value: bonDevs}("");
        require(transferOne && transferTwo && transferThree, "Transfer failed.");
    }
}


/* ---deployed address---

*/

/* ---ABI---

*/
