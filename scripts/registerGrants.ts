import { ethers } from "hardhat";
import abi from "../artifacts/contracts/registry/GrantRegistry.sol/GrantRegistry.json";

// See {IGrantRegistry-Grant}.
const grants = [
  {
    grantId: "0x635c2d0642c81e3191e6eff8623ba601b7e22e832d7791712b6bc28d052ff2b5",
    programId: 100,
    grantee: "0x67eE5d3A5374849aDB4D80713a5765F164375F03",
    chain: 42161,
    status: 0,
  },
  {
    grantId: "0x1dac0e2beeba6f3eec76117545f39f28e8ecc3d2c22731b6072b2d87e82fa35d",
    programId: 100,
    grantee: "0x67eE5d3A5374849aDB4D80713a5765F164375F03",
    chain: 42161,
    status: 1,
  },
  {
    grantId: "0xcdaa67fc005df1417c7f9a54eee0d62ec3b44d157eba707b3a0169d4cbca9bf3",
    programId: 100,
    grantee: "0x67eE5d3A5374849aDB4D80713a5765F164375F03",
    chain: 42161,
    status: 2,
  },
  {
    grantId: "0x8f11bdca983f72b840c4bbc4c2b96ebf4292872669619eac8bb24d88dedcef99",
    programId: 99,
    grantee: "0x67eE5d3A5374849aDB4D80713a5765F164375F03",
    chain: 42161,
    status: 1,
  },
];

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Registering Grants with:", deployer.address);

  const GrantRegistry = await ethers.getContractAt(
    abi.abi as any,
    process.env.GRANT_REGISTRY as string,
    deployer,
  );

  for (let i = 0; i < grants.length; i++) {
    try {
      const tx = await GrantRegistry.register(
        grants[i].grantId,
        grants[i].programId,
        grants[i].grantee,
        grants[i].chain,
        grants[i].status,
      );
      await tx.wait();
      console.log(`Grant ID ${grants[i].grantId} registered successfully at tx:`, tx.hash);
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
