import { ethers } from "hardhat";
import abi from "../abi/GrantRegistry.json";

enum Status {
  Proposed,
  InProgress,
  Completed,
  Cancelled,
  Rejected,
}

async function main() {
  if (!process.env.REGISTRY_GRANT_ADDRESS) {
    throw new Error("REGISTRY_GRANT_ADDRESS is not set");
  }
  const [deployer] = await ethers.getSigners();
  console.log("Connected with: ", deployer.address);
  const GrantRegistry = await ethers.getContractAt(
    abi as any,
    process.env.REGISTRY_GRANT_ADDRESS,
    deployer,
  );

  const grants = [
    {
      chain: 1399811149,
      grantee: "0x0000000000000000000000000000000000000000",
      grantProgramLabel: "01 Exchange",
      project: "01 Exchange Grants Program",
      externalLinks: [
        "https://01.xyz/",
        "https://discord.com/invite/01exchange",
        "https://x.com/01_exchange?lang=en",
        "https://01exchange.notion.site/01-Exchange-Grants-Program-ecbab6fde93843caa6924fb5cda3b79e",
      ],
      startDate: Math.floor(Date.now() / 1000),
      endDate: Math.floor(Date.now() / 1000) + 31536000,
      status: Status.InProgress,
      disbursements: {
        fundingTokens: ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"], // Using USDC on Ethereum as an example
        fundingAmounts: [ethers.utils.parseUnits("100000", 6)],
        disbursed: [false],
      },
    },
    {
      chain: 1,
      grantee: "0x0000000000000000000000000000000000000000",
      grantProgramLabel: "0x Protocol",
      project: "0x Protocol Grant Program",
      externalLinks: [
        "https://0xdao.gitbook.io/0x-dao/ecosystem-value-experiment/0xdao-grant-program-framework-v1-1",
        "https://discord.com/invite/01exchange",
        "https://x.com/zeroexprotocol",
        "https://discord.com/invite/official0x",
        "https://gov.0x.org/",
        "https://0x.org/content-hub",
        "https://www.oxdao.fi/",
      ],
      startDate: Math.floor(Date.now() / 1000),
      endDate: Math.floor(Date.now() / 1000) + 31536000,
      status: Status.InProgress,
      disbursements: {
        fundingTokens: ["0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"], // USDC address on Ethereum
        fundingAmounts: [ethers.utils.parseUnits("150000", 6)],
        disbursed: [false],
      },
    },
  ];

  for (let i = 0; i < grants.length; i++) {
    try {
      const tx = await GrantRegistry.register(grants[i], deployer.address);
      const receipt = await tx.wait();
      console.log(
        `Grant ${i + 1} registered successfully. Transaction hash:`,
        receipt.transactionHash,
      );
      const grantRegisteredEvent = receipt.events?.find(
        (event) => event.event === "GrantRegistered",
      );
      if (grantRegisteredEvent) {
        const grantId = grantRegisteredEvent.args?.grantId;
        console.log(`Created Grant ${i + 1} ID:`, grantId);
      }
    } catch (error) {
      console.error(`Error registering grant ${i + 1}:`, error);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
