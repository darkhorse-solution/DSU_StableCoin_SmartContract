import { ethers, upgrades } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  const NewImpl = await ethers.getContractFactory("DSUStablecoinUpgradeable");
  const proxyAddress = "0xbaa94bedc5d746aab20375e4e0d1a14a1f362953";
  const upgraded = await upgrades.upgradeProxy(proxyAddress, NewImpl);
  console.log("DSUStablecoin upgraded at:", await upgraded.getAddress());

  // Call reinitializer
  // const tx = await upgraded.reinitialize("0x6D9C96fb3E5559aF7Cb5890cBff70215b1355B6a", deployer.address, false, "0x2170Ed0880ac9A755fd29B2688956BD959F933F8");
  // await tx.wait();
  // console.log("Reinitialized with new price feed");
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
