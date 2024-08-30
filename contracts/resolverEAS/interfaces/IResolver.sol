// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { Attestation } from "../Common.sol";

/// @notice The interface of the {Resolver} contract.
interface IResolver {
  /// Emitted when non-EAS contract tries to attest.
  error AccessDenied();
  /// Emitted when the badge ID doesn't exist in the registry.
  error InvalidBadgeID();
  /// Emitted when trying to set contracts as address zero.
  error InvalidContractAddress();
  /// Emitted then the attestation was subnmitted with less than max uint64 expiration time.
  error InvalidExpirationTime();
  /// Emitted when the grantee is doesn't match the one in the grant registry.
  error InvalidGrantOwner();
  /// Emitted when the grant cannot be reviwed.
  error InvalidGrantReview();
  /// Emitted when the review score is not between 1 and 5.
  error InvalidScoreValue();
  /// Emitted when the refUID doesn't match the grant UID.
  error InvalidRefUID();
  /// Emitted when the attestation is revocable.
  error InvalidRevocability();

  /// Emitted when a new grant registry is set.
  event GrantRegistryUpdated(address indexed oldGrantRegistry, address indexed newGrantRegistry);
  /// Emitted when a new badge registry is set.
  event BadgeRegistryUpdated(address indexed oldBadgeRegistry, address indexed newBadgeRegistry);
  /// Emitted when a new trustful resolver is set.
  event TrustfulResolverUpdated(
    address indexed oldTrustfulResolver,
    address indexed newTrustfulResolver
  );

  /// @notice Checks if the resolver can be sent ETH.
  /// @return Whether the resolver supports ETH transfers.
  function isPayable() external pure returns (bool);

  /// @notice Processes an attestation and verifies whether it's valid.
  /// @param attestation The new attestation.
  /// @return Whether the attestation is valid.
  function attest(Attestation calldata attestation) external payable returns (bool);

  /// @notice Processes an attestation revocation and verifies if it can be revoked.
  /// @param attestation The existing attestation to be revoked.
  /// @return Whether the attestation can be revoked.
  function revoke(Attestation calldata attestation) external payable returns (bool);

  /// @notice Set a new address as the Grant Registry.
  function setGrantRegistry(address _grantRegistry) external;

  /// @notice Set a new address as the Badge Registry.
  function setBadgeRegistry(address _badgeRegistry) external;

  /// @notice Set a new address as the Trustful Resolver.
  function setTrustfulResolver(address _trustfulResolver) external;
}
