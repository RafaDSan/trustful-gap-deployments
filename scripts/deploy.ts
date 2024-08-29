import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const GrantRegistry = await ethers.getContractFactory("GrantRegistry", deployer);
  const BadgeRegistry = await ethers.getContractFactory("BadgeRegistry", deployer);
  const TrustfulScorer = await ethers.getContractFactory("TrustfulScorer", deployer);
  const ResolverEAS = await ethers.getContractFactory(
    "contracts/resolverEAS/Resolver.sol:Resolver",
    deployer,
  );
  const ResolverTrustful = await ethers.getContractFactory(
    "contracts/resolverTrustful/Resolver.sol:Resolver",
    deployer,
  );

  console.log("Deploying contracts...\n");

  const grantRegistry = await GrantRegistry.deploy();
  const badgeRegistry = await BadgeRegistry.deploy();
  const trustfulScorer = await TrustfulScorer.deploy();
  const resolverEAS = await ResolverEAS.deploy(
    process.env.ARB_ONE_EAS as string,
    grantRegistry.address,
    badgeRegistry.address,
  );
  const resolverTrustful = await ResolverTrustful.deploy(
    trustfulScorer.address,
    resolverEAS.address,
  );

  console.log("GRANT_REGISTRY deployed to:", grantRegistry.address);
  console.log("BADGE_REGISTRY deployed to:", badgeRegistry.address);
  console.log("TRUSTFUL_SCORER deployed to:", trustfulScorer.address);
  console.log("RESOLVER_EAS deployed to:", resolverEAS.address);
  console.log("RESOLVER_TRUSTFUL deployed to:", resolverTrustful.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
