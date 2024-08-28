// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @notice The interface of the {TrustfulScorer} contract.
interface ITrustfulScorer {
  /// Emitted when the account has no badges.
  error AccountHasNoBadges();
  /// Emitted when the badge is not registered.
  error BadgeNotRegistered();
  /// Emitted when the badge is already registered.
  error BadgeRegistered();
  /// Emitted for invalid badge ID.
  error InvalidBadgeId();
  /// Emitted when the length does not match criteria.
  error InvalidLength();
  /// Emitted when the manager is invalid.
  error InvalidManager();
  /// Emitted when the call to the resolver is fails.
  error InvalidResolverCall();
  /// Emitted when the scorer is not registered.
  error ScorerNotRegistered();

  /// Emitted when the scorer is registered.
  event ScorerRegistered(uint256 indexed scorerId, address manager, address resolver);
  /// Emitted when a badge is added to a scorer.
  event BadgeAddedToScorer(uint256 indexed scorerId, bytes32 badgeId, uint256 badgeScore);
  /// Emitted when a badge is removed from a scorer.
  event BadgeRemovedFromScorer(uint256 indexed scorerId, bytes32 badgeId);
  /// Emitted when a badge is added to an account.
  event BadgeAddedToAddr(address indexed account, uint256 indexed scorerId, bytes32 badgeId);
  /// Emmited when a badge is removed from an account.
  event BadgeRemovedFromAddr(address indexed account, uint256 indexed scorerId, bytes32 badgeId);
  /// Emitted when the manager changes to a new address.
  event ManagerUpdated(uint256 indexed scorerId, address oldManager, address newManager);
  /// Emitted when the resolver changes to a new address.
  event ResolverUpdated(uint256 indexed scorerId, address oldResolver, address newResolver);
  /// Emitted when the metadata of a scorer changes.
  event TokenURIUpdated(uint256 indexed scorerId, string metadata);

  /// @notice Registers a new scorer.
  ///
  /// Requirements:
  /// - The lenght of `badgeIds` and `badgeScores` must be the same.
  ///
  /// Emits a {ScorerRegistered} event.
  ///
  /// @param manager The address of the manager.
  /// @param resolver The address of the resolver.
  /// @param badgeIds The badge IDs.
  /// @param badgeScores The badge scores.
  /// @param scoresDecimals The number of decimals of the scores.
  /// @param metadata The metadata of the scorer.
  /// @return scorerId The unique identifier of the scorer.
  function registerScorer(
    address manager,
    address resolver,
    bytes32[] calldata badgeIds,
    uint256[] calldata badgeScores,
    uint8 scoresDecimals,
    string memory metadata
  ) external returns (uint256 scorerId);

  /// @notice Adds a badge to a scorer.
  /// Requirements:
  /// - Only the manager of the scorer can call this function.
  /// @param scorerId Unique identifier of the scorer.
  /// @param badgeId The badge ID.
  /// @param badgeScore The badge score.
  function addBadgeToScorer(uint256 scorerId, bytes32 badgeId, uint256 badgeScore) external;

  /// @notice Removes a badge from a scorer.
  /// Requirements:
  /// - Only the manager of the scorer can call this function.
  /// @param scorerId Unique identifier of the scorer.
  /// @param badgeId The badge ID.
  function removeBadgeFromScorer(uint256 scorerId, bytes32 badgeId) external;

  /// @notice Adds a badge to an account.
  /// Requirements:
  /// - Only the manager of the scorer can call this function.
  /// @param account The address of the account.
  /// @param scorerId Unique identifier of the scorer.
  function registerBadgeToAddr(address account, uint256 scorerId, bytes32 badgeId) external;

  /// @notice Removes a badge from an account.
  /// Requirements:
  /// - Only the manager of the scorer can call this function.
  /// @param account The address of the account.
  /// @param scorerId Unique identifier of the scorer.
  /// @param badgeId The badge ID.
  function removeBadgeFromAddr(address account, uint256 scorerId, bytes32 badgeId) external;

  /// @notice Set a new manager for a scorer.
  /// Requirements:
  /// - Only the manager of the scorer can call this function.
  /// @param scorerId Unique identifier of the scorer.
  /// @param newManager The address of the new manager.
  function setNewManager(uint256 scorerId, address newManager) external;

