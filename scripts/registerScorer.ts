import { ethers } from "hardhat";
import abi from "../artifacts/contracts/trustfulScorer/TrustfulScorer.sol/TrustfulScorer.json";

const badgeIds = ["0x0"];
const badgeScores = [5, 5, 5, 5, 5, 5, 5];

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Registering Scorer with:", deployer.address);

  const TrustfulScorer = await ethers.getContractAt(
    abi as any,
    process.env.TRUSTFUL_SCORER as string,
    deployer,
  );

  const scorerId = await TrustfulScorer.callStatic.registerScorer(
    deployer.address,
    process.env.RESOLVER_TRUSTFUL as string,
    badgeIds,
    badgeScores,
    18,
    "",
  );
  const tx0 = await TrustfulScorer.callStatic.registerScorer(
    deployer.address,
    process.env.RESOLVER_TRUSTFUL as string,
    badgeIds,
    badgeScores,
    18,
    "",
  );
  await tx0.wait();
  console.log(`Scorer registered at ID: ${scorerId} at tx: ${tx0.hash}`);
}

main();
