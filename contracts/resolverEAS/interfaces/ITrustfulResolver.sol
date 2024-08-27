//SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

/// @notice The interface of the {TrustfulResolver} contract.
interface ITrustfulResolver {
  /// @notice Creates a new story review for a grant program.
  ///
  /// Requirement:
  /// - The caller must be the EAS Resolver contract.
  /// - The badges must be registered in the Trustful Scorer.
  ///
  /// Emits a {StoryCreated} event.
  ///
  /// @param grantUID Unique identifier of the grant existing in the Grant Registry.
  /// @param txUID Unique identifier of the transaction on EAS that created the story.
  /// @param grantProgramUID The grant program UID.
  /// @param badges Array of badge IDs exiting in the Badge Registry.
  /// @param scores Array of scores for each badge.
  function createStory(
    bytes32 grantUID,
    bytes32 txUID,
    uint256 grantProgramUID,
    bytes32[] calldata badges,
    uint8[] calldata scores
  ) external returns (bool success);
}
