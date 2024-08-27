// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @notice The interface of the {GrantRegistry} contract.
interface IGrantRegistry {
  /// Emitted when a grant already exists in the Registry.
  error GrantAlreadyExists();
  /// Emitted when a grant doesn't exists in the Registry.
  error GrantNonExistent();
  /// Emitted when the grant owner is non-existent.
  error InvalidGrantOwner();
  /// Emitted when the array length is invalid.
  error InvalidArrayLength();

  /// Emitted when the grant is sucessfuly registered.
  event GrantRegistered(
    bytes32 indexed grantUID,
    uint256 indexed grantProgramUID,
    address indexed grantee,
    uint256 status
  );
  /// Emitted when the grant is updated.
  event GrantUpdated(bytes32 indexed grantUID, uint256 status);
  /// Emitted when the grant is removed.
  event GrantDeleted(bytes32 indexed grantUID);

  /// Grant Struct.
  struct Grant {
    address grantee; // Address of the person in charge of delivering the grant
    uint256 grantProgramUID; // The grant program UID defined by Karma Gap
    Status status; // Current status of the grant
  }

  /// Grant Status.
  enum Status {
    Proposed, // The grant has been proposed but not yet approved (Default)
    InProgress, // The project is actively being worked on
    Completed, // The project has been completed and deliverables submitted
    Cancelled, // The grant was cancelled
    Rejected // The grant proposal was reviewed and rejected
  }

  /// @notice Batch register grants in the registry.
  /// See {IGrantRegistry.register}.
  function batchRegister(
    bytes32[] calldata grantUIDs,
    uint256[] calldata grantProgramUIDs,
    uint256[] calldata statuses
  ) external;

  /// @notice Register a new grant in the registry.
  /// @param grantUID The grant struct to be registered.
  /// @param grantProgramUID The UID of the grant program.
  /// @param status The status of the grant.
  function register(bytes32 grantUID, uint256 grantProgramUID, uint256 status) external;

  /// @notice Update the grant data.
  /// @param grantUID The grant ID to be updated.
  /// @param status The status of the grant.
  function update(bytes32 grantUID, uint256 status) external;

  /// @notice Remove a grant from the registry.
  /// @param grantUID The grant ID to be removed.
  function remove(bytes32 grantUID) external;

  /// @notice Get the grantee address.
  /// @param grantUID The grant ID to be retrieved.
  function getGrantee(bytes32 grantUID) external view returns (address);

  /// @notice Get the grant program UID.
  /// @param grantUID The grant ID to be retrieved.
  function getGrantProgramUID(bytes32 grantUID) external view returns (uint256);

  /// @notice Get the grant status.
  /// @param grantUID The grant ID to be retrieved.
  function getStatus(bytes32 grantUID) external view returns (Status);

  /// @notice Get the grant data struct.
  /// Requirements:
  /// - The grant must exist.
  /// @param grantUID The grant ID to be retrieved.
  function getGrant(bytes32 grantUID) external view returns (Grant memory);
}
