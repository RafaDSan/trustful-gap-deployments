// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import { IEAS, Attestation } from "../interfaces/IEAS.sol";
import { IResolver } from "../interfaces/IResolver.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { AccessDenied, InvalidEAS, InvalidLength, uncheckedInc, EMPTY_UID, NO_EXPIRATION_TIME } from "../Common.sol";

error InvalidExpiration();
error InvalidAttestationData();

/// @author Blockful | 0xneves
/// @notice KarmaGap Resolver contract for Ethereum Attestation Service.
contract Resolver is IResolver, AccessControl {
  // The global EAS contract.
  IEAS internal immutable _eas;

  /// @dev Creates a new resolver.
  /// @param eas The address of the global EAS contract.
  constructor(IEAS eas) {
    if (address(eas) == address(0)) revert InvalidEAS();
    _eas = eas;
  }

  /// @dev Ensures that only the EAS contract can make this call.
  modifier onlyEAS() {
    if (msg.sender != address(_eas)) revert AccessDenied();
    _;
  }

  /// @inheritdoc IResolver
  function isPayable() public pure virtual returns (bool) {
    return false;
  }

  /// @inheritdoc IResolver
  function attest(Attestation calldata attestation) external payable onlyEAS returns (bool) {
    return true;
  }

  /// @inheritdoc IResolver
  function revoke(Attestation calldata attestation) external payable onlyEAS returns (bool) {
    return true;
  }
}
