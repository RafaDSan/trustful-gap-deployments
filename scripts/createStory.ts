import { ethers } from "hardhat";

async function main() {
  // Replace with the deployed contract address
  const resolverAddress = "0x";
  const Resolver = await ethers.getContractFactory("Resolver");
  const resolver = Resolver.attach(resolverAddress);

  const grantId = "0x";
  const badgeIds = ["0x", "0x", "0x", "0x", "0x", "0x", "0x"];

  const badgeScores = [1, 2, 3, 4, 5, 4, 3];

  // Replace with appropriate parameters
  const grantUID = grantId; // bytes32
  const txUID = "0x..."; // bytes32
  const grantProgramUID = 1; // uint256
  const badges = badgeIds; // bytes32[]
  const scores = badgeScores; // uint8[]

  const uid = await resolver.callStatic.createStory(
    grantUID,
    txUID,
    grantProgramUID,
    badges,
    scores,
  );
  const tx0 = await resolver.createStory(grantUID, txUID, grantProgramUID, badges, scores);
  await tx0.wait();

  console.log("Story created successfully:", tx0.hash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
