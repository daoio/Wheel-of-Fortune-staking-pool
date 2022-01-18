// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC20.sol";

contract FortuneCoin is ERC20 {
    constructor (address payable _tr) 
        ERC20(
            "FortuneCoin", 
            "FRTN", 
            1000000, 
            18, 
            5,
            _tr
        ) {
            _mint(msg.sender, 13000000);
        }
    
    function _transfer(address _from, address _to, uint256 _amount) internal override {
        require(_from != address(0), "You can't transfer from the zero address");
        require(_to != address(0), "You can't transfer to the zero address");
        require(_balances[_from] >= _amount, "Not enough tokens on balance");
        if (_from == _treasury) {
            _balances[_from] -= _amount;
            _balances[_to] += _amount;

            emit Transfer(_from, _to, _amount);
        } else {
            uint256 feeFromTransfer = _amount * _fee / 100; 
            _balances[_from] -= _amount;
            _balances[_treasury] += feeFromTransfer;
            _balances[_to] += _amount - feeFromTransfer;

            emit Transfer(_from, _to, _amount);
            emit TreasuryFee(_from, _amount);
        }
    }

    function getTreasuryAddress() public view returns(address) {
        return _treasury;
    }

    function balanceOfTreasury() public view returns(uint256) {
        return _balances[_treasury];
    }
}