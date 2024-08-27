// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @notice The interface of the {Resolver} contract.
interface IEASResolver {
  /// @notice Returns the owner of the project.
  /// @param key The key of the project.
  function projectOwner(bytes32 key) external view returns (address);
}
