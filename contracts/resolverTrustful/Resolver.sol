// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IResolver } from "./interfaces/IResolver.sol";
import { ITrustfulScorer } from "./interfaces/ITrustfulScorer.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Resolver
/// @author KarmaGap | 0xneves.eth
/// @notice This is the implementation of the Trustful Resolver contract.
/// This contract is used to resolve scores and badges for Karma Gap Reviews.
contract Resolver is IResolver, Ownable {
  /// Trustful Scorer contract address
  address public trustfulScorer;
  /// EAS Resolver contract address
  address public easResolver;

  /// The scorer ID registered in the Trustful Scorer contract.
  /// It must be initialized before start creating stories.
  /// @dev Create a scorer in TrustfulScorer, then set the ID here.
  /// NOTICE: To pause this contract, set this to zero.
  uint256 public scorerId;

  /// Maps grant IDs to their stories
  /// @dev We don't expect this to grow too large
  mapping(bytes32 => GrantStory[]) private _stories;
  /// Maps grant program IDs to their reviews
  mapping(uint256 => GrantProgram) private _grantPrograms;

  /// @param _scorerAddr Address of the Trustful Scorer contract.
  /// @param _easResolverAddr Address of the EAS Resolver contract.
  constructor(address _scorerAddr, address _easResolverAddr) Ownable(msg.sender) {
    trustfulScorer = _scorerAddr;
    easResolver = _easResolverAddr;
  }

  /// @inheritdoc IResolver
  function createStory(
    bytes32 grantUID,
    bytes32 txUID,
    uint256 grantProgramUID,
    bytes32[] calldata badges,
    uint8[] calldata scores
  ) external returns (bool) {
    if (msg.sender != easResolver) revert OnlyEASResolver();
    if (badges.length != scores.length) revert InvalidBadgeScoreLength();
    if (scorerId == 0) revert ScorerNotInitialized();
    // must check if the resolver is registered all the times because its
    // possible that the Scorer was updated to a different resolver
    if (ITrustfulScorer(trustfulScorer).getResolverAddress(scorerId) != address(this))
      revert ResolverNotRegistered();

    GrantProgram memory grantProgram = _grantPrograms[grantProgramUID];
    uint256 averageScore = 0;

    unchecked {
      for (uint i = 0; i < scores.length; i++) {
        // checks if the badge exists within the scorer
        if (!ITrustfulScorer(trustfulScorer).scorerContainsBadge(scorerId, badges[i]))
          revert BadgeNotRegistered();
        // sum the scores
        averageScore += scores[i];
      }
      // fetch the decimals of the scorer to normalize the score
      // allowing fixed point arithmetic since Solidty doesn't support floats
      // @dev decimals should not be higher as much as uint256 to avoid overflow
      averageScore *= 10 ** ITrustfulScorer(trustfulScorer).getScorerDecimals(scorerId);
      // calculate the average score by dividing the sum by the number of scores
      averageScore /= scores.length;

      // calculate the average score of the grant program
      uint256 lastStoryIndex = getGrantStorieLength(grantUID);
      // if the grant program has no reviews yet
      if (grantProgram.validReviewCount == 0) {
        grantProgram.averageScore = averageScore;
        grantProgram.validReviewCount++;
      } else if (lastStoryIndex == 0) {
        // if the grant program is already reviewed by another grant
        // but this is the first story of this grant
        // X = (A1 * C + A2) / C + 1
        uint256 incValidReviewCount = grantProgram.validReviewCount + 1;
        grantProgram.averageScore = ceilDiv(
          (grantProgram.averageScore * grantProgram.validReviewCount + averageScore),
          incValidReviewCount
        );
        grantProgram.validReviewCount++;
      } else if (grantProgram.validReviewCount == 1) {
        // if the grant program has only one review we need to overwrite it
        grantProgram.averageScore = averageScore;
      } else {
        // if the grant program has already been reviewed by this grant
        // we need to revert the last average score and calculate the new one
        uint256 lastReviewScore = _stories[grantUID][lastStoryIndex - 1].averageScore;
        uint256 lastAverageScore = getGrantProgramAverageScore(grantProgramUID);
        // A1 = ((X * C ) - A2) / (C - 1)
        uint256 lastLastAverageScore = ceilDiv(
          (lastAverageScore * grantProgram.validReviewCount) - lastReviewScore,
          grantProgram.validReviewCount - 1
        );
        // Recalculate the average score with the most recent review
        grantProgram.averageScore = ceilDiv(
          lastLastAverageScore * (grantProgram.validReviewCount - 1) + averageScore,
          grantProgram.validReviewCount
        );
      }
      grantProgram.reviewCount++;
    }

    // create the story and push to the map
    GrantStory memory story = GrantStory(block.timestamp, txUID, badges, scores, averageScore);
    _stories[grantUID].push(story);

    // update the grant program review count and average score
    _grantPrograms[grantProgramUID] = grantProgram;

    emit StoryCreated(
      grantUID,
      txUID,
      grantProgramUID,
      block.timestamp,
      averageScore,
      grantProgram.validReviewCount
    );

    return true;
  }

  /// @dev Cast a boolean (false or true) to a uint256 (0 or 1) with no jump.
  function toUint(bool b) internal pure returns (uint256 u) {
    assembly ("memory-safe") {
      u := iszero(iszero(b))
    }
  }

  /// @dev Returns the ceiling of the division of two numbers.
  /// This differs from standard division with `/` in that it rounds towards infinity instead
  /// of rounding towards zero.
  function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    if (b == 0) {
      // Guarantee the same behavior as in a regular Solidity division.
      revert DivisionByZero();
    }

    // The following calculation ensures accurate ceiling division without overflow.
    // Since a is non-zero, (a - 1) / b will not overflow.
    // The largest possible result occurs when (a - 1) / b is type(uint256).max,
    // but the largest value we can obtain is type(uint256).max - 1, which happens
    // when a = type(uint256).max and b = 1.
    unchecked {
      return toUint(a > 0) * ((a - 1) / b + 1);
    }
  }

  /// @inheritdoc IResolver
  function setScorerAddress(address newScorerAddr) external onlyOwner {
    address oldScorerAddr = trustfulScorer;
    trustfulScorer = newScorerAddr;
    scorerId = 0;
    emit ScorerUpdated(oldScorerAddr, newScorerAddr);
  }

  /// @inheritdoc IResolver
  function setScorerId(uint256 _scorerId) external onlyOwner {
    uint256 oldScorerId = scorerId;
    scorerId = _scorerId;
    emit ScorerIdUpdated(oldScorerId, _scorerId);
  }

  /// @inheritdoc IResolver
  function setEASResolverAddress(address newEasResolverAddr) external onlyOwner {
    address oldResolverAddr = easResolver;
    easResolver = newEasResolverAddr;
    emit EASResolverUpdated(oldResolverAddr, newEasResolverAddr);
  }

  /// @inheritdoc IResolver
  function scoreOf(bytes memory data) external view returns (bool success, uint256 score) {
    uint256 grantProgramUID = abi.decode(data, (uint256));
    return (true, getGrantProgramAverageScore(grantProgramUID));
  }

  /// @inheritdoc IResolver
  function getGrantStories(bytes32 grantUID) external view returns (GrantStory[] memory) {
    return _stories[grantUID];
  }

  /// @inheritdoc IResolver
  function getGrantStorie(
    bytes32 grantUID,
    uint256 index
  ) external view returns (GrantStory memory) {
    return _stories[grantUID][index];
  }

  /// @inheritdoc IResolver
  function getGrantStorieLength(bytes32 grantUID) public view returns (uint256) {
    return _stories[grantUID].length;
  }

  /// @inheritdoc IResolver
  function getGrantProgramValidReviewCount(
    uint256 grantProgramUID
  ) external view returns (uint256) {
    return _grantPrograms[grantProgramUID].validReviewCount;
  }

  /// @inheritdoc IResolver
  function getGrantProgramTotalReviewCount(
    uint256 grantProgramUID
  ) external view returns (uint256) {
    return _grantPrograms[grantProgramUID].reviewCount;
  }

  /// @inheritdoc IResolver
  function getGrantProgramAverageScore(uint256 grantProgramUID) public view returns (uint256) {
    GrantProgram memory grantProgram = _grantPrograms[grantProgramUID];
    if (grantProgram.validReviewCount == 0) revert GrantProgramNotReviewed();
    return grantProgram.averageScore;
  }
}
