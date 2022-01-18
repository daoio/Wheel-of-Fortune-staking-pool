const hre = require("hardhat");

async function main() {
  
  //1) TREASURY
  console.log("---------------------------------------")
  console.log("Deploying Treasury.sol");
  const Treasury = await hre.ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy();

  await treasury.deployed();

  console.log("Treasury deployed to:", treasury.address);

  //2) FORTUNE COIN
  console.log("Deploying FortuneCoin.sol");
  const FC = await hre.ethers.getContractFactory("FortuneCoin");
  const fc = await FC.deploy(treasury.address);

  await fc.deployed();

  console.log("FortuneCoin deployed to:", fc.address);

  //3) STAKING POOL
  console.log("Deploying StakingPool.sol");
  const SP = await hre.ethers.getContractFactory("StakingPool");
  const sp = await SP.deploy(fc.address);

  await sp.deployed();

  console.log("StakingPool deployed to:", sp.address);

  //4) WHEEL OF FORTUNE
  console.log("Deploying WheelOfFortune.sol");
  const WoF = await hre.ethers.getContractFactory("WheelOfFortune");
  const wof = await WoF.deploy(sp.address, fc.address);

  await wof.deployed();

  console.log("WheelOfFortune deployed to:", wof.address);

  //5) TREASURY setAddresses();
  console.log("Calling Treasury.sol setAddresses()");
  await treasury.setAddresses(fc.address, wof.address);
  console.log("Addresses has been set");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
