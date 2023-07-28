// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.-. $GAYG GAY GENSLER MEME TOKEN -.-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

// We SUPPORT LGBTQ rights ~~ We do NOT SUPPORT Gary Gensler
// 50% of tax raised will be sent to the LGBTQ Freedom Fund

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract GAYG is Ownable, ERC20, ERC20Burnable{
    
    address public devs;
    uint public tax;

    mapping(address => bool) public whitelistedAddress;

    event DevsAddressUpdated(address newDevs);
    event TaxUpdated(uint newTax);
    event WhitelistAddressUpdated(address newWhitelist);
    
    constructor(
        string memory _name, // Gay Gary Gensler
        string memory _symbol, // $GAYG
        address _devs, // tax multisig
        uint _tax, // 450 (4.5%)
        address[] memory _airdropAddresses
        ) ERC20(_name, _symbol) {
            _mint(msg.sender, (64_887_879) * 10 ** decimals()); // 93.1% of total supply
            
            uint length = _airdropAddresses.length;
            uint ADPerWallet = ((4_809_090) / length) * 10 ** decimals(); // 6.9% of total supply
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
        require(_dev != address(0), "ERROR: Cant be zero address");
        devs = _dev;
        whitelistedAddress[_dev] = true;
        emit DevsAddressUpdated(_dev);
    }

    function setTax(uint _tax) external onlyOwner{
        require(_tax != 0, "ERROR: Tax cannot be 0");
        tax = _tax;
        emit TaxUpdated(_tax);
    }

    function setWhitelistAddress(address _whitelist) external onlyOwner{
        require(_whitelist != address(0), "ERROR: Cant be zero address");
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
