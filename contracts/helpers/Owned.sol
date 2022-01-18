// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Owned {
    address public _owner;

    constructor () {
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == _owner, "Access denied");
        _;
    }
}