import { ethers } from "hardhat";
import abi from "../abi/BadgeRegistry.json";

async function main() {
  if (!process.env.REGISTRY_BADGE_ADDRESS) {
    throw new Error("REGISTRY_BADGE_ADDRESS is not set");
  }
  const [deployer] = await ethers.getSigners();
  console.log("Connected with: ", deployer.address);

  const BadgeRegistry = await ethers.getContractAt(
    abi as any,
    process.env.REGISTRY_BADGE_ADDRESS,
    deployer,
  );

  // TO DO: Change to correct names and descriptions
  const badges = [
    {
      name: "Example Badge",
      description: "This is an example badge",
      metadata: "https://example.com/badge-metadata",
      data: "0x",
    },
    {
      name: "Example Badge",
      description: "This is an example badge",
      metadata: "https://example.com/badge-metadata",
      data: "0x",
    },
    {
      name: "Example Badge",
      description: "This is an example badge",
      metadata: "https://example.com/badge-metadata",
      data: "0x",
    },
    {
      name: "Example Badge",
      description: "This is an example badge",
      metadata: "https://example.com/badge-metadata",
      data: "0x",
    },
    {
      name: "Example Badge",
      description: "This is an example badge",
      metadata: "https://example.com/badge-metadata",
      data: "0x",
    },
    {
      name: "Example Badge",
      description: "This is an example badge",
      metadata: "https://example.com/badge-metadata",
      data: "0x",
    },
    {
      name: "Example Badge",
      description: "This is an example badge",
      metadata: "https://example.com/badge-metadata",
      data: "0x",
    },
  ];

  for (let i = 0; i < badges.length; i++) {
    try {
      const tx = await BadgeRegistry.create(badges[i]);
      const receipt = await tx.wait();
      console.log(
        `Badge ${i + 1} created successfully. Transaction hash:`,
        receipt.transactionHash,
      );

      const badgeRegisteredEvent = receipt.events?.find(
        (event) => event.event === "BadgeRegistered",
      );
      if (badgeRegisteredEvent) {
        const badgeId = badgeRegisteredEvent.args?.badgeId;
        console.log(`Created Badge ${i + 1} ID:`, badgeId);
      }
    } catch (error) {
      console.error(`Error creating badge ${i + 1}:`, error);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
