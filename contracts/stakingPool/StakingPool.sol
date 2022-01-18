// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../stakingToken/FortuneCoin.sol";

contract StakingPool {

    // VARIABLES
    FortuneCoin public stakeToken;
    uint256 private totalStake;
    address[] public distributionParticipants;
    address payable owner;

    /*
    Each new epoch of staking begins with the end
    of the distribution of tokens from the treasury
    (except for the very first one). And it ends before the distribution,
    at this point users can find out the number
    of seats they will receive in the new distribution.
    */
    uint256 public epoch;
    bool public epochStarted;

    // MAPPINGS

    /* staking */
    mapping(address => bool) public stakeholders;
    mapping(address=> uint256) public stakeAmount;
    mapping(address => uint256) public stakingTime;

    /* distribution */
    mapping(address => bool) public _distributionParticipants;
    mapping(address => uint256) public callsCount;

    constructor (address payable _stakeToken) {
        stakeToken = FortuneCoin(_stakeToken);
        owner = payable(msg.sender);
    }

    // MODIFIERS
    modifier stakeholdersOnly {
        require(isStakeHolder(msg.sender) == true, "You're not a stakeholder");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier epochEnded {
        require(epoch < block.timestamp);
        _;
    }
    
    modifier onlyOnce {
        require(callsCount[msg.sender] == 1);
        _;
    }

    // FUNCTIONS THAT INTERACT WITH STAKEHOLDERS
    function isStakeHolder(address _account) internal view returns(bool) {
        return stakeholders[_account];
    }

    function addStakeHolder(address _account) internal {
        require(stakeholders[_account] != true, "You're already a stakeholder");
        stakeholders[_account] = true;
        stakingTime[msg.sender] = block.timestamp;
    }

    function removeStakeHolder(address _account) internal {
        require(stakeholders[_account] == true, "You're not a stakeholder");
        stakeholders[_account] = false; 
    }

    // FUNCTIONS THAT INTERACT WITH STAKES AMOUNTS
    function stakeOf(address _account) public view returns(uint256) {
        return stakeAmount[_account];
    }

    function stake(uint256 _amount) external {
        require(stakeToken.balanceOf(msg.sender) >= _amount, "Invalid amount provided");
        stakeToken.transferFrom(msg.sender, address(this), _amount); // Including fees;
        totalStake += _amount;
        if (isStakeHolder(msg.sender) == true) {
            stakeAmount[msg.sender] += _amount;
            stakingTime[msg.sender] = block.timestamp;
            if (callsCount[msg.sender] != 1) {
                callsCount[msg.sender] = 1;
            } else if (callsCount[msg.sender] == 1) {} // do nothing
        } else {
            addStakeHolder(msg.sender);
            stakeAmount[msg.sender] += _amount;
            if (callsCount[msg.sender] != 1) {
                callsCount[msg.sender] = 1;
            } else if (callsCount[msg.sender] == 1) {}
        }

    }

    function unstake(uint256 _amount) external stakeholdersOnly {
        require(stakeAmount[msg.sender] >= _amount, "Invalid amount provided");
        stakeToken.transfer(msg.sender, _amount);
        totalStake -= _amount;
        if (stakeOf(msg.sender) == _amount) {
            removeStakeHolder(msg.sender);
            stakeAmount[msg.sender] -= _amount;
        } else {
            stakeAmount[msg.sender] -= _amount;
        }
    }


    // Calculating the places;
    function getPlace(address _account) external stakeholdersOnly epochEnded onlyOnce returns(string memory) {
        uint256 stakeShare = (stakeAmount[_account] * 100) / totalStake;
        /* 
        Account must hold more than 1% of totalStake
        to participate in distibution of treasury tokens
        OR
        hold stakingTokens more than 4 weeks;
        */
        if (stakeShare < 1 && stakeShare > 0) {
            callsCount[msg.sender] = 0;
            return "You have 0 places";
        } else if (stakeShare < 1 && stakeShare > 0 && (block.timestamp - stakingTime[_account]) > 4 weeks ) {
            require(_distributionParticipants[_account] != true);
            callsCount[msg.sender] = 0;
            _distributionParticipants[_account] = true;
            distributionParticipants.push(_account);
            return "You have 1 place";
        } else if (stakeShare < 10 && stakeShare >= 1) {
           require(_distributionParticipants[_account] != true);
           callsCount[msg.sender] = 0;
            _distributionParticipants[_account] = true;
            distributionParticipants.push(_account);
            return "You have 1 place";
        } else if (stakeShare <= 35 && stakeShare > 10) {
            require(_distributionParticipants[_account] != true);
            callsCount[msg.sender] = 0;
            _distributionParticipants[_account] = true;
                for (uint256 i = 0; i != 2; i++) {
                    distributionParticipants.push(_account);
                }
            return "You have 2 places";
        } else if (stakeShare <= 75 && stakeShare > 35) {
            require(_distributionParticipants[_account] != true);
            callsCount[msg.sender] = 0;
            _distributionParticipants[_account] = true;
                for (uint256 i = 0; i != 3; i++) {
                    distributionParticipants.push(_account);
                }
            return "You have 3 places";
        } else if (stakeShare <= 100 && stakeShare > 75) {
            require(_distributionParticipants[_account] != true);
            callsCount[msg.sender] = 0;
            _distributionParticipants[_account] = true;
                for (uint256 i = 0; i != 4; i++) {
                    distributionParticipants.push(_account);
                }
            return "You have 4 places";
        }
    }

    // EPOCH FUNCTIONS
    function startNewEpoch() external onlyOwner {
        require(epochStarted != true);
        epoch = block.timestamp + 4 weeks;
        epochStarted = true;
        // Reset _dp mapping and clear dp array;
        for (uint256 i = 0; i < distributionParticipants.length; i++){
            _distributionParticipants[distributionParticipants[i]] = false;
        }
        distributionParticipants = new address[](0);
    }

    function endEpoch() external onlyOwner {
        require(epochStarted == true && epoch < block.timestamp);
        epochStarted = false;
    }

    function epochState() external view returns(bool) {
        return epochStarted;
    }

    // PARTICIPANTS GETTER FUNCTIONS
    function countParticipants() public view returns(uint256) {
        return distributionParticipants.length;
    }

    function getParticipant(uint256 position) external view returns(address) {
        return distributionParticipants[position];
    }
}