// SPDX-License-Identifier: GNU-3.0
pragma solidity ^0.8.9;

/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */
/* -.-.-.-.-.-       CUSTOM ERC20 TOKEN      -.-.-.-.-. */
/* -.-.-.-.-.    [[ BUILT BY REBEL LABS ]]    .-.-.-.-. */
/* -.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-. */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Token is Ownable, ERC20, ERC20Burnable{
    
    address private treasury;
    address private dev1;
    address private dev2;
    uint public treasTx;
    uint public devsTx;
    uint public burn;

    mapping(address => bool) public whitelistedAddress;

    constructor(
        string memory _name,
        string memory _symbol,
        address _treasury,
        address _dev1,
        address _dev2,
        uint _treasTx,
        uint _devsTx,
        uint _burn,
        uint _totalMade,
        address[] memory _airdropAddresses
        ) ERC20(_name, _symbol) {
            uint toOwner = _totalMade * 8 / 10;
            uint toAirdrop = _totalMade - toOwner;
            _mint(msg.sender, (toOwner) * 10 ** decimals());
            
            uint length = _airdropAddresses.length;
            uint ADPerWallet = ((toAirdrop) / length) * 10 ** decimals();
            for (uint i; i < length; ) {
                _mint(_airdropAddresses[i], ADPerWallet);
                unchecked { ++i; }
            }

            treasury = _treasury;
            treasTx = _treasTx;
            dev1 = _dev1;
            dev2 = _dev2;
            devsTx = _devsTx;
            burn = _burn;
            whitelistedAddress[msg.sender] = true;
            whitelistedAddress[_dev1] = true;
            whitelistedAddress[_dev2] = true;
    }

    function setVars(
        address _treasury,
        address _dev1,
        address _dev2,
        uint _treasTx,
        uint _devsTx,
        uint _burn
        ) external onlyOwner{
        require(_treasury != address(0), "ERROR: Cant be zero address");
        require(_dev1 != address(0), "ERROR: Cant be zero address");
        require(_dev2 != address(0), "ERROR: Cant be zero address");
        require(_treasTx != 0, "ERROR: TTax cannot be 0");
        require(_devsTx != 0, "ERROR: DTax cannot be 0");
        require(_burn != 0, "ERROR: Burn cannot be 0");
        treasury = _treasury;
        dev1 = _dev1;
        dev2 = _dev2;
        treasTx = _treasTx;
        devsTx = _devsTx;
        burn = _burn;
        whitelistedAddress[treasury] = true;
        whitelistedAddress[dev1] = true;
        whitelistedAddress[dev2] = true;
    }

    function setWhitelistAddress(address _whitelist) external onlyOwner{
        require(_whitelist != address(0), "ERROR: Cant be zero address");
        whitelistedAddress[_whitelist] = true;
    }

    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
        ) internal virtual override{      
            if(whitelistedAddress[_sender] || whitelistedAddress[_recipient]){
                super._transfer(_sender, _recipient, _amount);
            }else{
                uint256 treasAmount = _amount * treasTx / 10000;
                uint256 dev1Amount = _amount * devsTx / 2 / 10000;
                uint256 dev2Amount = _amount * devsTx / 2 / 10000;
                uint256 burnAmount = _amount * burn / 10000;
                uint256 userAmount = _amount - treasAmount - dev1Amount - dev2Amount - burnAmount;
                super._transfer(_sender, treasury, treasAmount);
                super._transfer(_sender, dev1, dev1Amount);
                super._transfer(_sender, dev2, dev2Amount);
                super._burn(_sender, burnAmount);
                super._transfer(_sender, _recipient, userAmount);
            }
    }
}
