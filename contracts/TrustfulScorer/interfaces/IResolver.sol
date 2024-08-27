// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @notice The interface of the {Resolver} contract.
interface IResolver {
  /// @dev Returns the score of the grant program.
  /// Implementer should encode their data and handle it in the resolver.
  ///
  /// NOTE: Its recommended to multiply by the decimals in the Scorer.
  /// Solidity can't handle floating points, so you can get the decimals by
  /// calling {ITrustfulScorer.getScorerDecimals} and dividing the result.
  ///
  /// @param data An arbitrary data to handle fetching the score
  /// @return success If the operation succeeded.
  /// @return score The average score of the grant program.
  function scoreOf(bytes memory data) external view returns (bool success, uint256 score);
}
