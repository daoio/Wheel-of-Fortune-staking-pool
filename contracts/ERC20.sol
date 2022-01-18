// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./interfaces/IERC20Metadata.sol";
import "./helpers/Owned.sol";

contract ERC20 is IERC20, IERC20Metadata, Owned {
    /*Keeps track of accounts balances*/
    mapping(address => uint256) public _balances;
    mapping(address =>mapping(address => uint256)) public _allowances;

    uint256 public _totalSupply;
    uint256 public _fee;
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    address public _treasury;
    
    event TreasuryFee(address indexed from, uint256 amount);
    /*  TS = 1,000,000;
        decimals = 18;
        Final number = 1,000,000 * 10**18;
    */
    constructor (
        string memory name, 
        string memory symbol, 
        uint256 supply, 
        uint8 decimals, 
        uint8 fee, 
        address treasury
        ) 
    {
        _decimals = decimals;
        _name = name;
        _symbol = symbol;
        _fee = fee;
        _treasury = treasury;
        _mint(msg.sender, supply*10**decimals);
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function totalSupply() external view virtual override returns(uint256) {
        return _totalSupply;
    }

    function decimals() external view virtual override returns (uint8) {
        return _decimals;
    }

    function balanceOf(address _account) public view virtual override returns (uint256) {
        return _balances[_account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    //This function mints fixed total supply and can be called only one time by constructor.
    function _mint(address _to, uint256 _amount) internal virtual {
        require(_to != address(0), "Can't mint tokens to 0 address");
        _totalSupply += _amount;
        _balances[_to] = _amount;
    }

    function transfer(address _to, uint256 _amount) public virtual override returns(bool) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[_sender][msg.sender];
        require(currentAllowance >= _amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(_sender, msg.sender, currentAllowance - _amount);
        }
        _transfer(_sender, _recipient, _amount);

        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /* With this function x% of all trades goes to Treasury Contract;
    For example:
    _fee = 5%;
    Alice sends 100 TOKENS to Bob
    after all requires passed, function calculates fee from sended amount;
    In our case it would be 5 tokens, so then balance of ALice decreases to 100
    and balance of Bob and Treasury increases by 95 and 5 respectively;
    */
    function _transfer(address _from, address _to, uint256 _amount) internal virtual {
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
}