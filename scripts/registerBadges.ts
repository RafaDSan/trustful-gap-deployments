import { ethers } from "hardhat";
import abi from "../artifacts/contracts/Registry/BadgeRegistry.sol/BadgeRegistry.json";

const badges = [
  {
    name: "Clear Goals",
    description:
      "Recognizes programs with well-defined goals. Every grant program has a goal, such as governance, impact, or education. Are these goals well explained so you can build a project aligned with them?",
    metadata: "ipfs://QmXnttoTAgdk4swUncezQiqUrrYj1pqzAA5s7JWASEsogb/",
    data: "0x",
  },
  {
    name: "Smooth Application",
    description:
      "Awards a seamless application process. Are they using a tech that facilitates the application process? Did they get back to you after the application, or was it just a poor form?",
    metadata: "ipfs://QmdU4So7LSBnyu5vV19rYYafgG8Nn2ifhAHppXdgGSzJtB/",
    data: "0x",
  },
  {
    name: "Fair Rounds",
    description:
      "Grant programs and funding rounds are conducted fairly, supporting a diverse range of projects, including new initiatives, while actively incorporating community feedback.",
    metadata: "ipfs://QmT2tth5pUu7va9gv6nuHgXiprHFYzEFeMC76151A8qJrK/",
    data: "0x",
  },
  {
    name: "Easy Tech",
    description:
      "Awards programs with easily implementable technology. How hard is the tech? Are the docs easy to use or find?",
    metadata: "ipfs://QmWVRDSdkENo9vWvaahHdhUqXnBxVNxy3hdTCLfJsHV6eS/",
    data: "0x",
  },
  {
    name: "Supportive Team",
    description:
      "Highlights programs with highly supportive teams. Whether technical or not, if you receive very helpful support after applying for a grant, issue this badge. – Post-Grant Support: Highlights strong post-grant support. How much do they help you after the application? Do they suggest related projects, possible connections, or interested people?",
    metadata: "ipfs://QmY7WqjXzWGVMPv1NRXdxFu6U4vScnzqM9AyKHg7yjxmvH/",
    data: "0x",
  },
  {
    name: "Great Reviewers",
    description:
      "Recognizes top-quality grant reviewers. They are impartial, select well-written projects, set clear goals, and explain the application process well.",
    metadata: "ipfs://QmbNWWN3jhqeadYjacsrKxA5PPVkJ8Cb2Kg3HHJhR88Gbs/",
    data: "0x",
  },
  {
    name: "Fast Disbursement",
    description:
      "Commends quick fund disbursement processes. Did they complete the payment as soon as you completed the milestones? If yes, issue this badge.",
    metadata: "ipfs://QmU4ro2t4kYNeHyUrSs4SDApqhFQJvGe3JfuWhrGPXobxd/",
    data: "0x",
  },
];

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Registering badges with the account:", deployer.address);

  const BadgeRegistry = await ethers.getContractAt(
    abi.abi as any,
    process.env?.BADGE_REGISTRY as string,
    deployer,
  );

  for (let i = 0; i < badges.length; i++) {
    try {
      const badgeId = await BadgeRegistry.callStatic.create(badges[i]);
      const tx0 = await BadgeRegistry.create(badges[i]);
      const receipt = await tx0.wait();
      console.log(
        `Badge ${badges[i].name} created at ID: ${badgeId} successfully. Transaction hash: ${receipt.transactionHash}`,
      );
    } catch (error) {
      console.error(`Error creating badge ${badges[i].name}:`, error);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
