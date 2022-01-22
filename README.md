# Wheel-of-Fortune-staking-pool
A staking pool whose participants stake their tokens in order to take part in the wheel of fortune and take all the funds from the treasury.

# Staking Pool
Staking starts when new epoch started by the owner of the contract. Each staking epoch lasts 4 weeks.
Users deposit they FortuneCoins into the pool. Then pool calculates total stake amount and the percentage share of each pool participant. Wallets whose share in the pool is > 1% && < 10%, get 1 place, 10-35% - 2 places, 35-75% - 3 places, 75-100% - 4 places in future WheelOfFortune lottery. Small shareholders whose share is < 1% can get 1 place if they stake FortuneCoin tokens more than 4 weeks.

# Wheel of Fortune
From each FortuneCoin trade 5% of it goes to the Treasury. Staking Pool participants after the end of Epoch can take a place in the WoF lottery. The winner of the lottery  would take all the funds from the Treasury. Participants should manually get they places from stakingPool after the end of epoch, then lottery, with using of Chainlink VRF, calculates the winner from all the users who has a place in distribution and transfers FortuneCoins directly to the winner. Then new epoch starts and all the actions are repeated again.
