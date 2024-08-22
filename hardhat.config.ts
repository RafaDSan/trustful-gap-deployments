import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.25",
  networks: {
    arbitrum: {
      url: `${process.env.RPC_ARBITRUM}`,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    arbitrum_sepolia: {
      url: `${process.env.RPC_ARBITRUM_SEPOLIA}`,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
  },
};

export default config;
