import { ethers, upgrades } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  const priceFeedAddress = "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419"; // Ethereum Mainnet
  // const priceFeedAddress = "0x694AA1769357215DE4FAC081bf1f309aDC325306"; // Ethereum Sepolia
  
  const DSUStablecoin = await ethers.getContractFactory("DSUStablecoinUpgradeable");
  
  // const ethAddress = "0x2170Ed0880ac9A755fd29B2688956BD959F933F8"; // BNB
  const ethAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";  // Ethereum Mainnet
  // const ethAddress = "0xd38E5c25935291fFD51C9d66C3B7384494bb099A" // Sepolia
  
  const proxy = await upgrades.deployProxy(DSUStablecoin, [priceFeedAddress, deployer.address, true, ethAddress], {
    initializer: "initialize",
  });
  await proxy.waitForDeployment();
  console.log("DSUStablecoin Proxy deployed to:", await proxy.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
