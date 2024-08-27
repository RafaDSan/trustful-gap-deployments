import { ethers } from "hardhat";
import abi from "../../artifacts/contracts/registry/GrantRegistry.sol/GrantRegistry.json";

// See {IGrantRegistry-Grant}.
const grantIds = ["0x0000000000000000000000000000000000000000"];
const programIds = [105];
const statuses = [1];

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Registering Grants with:", deployer.address);

  const GrantRegistry = await ethers.getContractAt(
    abi as any,
    process.env.GRANT_REGISTRY as string,
    deployer,
  );

  try {
    const tx = await GrantRegistry.batchRegister(grantIds, programIds, statuses);
    await tx.wait();
    console.log(`Successfully created ${grantIds.length} Grants in batch at tx`, tx.hash);
  } catch (error) {
    console.error(`Error creating ${grantIds.length} Grants in batch`, error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
