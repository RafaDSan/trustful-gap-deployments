// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @notice The interface of the {GrantRegistry} contract.
interface IGrantRegistry {
  /// Grant Status.
  enum Status {
    Proposed, // The grant has been proposed but not yet approved (Default)
    InProgress, // The project is actively being worked on
    Completed, // The project has been completed and deliverables submitted
    Cancelled, // The grant was cancelled
    Rejected // The grant proposal was reviewed and rejected
  }

  /// @notice Get the grantee address.
  /// @param grantUID The grant ID to be retrieved.
  function getGranteeAddress(bytes32 grantUID) external view returns (address);

  /// @notice Get the grant program UID.
  /// @param grantUID The grant ID to be retrieved.
  function getGrantProgramUID(bytes32 grantUID) external view returns (uint256);

  /// @notice Get the grant status.
  /// @param grantUID The grant ID to be retrieved.
  function getStatus(bytes32 grantUID) external view returns (Status);
}
