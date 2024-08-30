// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import { Attestation } from "./Common.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IResolver } from "./interfaces/IResolver.sol";
import { IBadgeRegistry } from "./interfaces/IBadgeRegistry.sol";
import { IGrantRegistry } from "./interfaces/IGrantRegistry.sol";
import { ITrustfulResolver } from "./interfaces/ITrustfulResolver.sol";

/// @author KarmaGap | 0xneves | RafaDSan
/// @notice KarmaGap Resolver contract for Ethereum Attestation Service.
contract Resolver is IResolver, Ownable {
  /// The global EAS contract.
  address public immutable eas;
  /// The global grant registry.
  IGrantRegistry public grantRegistry;
  /// The global badge registry.
  IBadgeRegistry public badgeRegistry;
  /// The Trustful Resolver contract.
  /// @dev Set this to address zero to stop the contract from working.
  /// NOTE: It's required to initialize this contract.
  ITrustfulResolver public trustfulResolver;

  /// @param _eas The address of the global EAS contract.
  /// @param _grantRegistry The address of the global grant registry.
  /// @param _badgeRegistry The address of the global badge registry.
  constructor(address _eas, address _grantRegistry, address _badgeRegistry) Ownable(msg.sender) {
    if (_eas == address(0)) revert InvalidContractAddress();
    eas = _eas;
    grantRegistry = IGrantRegistry(_grantRegistry);
    badgeRegistry = IBadgeRegistry(_badgeRegistry);
  }

  /// @dev Ensures that only the EAS contract can make this call.
  modifier onlyEAS() {
    if (msg.sender != eas) revert AccessDenied();
    _;
  }

  /// @inheritdoc IResolver
  function isPayable() public pure virtual returns (bool) {
    return false;
  }

  /// @inheritdoc IResolver
  function attest(Attestation calldata attestation) external payable onlyEAS returns (bool) {
    if (address(trustfulResolver) == address(0)) revert InvalidContractAddress();
    if (attestation.recipient != msg.sender) revert InvalidGrantOwner();
    if (attestation.expirationTime != 0) revert InvalidExpirationTime();
    if (attestation.revocable != false) revert InvalidRevocability();

    (bytes32 grantUID, bytes32[] memory badgeIds, uint8[] memory badgesScores) = abi.decode(
      attestation.data,
      (bytes32, bytes32[], uint8[])
    );

    if (attestation.refUID != grantUID) revert InvalidRefUID();

    // fetching each data separately because the grantRegistry might be upgraded someday
    // and this way we allow backwards compatibility
    address grantee = grantRegistry.getGranteeAddress(grantUID);
    uint256 grantProgramUID = grantRegistry.getGrantProgramUID(grantUID);
    IGrantRegistry.Status status = grantRegistry.getStatus(grantUID);

    // check if badges exists in the registry
    for (uint256 i = 0; i < badgeIds.length; i++) {
      if (!badgeRegistry.badgeExists(badgeIds[i])) {
        revert InvalidBadgeID();
      }
      // leverage the for loop to check for incorrect scores
      if (badgesScores[i] == 0 || badgesScores[i] > 5) {
        revert InvalidScoreValue();
      }
    }

    // check if grantee is the attester
    if (grantee != attestation.attester) {
      revert InvalidGrantOwner();
    }

    // rejected grants cannot be reviewed
    if (status == IGrantRegistry.Status.Rejected) {
      revert InvalidGrantReview();
    }

    // create a new review with a story
    bool success = trustfulResolver.createStory(
      grantUID,
      attestation.uid,
      grantProgramUID,
      badgeIds,
      badgesScores
    );

    if (success) return true;
    else return false;
  }

  /// @inheritdoc IResolver
  function revoke(Attestation calldata attestation) external payable onlyEAS returns (bool) {
    return false;
  }

  /// @inheritdoc IResolver
  function setGrantRegistry(address _grantRegistry) external onlyOwner {
    address oldGrantRegistry = address(grantRegistry);
    grantRegistry = IGrantRegistry(_grantRegistry);
    emit GrantRegistryUpdated(oldGrantRegistry, _grantRegistry);
  }

  /// @inheritdoc IResolver
  function setBadgeRegistry(address _badgeRegistry) external onlyOwner {
    address oldBadgeRegistry = address(badgeRegistry);
    badgeRegistry = IBadgeRegistry(_badgeRegistry);
    emit BadgeRegistryUpdated(oldBadgeRegistry, _badgeRegistry);
  }

  /// @inheritdoc IResolver
  function setTrustfulResolver(address _trustfulResolver) external onlyOwner {
    address oldTrustfulResolver = address(trustfulResolver);
    trustfulResolver = ITrustfulResolver(_trustfulResolver);
    emit TrustfulResolverUpdated(oldTrustfulResolver, _trustfulResolver);
  }
}
