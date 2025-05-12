const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying DSUStablecoin with account:", deployer.address);

    // const priceFeedAddress = "0x6D9C96fb3E5559aF7Cb5890cBff70215b1355B6a";  // bsc
    // const priceFeedAddress = "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419"   // ethereum
    const priceFeedAddress = "0x694AA1769357215DE4FAC081bf1f309aDC325306"   // sepolia

    // const ethAddress = "0x2170Ed0880ac9A755fd29B2688956BD959F933F8"; // BNB
    // const ethAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";  // Ethereum Mainnet
    const ethAddress = "0xd38E5c25935291fFD51C9d66C3B7384494bb099A" // Sepolia

    const feeReceiver = deployer.address;     // who receives 1% fee
    const ethIsNative = true;                           // true if using native ETH

    const DSUStablecoin = await ethers.getContractFactory("DSUStablecoin");
    const dsu = await DSUStablecoin.deploy(priceFeedAddress, feeReceiver, ethIsNative, ethAddress);

    await dsu.waitForDeployment();

    console.log("DSUStablecoin deployed to:", await dsu.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


