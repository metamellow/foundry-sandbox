// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/*
NOTES:
- on first deploy on mainnet, use fresh temp wallets for all treasuries
- this contract owner should be ledger, but treasuries not
- 'bonStakers' set at fresh BUT THEN switched to staking contract ASAP
- 

TODO:
- consider bumping the BONDAO percent up to 7.5-10%
- test BUURRRNNN

*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract bankToken is Ownable, ERC20, ERC20Burnable {
    
    address public bonTreasury;
    address public bonStakers;
    address public bonDevs;
    uint public bonTax; //4 == 0.4%

    mapping(address => bool) public whitelistedAddress;

    event TaxUpdated(uint256 taxAmount);
    event TreasuryAddressUpdated(address newTreasury);
    event StakersAddressUpdated(address newStakers);
    event DevsAddressUpdated(address newDevs);
    event WhitelistAddressUpdated(address newWhitelist);
    

    // "BON GOVERNANCE TOKEN", "BANK", XXX, XXX, XXX, 4, airdropArray
    // do I need _nameSymb in both the first and second args?
    constructor(
        string memory _name,
        string memory _symbol,
        //uint _supply,
        address _treasury, 
        address _stakers, 
        address _devs,
        uint _tax,
        address[] memory _airdropAddresses
        ) ERC20(_name, _symbol) {
            _mint(msg.sender, (19_950_000) * 10 ** decimals());
            
            uint length = _airdropAddresses.length;
            uint ADPerWallet = ((1_050_000) / length) * 10 ** decimals();
            for (uint i; i < length; ) {
                _mint(_airdropAddresses[i], ADPerWallet);
                unchecked { ++i; }
            }

            bonTax = _tax;
            bonTreasury = _treasury;
            bonStakers = _stakers;
            bonDevs = _devs;
            whitelistedAddress[msg.sender] = true;
            whitelistedAddress[_treasury] = true;
            whitelistedAddress[_stakers] = true;
            whitelistedAddress[_devs] = true;
    }

    function setTreasuryAddress(address _treasury) external onlyOwner{
        require(_treasury != address(0), "ERROR: Can not be zero address");
        bonTreasury = _treasury;
        whitelistedAddress[_treasury] = true;
        emit TreasuryAddressUpdated(_treasury);
    }

    function setStakersAddress(address _stakers) external onlyOwner{
        require(_stakers != address(0), "ERROR: Can not be zero address");
        bonStakers = _stakers;
        whitelistedAddress[_stakers] = true;
        emit StakersAddressUpdated(_stakers);
    }

    function setDevAddress(address _dev) external onlyOwner{
        require(_dev != address(0), "ERROR: Can not be zero address");
        bonDevs = _dev;
        whitelistedAddress[_dev] = true;
        emit DevsAddressUpdated(_dev);
    }

    function setWhitelistAddress(address _whitelist) external onlyOwner{
        require(_whitelist != address(0), "ERROR: Can not be zero address");
        whitelistedAddress[_whitelist] = true;
        emit WhitelistAddressUpdated(_whitelist);
    }

    function setTax(uint256 _tax) external onlyOwner{
        require(_tax > 0 && _tax < 1000, "ERROR: Tax must be > 0 and < 1000");
        bonTax = _tax;
        emit TaxUpdated(bonTax);
    }

    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
        ) internal virtual override{      
            if(whitelistedAddress[_sender] || whitelistedAddress[_recipient]){
                super._transfer(_sender, _recipient, _amount);
            }else{
                uint256 taxAmount = (_amount * bonTax) / 1000;
                uint256 treasuryAmount = taxAmount * 50/100;
                uint256 stakersAmount = taxAmount * 30/100;
                uint256 burnAmount = taxAmount * 10/100;
                uint256 devsAmount = taxAmount * 10/100;
                uint256 userAmount = _amount - taxAmount;
                burnFrom(_sender, burnAmount);
                super._transfer(_sender, bonTreasury, treasuryAmount);
                super._transfer(_sender, bonStakers, stakersAmount);
                super._transfer(_sender, bonDevs, devsAmount);
                super._transfer(_sender, _recipient, userAmount);
            }
    }
}
