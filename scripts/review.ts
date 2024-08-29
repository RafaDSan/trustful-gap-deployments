import { ethers } from "hardhat";
import abi from "../abi/EAS.json";

async function main() {
  const [attester] = await ethers.getSigners();
  console.log("Writting a review with account:", attester.address);

  const EAS = await ethers.getContractAt(abi as any, process.env.ARB_ONE_EAS as string, attester);

  const grantId = "0x635c2d0642c81e3191e6eff8623ba601b7e22e832d7791712b6bc28d052ff2b5";
  const badgeIds = [
    "0xe02b7f93d209aa1a9708544eb17e46eee3a1f45fed0de720f4866e0caff148f8",
    "0x446d8276789167189130fb83fce2c7b401752249a46b7e001d517c972a680219",
    "0xb2cf2baa9cdf459fd115c1bac872e0c7318c71d1201da034ff34090bf5c9ead3",
    "0xe85f17539b1c37dce80ab28bd08ca41f0c3f04a997756426157561ccf3447efa",
    "0x8934465c22520a1367b2794d7c3448e531923564a89acf65fc1cb97d918eb9bd",
    "0xc7110d04cc11dd911b5c12d4a26449fd87d7b6bf92ffbe02d0cda65b161eacb9",
    "0x41fdc7e77ebf77189b683427e0c79506b9177b5ddad561f8e1d62b15f779dcfb",
  ];
  const badgeScores = [1, 2, 3, 4, 5, 4, 3];

  // Encode the data
  const encodedData = ethers.utils.defaultAbiCoder.encode(
    ["bytes32", "bytes32[]", "uint8[]"],
    [grantId, badgeIds, badgeScores],
  );

  const requestData = {
    recipient: attester.address,
    expirationTime: ethers.BigNumber.from("2").pow(64).sub(1),
    revocable: false,
    refUID: grantId,
    data: encodedData,
    value: 0,
  };

  const request = {
    schema: process.env.KARMA_EAS_SCHEMA_UID as string,
    data: requestData,
  };

  const uid = await EAS.callStatic.attest(request);
  const tx0 = await EAS.attest(request);
  await tx0.wait();
  console.log(`Review registered with attestion UID: ${uid} at tx: ${tx0.hash}`);
}

main();
