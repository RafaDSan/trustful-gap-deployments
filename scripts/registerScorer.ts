import { ethers } from "hardhat";
import abi from "../artifacts/contracts/TrustfulScorer/TrustfulScorer.sol/TrustfulScorer.json";

const badgeIds = [
  "0xe02b7f93d209aa1a9708544eb17e46eee3a1f45fed0de720f4866e0caff148f8",
  "0x446d8276789167189130fb83fce2c7b401752249a46b7e001d517c972a680219",
  "0xb2cf2baa9cdf459fd115c1bac872e0c7318c71d1201da034ff34090bf5c9ead3",
  "0xe85f17539b1c37dce80ab28bd08ca41f0c3f04a997756426157561ccf3447efa",
  "0x8934465c22520a1367b2794d7c3448e531923564a89acf65fc1cb97d918eb9bd",
  "0xc7110d04cc11dd911b5c12d4a26449fd87d7b6bf92ffbe02d0cda65b161eacb9",
  "0x41fdc7e77ebf77189b683427e0c79506b9177b5ddad561f8e1d62b15f779dcfb",
];
const badgeScores = [5, 5, 5, 5, 5, 5, 5];

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Registering Scorer with account:", deployer.address);

  const TrustfulScorer = await ethers.getContractAt(
    abi.abi as any,
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
  const tx0 = await TrustfulScorer.registerScorer(
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
