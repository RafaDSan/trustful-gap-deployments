import { ethers } from "hardhat";

async function main() {
  const BadgeRegistry = await ethers.getContractFactory("BadgeRegistry");
  const GrantRegistry = await ethers.getContractFactory("GrantRegistry");

  const badgeRegistry = await BadgeRegistry.deploy();
  const grantRegistry = await GrantRegistry.deploy();

  console.log("badgeRegistry deployed to:", badgeRegistry.address);
  console.log("grantRegistry deployed to:", grantRegistry.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
