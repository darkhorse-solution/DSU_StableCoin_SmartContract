import { ethers, upgrades } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  const priceFeedAddress = "0x6D9C96fb3E5559aF7Cb5890cBff70215b1355B6a"; // Replace with your actual address
  const DSUStablecoin = await ethers.getContractFactory("DSUStablecoinUpgradeable");
  const ethAddress = "0x2170Ed0880ac9A755fd29B2688956BD959F933F8";
  const proxy = await upgrades.deployProxy(DSUStablecoin, [priceFeedAddress, deployer.address, false, ethAddress], {
    initializer: "initialize",
  });
  await proxy.waitForDeployment();
  console.log("DSUStablecoin Proxy deployed to:", await proxy.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
