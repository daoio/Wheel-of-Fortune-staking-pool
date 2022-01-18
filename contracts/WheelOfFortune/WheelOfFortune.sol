// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RandomNumberConsumer.sol";
import "../stakingPool/StakingPool.sol";
import "../Treasury.sol";

contract WheelOfFortune is RandomNumberConsumer {
    StakingPool public stakingPool;
    Treasury public treasury;

    address payable owner;
    address payable public winner;

    event WinnerChosen(address indexed winner, uint256 _amount);

    constructor (address payable _sp, address payable _tr) {
        stakingPool = StakingPool(_sp);
        treasury = Treasury(_tr);
        owner = payable(msg.sender);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function getWinner() external view returns(address payable) {
        return winner;
    }

    function getRandomNumber() public override onlyOwner returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        require(stakingPool.epochState() == false, "Epoch didn't end");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = (randomness % stakingPool.countParticipants()) + 1;
        winner = payable(stakingPool.getParticipant(randomResult));
        emit WinnerChosen(winner, treasury.getTreasuryBalance());
        treasury.withdrawFunds(winner);
    }
}