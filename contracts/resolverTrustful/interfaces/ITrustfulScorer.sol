// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface ITrustfulScorer {
  /// @param scorerId The score ID of the scorer.
  /// @param badgeId The badge ID of the badge.
  /// @return True if the badge is registered in the scorer. False if it is not.
  function scorerContainsBadge(uint256 scorerId, bytes32 badgeId) external view returns (bool);

  /// @notice Gets the number of decimals of a given scorer.
  /// Requirements:
  /// - The scorer must exist.
  /// @param scorerId Unique identifier of the scorer.
  /// @return The number of decimals of the scorer.
  function getScorerDecimals(uint256 scorerId) external view returns (uint8);
}
