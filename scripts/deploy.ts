import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const BadgeRegistry = await ethers.getContractFactory("BadgeRegistry", deployer);
  const GrantRegistry = await ethers.getContractFactory("GrantRegistry", deployer);
  const TrustfulScorer = await ethers.getContractFactory("TrustfulScorer", deployer);
  const ResolverEAS = await ethers.getContractFactory("resolverTrustul/Resolver", deployer);
  const ResolverTrustful = await ethers.getContractFactory("resolverEAS/Resolver", deployer);

  console.log("Deploying contracts...\n");
  const badgeRegistry = await BadgeRegistry.deploy();
  const grantRegistry = await GrantRegistry.deploy();
  const trustfulScorer = await TrustfulScorer.deploy();
  const resolverEAS = await ResolverEAS.deploy(process.env?.ARB_ONE_EAS);
  const resolverTrustful = await ResolverTrustful.deploy(
    trustfulScorer.address,
    resolverEAS.address,
  );

  console.log("BadgeRegistry deployed to:", badgeRegistry.address);
  console.log("GrantRegistry deployed to:", grantRegistry.address);
  console.log("TrustfulScorer deployed to:", trustfulScorer.address);
  console.log("ResolverEAS deployed to:", resolverEAS.address);
  console.log("ResolverTrustful deployed to:", resolverTrustful.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
