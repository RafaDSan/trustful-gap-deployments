// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @notice The interface of the {BadgeRegistry} contract.
interface IBadgeRegistry {
  /// @param badgeId The badge ID to check.
  /// @return True if the badge exists. False if it does not.
  function badgeExists(bytes32 badgeId) external view returns (bool);
}
