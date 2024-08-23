// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IBadgeRegistry } from "./interfaces/IBadgeRegistry.sol";

/// @title Badge Registry
/// @author KarmaGap | 0xneves.eth
contract BadgeRegistry is IBadgeRegistry {
  /// Map of badges registered in the registry
  mapping(bytes32 => Badge) public badges;

  /// @inheritdoc IBadgeRegistry
  function create(Badge calldata badge) public returns (bytes32) {
    bytes32 badgeId = generateId(badge);

    if (bytes(badge.name).length == 0) revert InvalidBadgeNameLength();
    if (bytes(badges[badgeId].name).length > 0) revert BadgeAlreadyRegistered();
    badges[badgeId] = badge;

    emit BadgeRegistered(badgeId, msg.sender, badge.name);
    return badgeId;
  }

  /// @inheritdoc IBadgeRegistry
  function getBadge(bytes32 badgeId) public view returns (Badge memory) {
    return badges[badgeId];
  }

  /// @inheritdoc IBadgeRegistry
  function badgeExists(bytes32 badgeId) public view returns (bool) {
    return bytes(badges[badgeId].name).length > 0;
  }

  /// @inheritdoc IBadgeRegistry
  function generateId(Badge calldata badge) public pure returns (bytes32) {
    return keccak256(abi.encode(badge));
  }
}
