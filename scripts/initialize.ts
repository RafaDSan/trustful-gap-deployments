import { ethers } from "hardhat";
import abitrustful from "../artifacts/contracts/resolverTrustful/Resolver.sol/Resolver.json";
import abieas from "../artifacts/contracts/resolverEAS/Resolver.sol/Resolver.json";

// Remember to set all the environment variables in the .env file before
// running the script.
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Initializing contracts with the account:", deployer.address);

  // Must get the SCORER_ID created in the Trustful Scorer contract
  // and set in the Trustful Resolver contract.
  const TrustfulResolver = await ethers.getContractAt(
    abitrustful.abi as any,
    process.env?.RESOLVER_TRUSTFUL as string,
    deployer,
  );
  const tx0 = await TrustfulResolver.setScorerId(process.env.SCORER_ID as string);
  await tx0.wait();
  console.log("Scorer ID set in Trustful Resolver at tx:", tx0.hash);

  // We need to first have both resolvers deployed to link one another.
  // We've deployed the Trustful Resolver with the EAS Resolver address
  // as aconstructor argument, now we need to set the Trustful Resolver
  // address in the EAS Resolver.
  // The EAS calls the Trustful Resolver, but the Trustful Resolver can
  // only accept calls from the EAS, therefore the need for this link.
  const EASResolver = await ethers.getContractAt(
    abieas.abi as any,
    process.env.RESOLVER_EAS as string,
    deployer,
  );
  const tx1 = await EASResolver.setTrustfulResolver(process.env.RESOLVER_TRUSTFUL as string);
  await tx1.wait();
  console.log("Trustful Resolver set in EAS Resolver at tx:", tx0.hash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
