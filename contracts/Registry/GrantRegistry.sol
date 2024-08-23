// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IGrantRegistry } from "./interfaces/IGrantRegistry.sol";

/// @title Grant Registry
/// @author KarmaGap | 0xneves.eth
/// @notice Registry of grant applications.
/// The Grant Programs can issue and manage grants.
contract GrantRegistry is IGrantRegistry {
  /// Map the grant ID to the grant data
  mapping(bytes32 => Grant) private _grants;
  /// Map the grant ID to its grant manager
  mapping(bytes32 => address) private _managers;

  /// @inheritdoc IGrantRegistry
  function register(Grant calldata grant, address manager) public returns (bytes32) {
    // generate the grant ID and verify if it already exists
    bytes32 grantUID = generateId(grant);
    if (_grants[grantUID].chain != 0) revert GrantAlreadyExists();

    // verify if the chain ID matches the current chain
    if (grant.chain != block.chainid) revert InvalidChain();

    // store the grant data and its manager address
    _managers[grantUID] = manager;
    _grants[grantUID] = grant;

    emit GrantRegistered(grantUID, grant.id, grant.grantee, grant.grantProgramLabel, manager);
    return grantUID;
  }

  /// @inheritdoc IGrantRegistry
  function update(bytes32 grantUID, Grant calldata grant) public {
    _verify(grantUID);
    _grants[grantUID] = grant;
    emit GrantUpdated(grantUID, grant.id, grant.grantProgramLabel, grant.status);
  }

  /// @inheritdoc IGrantRegistry
  function remove(bytes32 grantUID) public {
    _verify(grantUID);
    delete _grants[grantUID];
    emit GrantDeleted(grantUID);
  }

  /// @inheritdoc IGrantRegistry
  function transferOwnership(bytes32 grantUID, address newManager) public {
    _verify(grantUID);
    _managers[grantUID] = newManager;
    emit GrantManagerChanged(grantUID, msg.sender, newManager);
  }

  /// @notice Verify if the grant exists and that the sender is the grant manager
  function _verify(bytes32 _grantUID) internal view {
    // checks if the grant exists
    if (_grants[_grantUID].chain == 0) revert GrantNonExistent();
    // checks if the sender is the grant manager
    if (_managers[_grantUID] != msg.sender) revert InvalidGrantManager();
  }

  /// @inheritdoc IGrantRegistry
  function getGrant(bytes32 grantUID) public view returns (Grant memory) {
    // checks if the grant exists
    if (_grants[grantUID].chain == 0) revert GrantNonExistent();
    return _grants[grantUID];
  }

  /// @inheritdoc IGrantRegistry
  function getManager(bytes32 grantUID) public view returns (address) {
    return _managers[grantUID];
  }

  /// @inheritdoc IGrantRegistry
  function generateId(Grant calldata grant) public pure returns (bytes32) {
    return keccak256(abi.encode(grant));
  }
}
