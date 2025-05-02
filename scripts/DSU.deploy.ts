import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying DSU contract with the account:", deployer.address);

    const priceFeedAddress = "0x6D9C96fb3E5559aF7Cb5890cBff70215b1355B6a";
    const dsu = await ethers.deployContract("DSU", [priceFeedAddress]);
    await dsu.waitForDeployment();

    console.log("DSU contract deployed to:", await dsu.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

