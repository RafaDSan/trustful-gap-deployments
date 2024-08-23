import { ethers } from "hardhat";
import abi from "../abi/SchemaRegistry.json";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Registering Schema with the account:", deployer.address);

  const SchemaRegistry = await ethers.getContractAt(
    abi as any,
    process.env?.ARB_ONE_SCHEMA_REGISTRY as string,
    deployer,
  );

  //Register the Badge Schema
  let schema = "bytes32 grantId,uint256 scoreId,bytes32[] badges,uint8[] score";
  let resolverAddress = process.env?.RESOLVER_EAS as string;
  let revocable = false;

  const uid = await SchemaRegistry.callStatic.register(schema, resolverAddress, revocable);
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
