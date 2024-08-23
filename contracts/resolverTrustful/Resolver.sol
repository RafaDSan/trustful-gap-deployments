// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IResolver } from "./interfaces/IResolver.sol";
import { ITrustfulScorer } from "./interfaces/ITrustfulScorer.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Resolver
/// @author KarmaGap | 0xneves.eth
/// @notice This is the implementation of the Trustful Resolver contract.
/// This contract is used to resolve scores and badges from Trustful.
contract Resolver is IResolver, Ownable {
  /// Scorer contract address
  address public scorer;
  /// EAS Resolver contract address
  address public easResolver;

  /// Maps grant IDs to their stories
  /// @dev We don't expect this to grow too large
  mapping(bytes32 => GrantStory[]) private _stories;
  /// Maps grant program labels to their reviews
  mapping(string => GrantProgram) private _grantPrograms;

  /// @param _scorer Address of the Trustful Scorer contract.
  /// @param _easResolver Address of the EAS Resolver contract.
  constructor(address _scorer, address _easResolver) Ownable(msg.sender) {
    scorer = _scorer;
    easResolver = _easResolver;
  }

  /// @inheritdoc IResolver
  function createStory(
    uint256 scorerId,
    bytes32 grantUID,
    bytes32 txUID,
    bytes32[] calldata badges,
    uint8[] calldata scores,
    string memory grantProgramLabel
  ) external {
    if (msg.sender != easResolver) revert OnlyEASResolver();

    GrantProgram memory grantProgram = _grantPrograms[grantProgramLabel];
    uint256 averageScore = 0;

    unchecked {
      for (uint i = 0; i < scores.length; i++) {
        // checks if the badge exists within the scorer
        if (!ITrustfulScorer(scorer).scorerContainsBadge(scorerId, badges[i]))
          revert BadgeNotRegistered();
        // sum the scores
        averageScore += scores[i];
      }
      // fetch the decimals of the scorer to normalize the score
      // allowing fixed point arithmetic since Solidty doesn't support floats
      // @dev decimals should not be higher as much as uint256 to avoid overflow
      averageScore *= 10 ** ITrustfulScorer(scorer).getScorerDecimals(scorerId);
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
        grantProgram.averageScore =
          (grantProgram.averageScore * grantProgram.validReviewCount + averageScore) /
          (grantProgram.validReviewCount++);
      } else {
        // if the grant program has already been reviewed by this grant
        // we need to revert the last average score and calculate the new one
        uint256 lastReviewScore = _stories[grantUID][lastStoryIndex - 1].averageScore;
        uint256 lastAverageScore = getGrantProgramScore(grantProgramLabel);
        // A1 = (X * ( C + 1 ) - A2) / C
        uint256 lastLastAverageScore = ((lastAverageScore * grantProgram.validReviewCount) -
          lastReviewScore) / (grantProgram.validReviewCount - 1);
        // Recalculate the average score with the most recent review
        grantProgram.averageScore =
          (lastLastAverageScore * (grantProgram.validReviewCount - 1) + averageScore) /
          (grantProgram.validReviewCount);
      }
      grantProgram.reviewCount++;
    }

    // create the story and push to the map
    GrantStory memory story = GrantStory(block.timestamp, txUID, badges, scores, averageScore);
    _stories[grantUID].push(story);

    // update the grant program review count and average score
    _grantPrograms[grantProgramLabel] = grantProgram;

    emit StoryCreated(
      grantUID,
      txUID,
      grantProgramLabel,
      block.timestamp,
      averageScore,
      grantProgram.validReviewCount
    );
  }

  /// @inheritdoc IResolver
  function setScorer(address _scorer) external onlyOwner {
    scorer = _scorer;
  }

  /// @inheritdoc IResolver
  function setEasResolver(address _easResolver) external onlyOwner {
    easResolver = _easResolver;
  }

  /// @inheritdoc IResolver
  function scoreOf(bytes memory data) external view returns (bool success, uint256 score) {
    string memory grantProgramLabel = abi.decode(data, (string));
    return (true, getGrantProgramScore(grantProgramLabel));
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
  function getGrantProgramReviewCount(
    string memory grantProgramLabel
  ) external view returns (uint256) {
    return _grantPrograms[grantProgramLabel].validReviewCount;
  }

  /// @inheritdoc IResolver
  function getGrantProgramScore(string memory grantProgramLabel) public view returns (uint256) {
    GrantProgram memory grantProgram = _grantPrograms[grantProgramLabel];
    if (grantProgram.validReviewCount == 0) revert GrantProgramNonExistant();
    if (grantProgram.averageScore == 0) revert GrantProgramNotReviewed();
    return grantProgram.averageScore;
  }
}
