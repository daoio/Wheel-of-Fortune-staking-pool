// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./stakingToken/FortuneCoin.sol";
import "./WheelOfFortune/WheelOfFortune.sol";

contract Treasury {
    FortuneCoin fortuneCoin;
    WheelOfFortune wheelOfF;

    address public treasuryOwner;

    constructor () {
        treasuryOwner = msg.sender;
    }

    modifier onlyTreasuryOwner {
        require(msg.sender == treasuryOwner, "Access denied: You are not the Treasury owner!");
        _;
    }

    function _treasuryOwner() external view returns(address) {
        return treasuryOwner;
    }

    function setAddresses(address _token, address _wof) external onlyTreasuryOwner {
        fortuneCoin = FortuneCoin(_token);
        wheelOfF = WheelOfFortune(_wof);
    }

    function withdrawFunds(address payable _winner) external {
        require(_winner == wheelOfF.getWinner(), "You're not the winner");
        fortuneCoin.transfer(_winner, fortuneCoin.balanceOf(address(this)));
    }

    function getTreasuryBalance() external view returns(uint256) {
        return fortuneCoin.balanceOf(address(this));
    }
}
