# Karma Gap Grant Program Review Manager

This repository is a Hardhat project with the intuit of being simple and straight forward.

## Overview

The Karma GAP, or Grantee Accountability Protocol, is a system designed to enhance transparency and
accountability in grant funding processes, particularly in decentralized ecosystems. It aims to
ensure that grantees—those who receive funding—are held accountable for how they use the funds, and
that the outcomes of funded projects align with the objectives set out in their proposals.

## Getting Started

Start by getting dependencies latest versions:

```sh
$ yarn
```

Then make a copy of `.env.example` and rename it to `.env`. Fill in the required environment
variables.

### Compile

Compile the contracts:

```sh
$ yarn compile
```

### 1. Deployments

Have in mind that the initialization sequence must be followed in order. And that the contract has
security measures to avoid working while not configured correctly. All important variables to run
the workflow are mutable and can be changed by the contract owner.

Run the deployment script:

```sh
$ yarn deploy --network arbitrum
```

Add the contract addresses to the `.env` file then verify them on Arbiscan.

```sh
$ npx hardhat verify --network arbitrum <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>
```

### 2. Register the grants

You must first fill the `registerGrants.ts` file with the grants you want to register. The grants
use the following interface:

```solidity
  struct Grant {
    bytes32 grantUID; // The grant UID defined in EAS
    uint256 grantProgramUID; // The grant program UID defined by Karma Gap
    address grantee; // Address of the person in charge of delivering the grant
    uint256 chainId; // The chain ID where the grant was originated
    Status status; // Current status of the grant
  }
```

Register the grants in the `GrantRegistry.sol`:

```sh
$ yarn grants --network arbitrum
```

### 3. Register the badges

You must first fill the `registerBadges.ts` file with the grants you want to register. The grants
use the following interface:

```solidity
  struct Badge {
    string name; // The badge name or title
    string description; // The description of the badge
    string metadata; // A metadata to point external links or json format with the entire badge data
    bytes data; // Arbitrary data to be used by implementers
  }
```

Register the badges in the `BadgeRegistry.sol`:

```sh
$ yarn badges --network arbitrum
```

Grab the Badges from the logs and save them into the `registerScorer.ts` file. We will need them to
create the Scorer.

### 4. Create a Scorer

The scorer is a collective of badges that carry a score for each badge. We also have a `resolver`
field to handle arbitrary data. Which is the case for Karma Gap Reviews, as we don't know which
exact score the reviewer will give.

```sh
$ yarn scorer --network arbitrum
```

Save the resulting Scorer ID into the `.env` file.

### 2. Create Schemas on EAS

Create the schemas on the EAS contract:

```sh
$ yarn schemas --network arbitrum
```

Save the resulting schema UID into the `.env` file.

### 6. Initialize the contracts

Contracts should only work when a few items are initialized. The requirements are:

- The `Grant Registry` contract must have at least one grant registered.
- The `Badge Registry` contract must have at least one badge registered.
- The `EAS Resolver` must have the schema registered.
- The `Trustful Scorer` must have at least one Scorer registered.
- The `Trustful Resolver` must have the `scorerId` (uint256) set.
- The `EAS Resolver` must have the `TrustfulResolver.sol` contract set.

This script will:

- Set the scorerId on the `Trustful Resolver`.
- Set the `Trustful Resolver` contract in the `EAS Resolver`.

```sh
yarn initialize --network arbitrum
```

### 7. Create a Review

This is a sample script of how the front-end should Attest on EAS to create a review on-chain.

```sh
yarn review --network arbitrum
```

## License

This project is licensed under MIT.

```

```