  /// @notice Set a new resolver for a scorer.
  /// Requirements:
  /// - Only the manager of the scorer can call this function.
  /// @param scorerId Unique identifier of the scorer.
  /// @param newResolver The address of the new manager.
  function setNewResolver(uint256 scorerId, address newResolver) external;

  /// @notice Set a new scorer metadata.
  /// Requirements:
  /// - Only the manager of the scorer can call this function.
  /// @param scorerId Unique identifier of the scorer.
  /// @param metadata The metadata of the scorer.
  function setTokenURI(uint256 scorerId, string memory metadata) external;

  /// @notice Returns true if the scorer exists.
  /// @param scorerId Unique identifier of the scorer.
  function scorerExists(uint256 scorerId) external view returns (bool);

  /// @notice Request a score to the resolver by providing arbitrary data.
  ///
  /// Requirements:
  /// - The scorer must exist.
  /// - The call to the resolver must succeed.
  ///
  /// @param scorerId Unique identifier of the scorer.
  /// @param score The score returned by the resolver.
  function getScoreOf(bytes memory data, uint256 scorerId) external view returns (uint256 score);

  /// @notice Gets the score of an account inside a scorer.
  ///
  /// Requirements:
  /// - The scorer must exist.
  ///
  /// @param account The address of the account.
  /// @param scorerId Unique identifier of the scorer.
  /// @return badgesIds All the badge IDs of an account inside a scorer.
  /// @return badgesScores All the scores given to each badge of an account inside a scorer.
  /// @return finalScore The final sum of all scores.
  /// @return averageScore The average of the scores.
  function getLegacyScoreOf(
    address account,
    uint256 scorerId
  )
    external
    view
    returns (
      bytes32[] memory badgesIds,
      uint256[] memory badgesScores,
      uint256 finalScore,
      uint256 averageScore
    );

  /// @notice Returns the badge IDs contained in a scorer.
  /// Requirements:
  /// - The scorer must exist.
  /// @param scorerId Unique identifier of the scorer.
  function getBadgesIds(uint256 scorerId) external view returns (bytes32[] memory);

  /// @param scorerId Unique identifier of the scorer.
  /// @return The scores of all badges in a scorer.
  function getBadgesScores(uint256 scorerId) external view returns (uint256[] memory);

  /// @notice The score of a given badge
  /// Requirements:
  /// - The scorer must exist.
  /// @param scorerId Unique identifier of the scorer.
  /// @param badgeId The badge ID.
  function getBadgeScore(uint256 scorerId, bytes32 badgeId) external view returns (uint256);

  /// @param scorerId The score ID of the scorer.
  /// @param badgeId The badge ID of the badge.
  /// @return True if the badge is registered in the scorer. False if it is not.
  function scorerContainsBadge(uint256 scorerId, bytes32 badgeId) external view returns (bool);

  /// @notice Returns an array of badges held by an account.
  /// Requirements:
  /// - The scorer must exist.
  /// @param account The address of the account.
  /// @param scorerId Unique identifier of the scorer.
  function getBadgesFromAddr(
    address account,
    uint256 scorerId
  ) external view returns (bytes32[] memory);

  /// @notice Returns the manager address of a given scorer.
  /// Requirements:
  /// - The scorer must exist.
  /// @param scorerId Unique identifier of the scorer.
  function getManagerAddress(uint256 scorerId) external view returns (address);

  /// @notice Returns the resolver address of a given scorer.
  /// Requirements:
  /// - The scorer must exist.
  /// @param scorerId Unique identifier of the scorer.
  function getResolverAddress(uint256 scorerId) external view returns (address);

  /// @notice Returns the metadata of a scorer.
  /// Requirements:
  /// - The scorer must exist.
  /// @param scorerId Unique identifier of the scorer.
  function tokenURI(uint256 scorerId) external view returns (string memory);

  /// @notice Gets the number of decimals of a given scorer.
  /// Requirements:
  /// - The scorer must exist.
  /// @param scorerId Unique identifier of the scorer.
  function getScorerDecimals(uint256 scorerId) external view returns (uint8);
}
