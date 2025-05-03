import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "@nomicfoundation/hardhat-verify";
import {config as dotenvConfig} from "dotenv";

// Import these explicitly to ensure artifacts are properly generated
import "@nomicfoundation/hardhat-ethers";
import "@typechain/hardhat";

dotenvConfig();

const config: HardhatUserConfig = {
  networks: {
    mainnet: {
      url:"https://mainnet.infura.io/v3/eb89efb7e88e4ba1a49f66f5ca973b29",
      chainId: 1,
      accounts: [process.env.PRIVATE_KEY || ""] // Make sure to set your private key in an environment variable
    },
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      accounts: [process.env.PRIVATE_KEY || ""], // Make sure to set your private key in an environment variable
    },
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      accounts: [process.env.PRIVATE_KEY || ""], // Make sure to set your private key in an environment variable
    },
    polygon: {
      url: "https://polygon-mainnet.infura.io/v3/2adbe8148b3548d3b7297901033c59ce",
      chainId: 137,
      accounts: [process.env.PRIVATE_KEY || ""], // Make sure to set your private key in an environment variable
    },
    pulse: {
      url: "https://rpc.pulsechain.com",
      chainId: 369,
      accounts: [process.env.PRIVATE_KEY || ""], // Make sure to set your private key in an environment variable
    },
    sepolia: {
      url: "https://sepolia.drpc.org",
      chainId: 11155111,
      accounts: [process.env.PRIVATE_KEY || ""]
    },
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY_MAINNET || "",
      bsc: process.env.ETHERSCAN_API_KEY_BSC || "",
      sepolia: process.env.ETHERSCAN_API_KEY || ""
    },
    customChains: [
      {
        network: "bsc",
        chainId: 56,
        urls: {
          apiURL: "https://api.bscscan.com/api",
          browserURL: "https://bscscan.com",
        }
      }
    ]
  },
  solidity: {
    version: "0.8.27",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
};

export default config;
