// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @notice The interface of the {BadgeRegistry} contract.
interface IBadgeRegistry {
  /// Emitted when the badge is already registered.
  error BadgeAlreadyRegistered();
  /// Emitted when the badge name length is invalid.
  error InvalidBadgeNameLength();

  /// Emitted when the a new Badge is registered within the Registry.
  event BadgeRegistered(bytes32 indexed badgeId, address indexed issuer, string name);

  /// Badge Struct.
  struct Badge {
    string name;
    string description;
    string metadata;
    bytes data;
  }

  /// @notice Registers a badge in the registry.
  /// @param badge Badge data struct.
  /// @return badgeId The badge ID generated.
  function create(Badge calldata badge) external returns (bytes32);

  /// @param badgeId The badge ID to fetch.
  /// @return badge The badge data struct.
  function getBadge(bytes32 badgeId) external view returns (Badge memory);

  /// @param badgeId The badge ID to check.
  /// @return True if the badge exists. False if it does not.
  function badgeExists(bytes32 badgeId) external view returns (bool);

  /// @notice Generates a badge based on its content.
  /// @param badge Badge data struct.
  /// @return badgeId The badge ID generated.
  function generateId(Badge calldata badge) external pure returns (bytes32);
}
