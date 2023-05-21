// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract ChadGPT is Ownable, ERC20, ERC20Burnable{
    
    address public devs;
    uint public tax;

    mapping(address => bool) public whitelistedAddress;

    event DevsAddressUpdated(address newDevs);
    event WhitelistAddressUpdated(address newWhitelist);
    
    constructor(
        string memory _name, // ChadGPT Alpha Meme
        string memory _symbol, // ChadGPT
        address _devs, // dev multisig
        uint _tax, // dev multisig
        address[] memory _airdropAddresses
        ) ERC20(_name, _symbol) {
            _mint(msg.sender, (402_762_762_765) * 10 ** decimals()); // 95.8% of total supply
            
            uint length = _airdropAddresses.length; // 4.2% of total supply
            uint ADPerWallet = ((17_657_657_655) / length) * 10 ** decimals();
            for (uint i; i < length; ) {
                _mint(_airdropAddresses[i], ADPerWallet);
                unchecked { ++i; }
            }

            tax = _tax;
            devs = _devs;
            whitelistedAddress[msg.sender] = true;
            whitelistedAddress[_devs] = true;
    }

    function setDevAddress(address _dev) external onlyOwner{
        require(_dev != address(0), "ERROR: Can not be zero address");
        devs = _dev;
        whitelistedAddress[_dev] = true;
        emit DevsAddressUpdated(_dev);
    }

    function setWhitelistAddress(address _whitelist) external onlyOwner{
        require(_whitelist != address(0), "ERROR: Can not be zero address");
        whitelistedAddress[_whitelist] = true;
        emit WhitelistAddressUpdated(_whitelist);
    }

    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
        ) internal virtual override{      
            if(whitelistedAddress[_sender] || whitelistedAddress[_recipient]){
                super._transfer(_sender, _recipient, _amount);
            }else{
                uint256 devsAmount = (_amount * tax) / 10000;
                uint256 userAmount = _amount - devsAmount;
                super._transfer(_sender, devs, devsAmount);
                super._transfer(_sender, _recipient, userAmount);
            }
    }
}
