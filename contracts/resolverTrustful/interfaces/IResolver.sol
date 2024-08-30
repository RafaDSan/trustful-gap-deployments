// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @notice The interface of the {Resolver} contract.
interface IResolver {
  /// Emitted when the badge is not registered in the scorer.
  error BadgeNotRegistered();
  /// Emitted when the program has no reviews.
  error GrantProgramNotReviewed();
  /// Emitted when the badge and score arrays have different lengths.
  error InvalidBadgeScoreLength();
  /// Emitted when the `msg.sender` is not the EAS Resolver contract.
  error OnlyEASResolver();
  /// Emitted when the scorer is not initialized.
  error ScorerNotInitialized();
  /// Emitted when the resolver is not registered in the scorer.
  error ResolverNotRegistered();
  /// Emitted when there is an attemp to divide by zero.
  error DivisionByZero();

  /// Emitted when a new Scorer address is set.
  event ScorerUpdated(address indexed oldScorer, address indexed newScorer);
  /// Emitted when a new Scorer ID is set.
  event ScorerIdUpdated(uint256 indexed oldScorerId, uint256 indexed newScorerId);
  /// Emitted when a new EAS Resolver address is set.
  event EASResolverUpdated(address indexed oldResolver, address indexed newResolver);
  /// Event emitted when a story review is created for the grant.
  event StoryCreated(
    bytes32 indexed grantUID,
    bytes32 indexed txUID,
    uint256 indexed grantProgramUID,
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

  /// @notice Sets a new address as the Trustful Scorer.
  /// NOTE: Will set the scorerId to zero. You must set it again.
  /// @param newScorerAddr Address of the Trustful Scorer contract.
  function setScorerAddress(address newScorerAddr) external;

  /// @notice Sets a new scorer ID.
  /// @param _scorerId Unique identifier of the scorer.
  function setScorerId(uint256 _scorerId) external;

  /// @notice Sets a new address as the EAS Resolver.
  /// @param newEasResolverAddr Address of the EAS Resolver contract.
  function setEASResolverAddress(address newEasResolverAddr) external;

  /// @dev This implementation is required by {TrustfulScorer}.
  /// @param grantProgramUID Abi Encoded grant program UID.
  /// @return success If the operation succeeded.
  /// @return score The average score of the grant program.
  function scoreOf(
    bytes memory grantProgramUID
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

  /// @param grantProgramUID The ID of the progam.
  /// @return validReviewCount The review count for the grant program.
  function getGrantProgramValidReviewCount(uint256 grantProgramUID) external view returns (uint256);

  /// @param grantProgramUID The ID of the progam.
  /// @return reviewCount The review count for the grant program.
  function getGrantProgramTotalReviewCount(uint256 grantProgramUID) external view returns (uint256);

  /// @notice Gets the average score of a grant program.
  ///
  /// Requirement:
  /// - The grant program must exist
  /// - The grant program must have at least one review.
  ///
  /// NOTE: The result is multiplied by the decimals in the Scorer.
  /// Solidity can't handle floating points, so you can get the decimals by
  /// calling {ITrustfulScorer.getScorerDecimals} and dividing the result.
  ///
  /// @param grantProgramUID The ID of the progam.
  /// @return averageScore The average score of the grant program.
  function getGrantProgramAverageScore(uint256 grantProgramUID) external view returns (uint256);
}
