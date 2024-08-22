import { ethers } from "hardhat";
import abi from "../abi/SchemaRegistry.json";

async function main() {
  if (!process.env.SCHEMA_REGISTRY_ADDRESS) {
    throw new Error("SCHEMA_REGISTRY_ADDRESS must be set");
  }

  const [deployer] = await ethers.getSigners();
  console.log("Connected with: ", deployer.address);

  const SchemaRegistry = await ethers.getContractAt(
    abi.abi as any,
    process.env.SCHEMA_REGISTRY_ADDRESS,
    deployer
  );

  //Register the Badge Schema
  let schema = "bytes32[] badges,uint8[] score,bytes32 grantId,uint256 scoreId";
  let resolverAddress = process.env.RESOLVER_ADDRESS;
  let revocable = true;

  const uid = await SchemaRegistry.callStatic.register(
    schema,
    resolverAddress,
    revocable
  );
  const tx = await SchemaRegistry.register(schema, resolverAddress, revocable);
  await tx.wait();
  console.log("Badge Schema registered with UID: ", uid);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
