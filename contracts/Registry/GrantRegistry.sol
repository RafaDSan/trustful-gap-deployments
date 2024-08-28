// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IGrantRegistry } from "./interfaces/IGrantRegistry.sol";

/// @title Grant Registry
/// @author KarmaGap | 0xneves.eth
/// @notice Registry of grant applications.
/// The Grant Programs can issue and manage grants.
contract GrantRegistry is IGrantRegistry, Ownable {
  /// Map the grant UID to the grant data
  mapping(bytes32 => Grant) private _grants;

  constructor() Ownable(msg.sender) {}

  /// @inheritdoc IGrantRegistry
  function batchRegister(Grant[] memory grants) external onlyOwner {
    for (uint256 i = 0; i < grants.length; i++) {
      register(
        grants[i].grantUID,
        grants[i].grantProgramUID,
        grants[i].grantee,
        grants[i].chainId,
        grants[i].status
      );
    }
  }

  /// @inheritdoc IGrantRegistry
  function register(
    bytes32 grantUID,
    uint256 grantProgramUID,
    address grantee,
    uint256 chainId,
    Status status
  ) public onlyOwner {
    if (_grants[grantUID].grantee != address(0)) revert GrantAlreadyExists();
    if (grantee == address(0)) revert InvalidGrantOwner();

    _grants[grantUID] = Grant(grantUID, grantProgramUID, grantee, chainId, Status(status));

    emit GrantRegistered(grantUID, grantProgramUID, grantee, uint256(status));
  }

  /// @inheritdoc IGrantRegistry
  function update(bytes32 grantUID, uint256 status) external onlyOwner {
    _grantExists(grantUID);
    _grants[grantUID].status = Status(status);
    emit GrantUpdated(grantUID, status);
  }

  /// @inheritdoc IGrantRegistry
  function remove(bytes32 grantUID) external onlyOwner {
    _grantExists(grantUID);
    delete _grants[grantUID];
    emit GrantDeleted(grantUID);
  }

  /// @dev Checks if the grant exists.
  function _grantExists(bytes32 grantUID) internal view {
    if (_grants[grantUID].grantee == address(0)) revert GrantNonExistent();
  }

  /// @inheritdoc IGrantRegistry
  function getGrantee(bytes32 grantUID) public view returns (address) {
    _grantExists(grantUID);
    return _grants[grantUID].grantee;
  }

  /// @inheritdoc IGrantRegistry
  function getGrantProgramUID(bytes32 grantUID) public view returns (uint256) {
    _grantExists(grantUID);
    return _grants[grantUID].grantProgramUID;
  }

  /// @inheritdoc IGrantRegistry
  function getStatus(bytes32 grantUID) public view returns (Status) {
    _grantExists(grantUID);
    return _grants[grantUID].status;
  }

  /// @inheritdoc IGrantRegistry
  function getGrant(bytes32 grantUID) public view returns (Grant memory) {
    _grantExists(grantUID);
    return _grants[grantUID];
  }
}
