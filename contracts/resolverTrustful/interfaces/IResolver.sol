// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IResolver {
  /// Emitted when the `msg.sender` is not the EAS Resolver contract.
  error OnlyEASResolver();

  /// Emitted when the badge is not registered in the scorer.
  error BadgeNotRegistered();

  /// Emitted when the program has no reviews.
  error GrantProgramNotReviewed();

  /// Emitted when the grant program does not exist.
  error GrantProgramNonExistant();

  /// Event emitted when a story review is created for the grant.
  event StoryCreated(
    bytes32 indexed grantUID,
    bytes32 indexed txUID,
    string indexed grantProgramLabel,
    uint256 timestamp,
    uint256 averageScore,
    uint256 reviewCount
  );

  /// Struct that represents a grant story that appears as a timeline.
  struct GrantStory {
    uint256 timestamp;
    bytes32 txUID;
    bytes32[] badgeIds;
    uint8[] badgeScores;
    uint256 averageScore;
  }

  /// Struct to track current state of the grant program.
  struct GrantProgram {
    uint256 reviewCount; // The total amount of reviews for the grant program.
    uint256 validReviewCount; // Only counts the last review by a GrantStory.
    uint256 averageScore; // The average score of the grant program.
  }

  /// @notice Creates a new story review for a grant program.
  ///
  /// Requirement:
  /// - The caller must be the EAS Resolver contract.
  /// - The badges must be registered in the Trustful Scorer.
  /// - The grant program must exist.
  ///
  /// Emits a {StoryCreated} event.
  ///
  /// @param grantUID Unique identifier of the grant existing in the Grant Registry.
  /// @param txUID Unique identifier of the transaction on EAS that created the story.
  /// @param scorerId Unique identifier of the scorer that registered the badges.
  /// @param badges Array of badge IDs exiting in the Badge Registry.
  /// @param scores Array of scores for each badge.
  /// @param grantProgramLabel Label of the grant program.
  function createStory(
    uint256 scorerId,
    bytes32 grantUID,
    bytes32 txUID,
    bytes32[] calldata badges,
    uint8[] calldata scores,
    string memory grantProgramLabel
  ) external;

  /// @notice Sets a new address for the Trustful Scorer.
  /// @param _scorer Address of the Trustful Scorer contract.
  function setScorer(address _scorer) external;

  /// @notice Sets a new address for the EAS Resolver.
  /// @param _easResolver Address of the EAS Resolver contract.
  function setEasResolver(address _easResolver) external;

  /// @param grantProgramLabel Label of the grant program.
  /// @return success If the operation succeeded.
  /// @return score The average score of the grant program.
  function scoreOf(
    bytes memory grantProgramLabel
  ) external view returns (bool success, uint256 score);

  /// @param grantUID Unique identifier of the grant.
  /// @return stories The timeline of stories for the grant.
  function getGrantStories(bytes32 grantUID) external view returns (GrantStory[] memory);

  /// @param grantUID Unique identifier of the grant.
  /// @param index Index of the story in the timeline.
  /// @return story The specific story data.
  function getGrantStorie(
    bytes32 grantUID,
    uint256 index
  ) external view returns (GrantStory memory);

  /// @param grantUID Unique identifier of the grant.
  /// @return length The length of the timeline.
  function getGrantStorieLength(bytes32 grantUID) external view returns (uint256);

  /// @param grantProgramLabel Label of the grant program.
  /// @return reviewCount The review count for the grant program.
  function getGrantProgramReviewCount(
    string memory grantProgramLabel
  ) external view returns (uint256);

  /// @notice Gets the average score of a grant program.
  /// Requirement:
  /// - The grant program must exist
  /// - The grant program must have at least one review.
  /// @param grantProgramLabel Label of the grant program.
  /// @return averageScore The average score of the grant program.
  function getGrantProgramScore(string memory grantProgramLabel) external view returns (uint256);
}
