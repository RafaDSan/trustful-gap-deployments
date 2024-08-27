import { ethers } from "hardhat";
import abi from "../artifacts/contracts/registry/GrantRegistry.sol/GrantRegistry.json";

// See {IGrantRegistry-Grant}.
const grants = [
  {
    grantId: "0x7681b353ede51eadfbf7165c592a8449808ef4f37999cd9c819cb29dc923ad1a",
    programId: 260,
    status: 1,
  },
  {
    grantId: "0x35e2d5b3bb6fe9ecbcd3e4656520a4de6f0e7ea525ddd19f27af0ed66a83a6f1",
    programId: 260,
    status: 1,
  },
];

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Registering Grants with:", deployer.address);

  const GrantRegistry = await ethers.getContractAt(
    abi as any,
    process.env.GRANT_REGISTRY as string,
    deployer,
  );

  for (let i = 0; i < grants.length; i++) {
    try {
      const tx = await GrantRegistry.register(
        grants[i].grantId,
        grants[i].programId,
        grants[i].status,
      );
      await tx.wait();
      console.log(`Grant ID ${grants[i].programId} registered successfully at tx:`, tx.hash);
    } catch (error) {
      console.error(`Error creating Grant with ID: ${grants[i].programId}`, error);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
