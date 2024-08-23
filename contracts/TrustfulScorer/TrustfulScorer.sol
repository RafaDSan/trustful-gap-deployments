// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IResolver } from "./interfaces/IResolver.sol";
import { ITrustfulScorer } from "./interfaces/ITrustfulScorer.sol";
import { EnumerableSetLib } from "./utils/EnumerableSetLib.sol";

/// @title Trustful Scorer
/// @author KarmaGap | 0xneves.eth
/// @notice Scorers are responsible for registering scores for a set of data.
/// This data can be anything that can be fetched on-chain. For this reason,
/// the scorer asks for the implementation of Resolver contracts to provide the
/// implementation that returns the necessary data to compute the final score.
/// This contract also have a legacy version in case the badges created follow
/// the {BadgeRegistry} standard.
contract TrustfulScorer is ITrustfulScorer {
  using EnumerableSetLib for EnumerableSetLib.Bytes32Set;

  /// Scorer structure
  struct Scorer {
    EnumerableSetLib.Bytes32Set badgeIds;
    mapping(bytes32 => uint256) badgeScores;
    mapping(address => EnumerableSetLib.Bytes32Set) badgeBalances;
    uint8 scoresDecimals;
    string metadata;
  }

  /// The next scorer ID. Keep track of scorers created.
  uint256 public nextScorerId;

  /// Map scorer ID to the scorer struct.
  mapping(uint256 => Scorer) private _scorers;
  /// Map scorer ID to the manager address of that scorer.
  mapping(uint256 => address) private _managers;
  /// Map scorer ID to the resolver address of that scorer.
  mapping(uint256 => address) private _resolvers;

  /// @dev Only allow manager address to perform actions.
  /// @param scorerId The scorer ID.
  modifier onlyManager(uint256 scorerId) {
    if (_managers[scorerId] != msg.sender) revert InvalidManager();
    _;
  }

  /// @inheritdoc ITrustfulScorer
  function registerScorer(
    address manager,
    address resolver,
    bytes32[] calldata badgeIds,
    uint256[] calldata badgeScores,
    uint8 scoresDecimals,
    string memory metadata
  ) external returns (uint256) {
    uint256 scorerId = nextScorerId;

    // assembly incrementation of scorer IDs
    assembly {
      sstore(nextScorerId.slot, add(sload(nextScorerId.slot), 1))
    }

    // check if the length of badgeIds and badgeScores are the same
    if (badgeIds.length != badgeScores.length) revert InvalidLength();
    // only stores resolver if different from zero address
    if (resolver != address(0)) _resolvers[scorerId] = resolver;
    // store manager address
    _managers[scorerId] = manager;

    // load the scorer storage at given scorer Id
    Scorer storage scorer = _scorers[scorerId];
    // set the scores decimals and metadata
    scorer.scoresDecimals = scoresDecimals;
    scorer.metadata = metadata;

    // iterate over the badgeIds and badgeScores to add them to the scorer
    for (uint256 i = 0; i < badgeIds.length; ) {
      scorer.badgeIds.add(badgeIds[i]);
      unchecked {
        scorer.badgeScores[badgeIds[i]] = badgeScores[i] * 10 ** scoresDecimals;
      }
      assembly {
        i := add(i, 1)
      }
    }

    emit ScorerRegistered(scorerId, manager, resolver);
    return nextScorerId;
  }

  /// @inheritdoc ITrustfulScorer
  function addBadgeToScorer(
    uint256 scorerId,
    bytes32 badgeId,
    uint256 badgeScore
  ) external onlyManager(scorerId) {
    Scorer storage scorer = _scorers[scorerId];
    if (scorer.badgeIds.contains(badgeId)) revert BadgeRegistered();

    scorer.badgeIds.add(badgeId);
    scorer.badgeScores[badgeId] = badgeScore * 10 ** scorer.scoresDecimals;

    emit BadgeAddedToScorer(scorerId, badgeId, badgeScore);
  }

  /// @inheritdoc ITrustfulScorer
  function removeBadgeFromScorer(uint256 scorerId, bytes32 badgeId) external onlyManager(scorerId) {
    Scorer storage scorer = _scorers[scorerId];
    if (!scorer.badgeIds.contains(badgeId)) revert BadgeNotRegistered();

    scorer.badgeIds.remove(badgeId);
    scorer.badgeScores[badgeId] = 0;

    emit BadgeRemovedFromScorer(scorerId, badgeId);
  }

  /// @inheritdoc ITrustfulScorer
  function registerBadgeToAddr(
    address account,
    uint256 scorerId,
    bytes32 badgeId
  ) external onlyManager(scorerId) {
    Scorer storage scorer = _scorers[scorerId];
    if (scorer.badgeBalances[account].contains(badgeId)) revert BadgeRegistered();
    scorer.badgeBalances[account].add(badgeId);
    emit BadgeAddedToAddr(account, scorerId, badgeId);
  }

  /// @inheritdoc ITrustfulScorer
  function removeBadgeFromAddr(
    address account,
    uint256 scorerId,
    bytes32 badgeId
  ) external onlyManager(scorerId) {
    Scorer storage scorer = _scorers[scorerId];
    if (!scorer.badgeBalances[account].contains(badgeId)) revert BadgeNotRegistered();
    scorer.badgeBalances[account].remove(badgeId);
    emit BadgeRemovedFromAddr(account, scorerId, badgeId);
  }

  /// @inheritdoc ITrustfulScorer
  function setNewManager(uint256 scorerId, address newManager) external onlyManager(scorerId) {
    address oldManager = _managers[scorerId];
    _managers[scorerId] = newManager;
    emit ManagerUpdated(scorerId, oldManager, newManager);
  }

  /// @inheritdoc ITrustfulScorer
  function setNewResolver(uint256 scorerId, address newResolver) external onlyManager(scorerId) {
    address oldResolver = _managers[scorerId];
    _managers[scorerId] = newResolver;
    emit ResolverUpdated(scorerId, oldResolver, newResolver);
  }

  /// @inheritdoc ITrustfulScorer
  function setTokenURI(uint256 scorerId, string memory metadata) external onlyManager(scorerId) {
    _scorers[scorerId].metadata = metadata;
    emit TokenURIUpdated(scorerId, metadata);
  }

  function _scorerExists(uint256 scorerId) internal view returns (bool) {
    Scorer storage scorer = _scorers[scorerId];
    if (scorer.badgeIds.length() == 0) return false;
    return true;
  }

  /// @inheritdoc ITrustfulScorer
  function getScoreOf(bytes memory data, uint256 scorerId) external view returns (uint256) {
    if (!_scorerExists(scorerId)) revert ScorerNotRegistered();

    // try to call the resolver contract
    IResolver resolver = IResolver(_resolvers[scorerId]);
    (bool success, uint256 score) = resolver.scoreOf(data);

    // if the call was not successful, revert
    if (!success) revert InvalidResolverCall();
    return score;
  }

  /// @inheritdoc ITrustfulScorer
  function getLegacyScoreOf(
    address account,
    uint256 scorerId
  )
    external
    view
    returns (bytes32[] memory, uint256[] memory, uint256 finalScore, uint256 averageScore)
  {
    // load the scorer storage at given scorer Id
    Scorer storage scorer = _scorers[scorerId];
    // check if the scorer exists
    if (scorer.badgeIds.length() == 0) revert ScorerNotRegistered();

    // load the account balances in that scorer
    EnumerableSetLib.Bytes32Set storage badges = scorer.badgeBalances[account];
    // cannot have zero badges
    if (badges.length() == 0) revert AccountHasNoBadges();

    bytes32[] memory badgeIds = new bytes32[](badges.length());
    uint256[] memory badgeScores = new uint256[](badges.length());
    uint256 j = 0;

    // iterate over the badges to get the final score
    for (uint256 i = 0; i < badges.length(); ) {
      bytes32 badgeId = badges.at(i);

      // checks if the scorer has the badge of the account
      if (scorer.badgeIds.contains(badgeId)) {
        finalScore += scorer.badgeScores[badgeId];
        badgeIds[j] = badgeId;
        badgeScores[j] = scorer.badgeScores[badgeId];
        assembly {
          j := add(j, 1)
        }
      }

      assembly {
        i := add(i, 1)
      }
    }

    // fixes the length of badgeIds and badgeScores
    assembly {
      mstore(badgeIds, j)
      mstore(badgeScores, j)
      // if the final score is greater than zero, calculate the average score
      if gt(j, 0) {
        averageScore := div(finalScore, j)
      }
    }

    return (badgeIds, badgeScores, finalScore, averageScore);
  }

  /// @inheritdoc ITrustfulScorer
  function getBadgesIds(uint256 scorerId) public view returns (bytes32[] memory) {
    if (!_scorerExists(scorerId)) revert ScorerNotRegistered();
    return _scorers[scorerId].badgeIds.values();
  }

  /// @inheritdoc ITrustfulScorer
  function getBadgesScores(uint256 scorerId) external view returns (uint256[] memory) {
    Scorer storage scorer = _scorers[scorerId];
    if (scorer.badgeIds.length() == 0) revert ScorerNotRegistered();

    bytes32[] memory badgeIds = getBadgesIds(scorerId);
    uint256[] memory badgeScores = new uint256[](badgeIds.length);

    for (uint256 i = 0; i < badgeIds.length; i++) {
      badgeScores[i] = scorer.badgeScores[badgeIds[i]];
    }

    return badgeScores;
  }

  /// @inheritdoc ITrustfulScorer
  function getBadgeScore(uint256 scorerId, bytes32 badgeId) external view returns (uint256) {
    if (!_scorerExists(scorerId)) revert ScorerNotRegistered();
    return _scorers[scorerId].badgeScores[badgeId];
  }

  /// @inheritdoc ITrustfulScorer
  function scorerContainsBadge(uint256 scorerId, bytes32 badgeId) external view returns (bool) {
    return _scorers[scorerId].badgeIds.contains(badgeId);
  }

  /// @inheritdoc ITrustfulScorer
  function getBadgesFromAddr(
    address account,
    uint256 scorerId
  ) external view returns (bytes32[] memory) {
    Scorer storage scorer = _scorers[scorerId];
    return scorer.badgeBalances[account].values();
  }

  /// @inheritdoc ITrustfulScorer
  function getManagerAddress(uint256 scorerId) external view returns (address) {
    return _managers[scorerId];
  }

  /// @inheritdoc ITrustfulScorer
  function getResolverAddress(uint256 scorerId) external view returns (address) {
    return _resolvers[scorerId];
  }

  /// @inheritdoc ITrustfulScorer
  function tokenURI(uint256 scorerId) external view returns (string memory) {
    return _scorers[scorerId].metadata;
  }

  /// @inheritdoc ITrustfulScorer
  function getScorerDecimals(uint256 scorerId) public view returns (uint8) {
    return _scorers[scorerId].scoresDecimals;
  }
}
