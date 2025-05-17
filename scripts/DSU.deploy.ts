const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying DSUStablecoin with account:", deployer.address);

    // const priceFeedAddress = "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419" // ETH
    // const priceFeedAddress = "0x694AA1769357215DE4FAC081bf1f309aDC325306" // Sepolia

    const priceFeedAddress = "0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE" // BSC

    const DSUStablecoin = await ethers.getContractFactory("DSUStablecoin");
    const dsu = await DSUStablecoin.deploy(priceFeedAddress);

    await dsu.waitForDeployment();

    console.log("DSUStablecoin deployed to:", await dsu.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


