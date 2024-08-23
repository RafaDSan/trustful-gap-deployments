// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IGrantRegistry {
  /// Emitted when a grant already exists in the Registry.
  error GrantAlreadyExists();
  /// Emitted when the grant does not exist in the Registry.
  error GrantNonExistent();
  /// Emitted when the sender is not the grant manager.
  error InvalidGrantManager();
  /// Emitted when the chain ID is invalid.
  error InvalidChain();

  /// Emitted when the grant is sucessfuly registered.
  event GrantRegistered(
    bytes32 indexed grantId,
    bytes32 indexed id,
    address indexed grantee,
    string grantProgramLabel,
    address manager
  );
  /// Emitted when the grant is updated.
  event GrantUpdated(
    bytes32 indexed grantId,
    bytes32 indexed id,
    string grantProgramLabel,
    Status status
  );
  /// Emitted when the grant is removed.
  event GrantDeleted(bytes32 indexed grantId);
  /// Emitted when the grant manager changes.
  event GrantManagerChanged(
    bytes32 indexed grantId,
    address indexed oldManager,
    address indexed newManager
  );

  /// Grant Struct.
  struct Grant {
    bytes32 id; // Optional unique identifier for the grant program to fetch the data
    uint256 chain; // Blockchain network where the grant is being developed
    address grantee; // Address of the person responsible for delivering and receiving the grant reward
    string grantProgramLabel; // Name of the protocol/community that issued the grant
    string project; // Name/Title of the project or company that received the grant
    string[] externalLinks; // Link that redirects to the grant proposal, discussion or relative
    uint256 startDate; // Start date for the grant development
    uint256 endDate; // Expected completion date for the grant
    Status status; // Current status of the grant
    Disbursement disbursements; // Disbursement stages based on milestones
  }

  /// Grant Status.
  enum Status {
    Proposed, // The grant has been proposed but not yet approved (Default)
    InProgress, // The project is actively being worked on
    Completed, // The project has been completed and deliverables submitted
    Cancelled, // The grant was cancelled
    Rejected // The grant proposal was reviewed and rejected
  }

  /// Disbursement Struct.
  /// @dev This struct is used to track the disbursement of funds based on milestones
  /// The disbursement is made in stages, each stage has a list of tokens and amounts
  /// to be disbursed. The boolean array disbursed is used to track if the disbursement.
  /// has been made in the current stage.
  struct Disbursement {
    address[] fundingTokens; // Tokens that will be disbursed in this stage
    uint256[] fundingAmounts; // Amounts of tokens to be disbursed in this stage
    bool[] disbursed; // Indicates if the disbursement has been made in this stage
  }

  /// @notice Register a new grant in the registry.
  /// @param grant The grant struct to be registered.
  /// @param manager The address allowed to perform operations on the grant.
  function register(Grant calldata grant, address manager) external returns (bytes32);

  /// @notice Update the grant data.
  /// @param grantId The grant ID to be updated.
  /// @param grant The new grant data.
  function update(bytes32 grantId, Grant calldata grant) external;

  /// @notice Remove a grant from the registry.
  /// @param grantId The grant ID to be removed.
  function remove(bytes32 grantId) external;

  /// @notice Transfer the manager of a grant to a new address.
  /// @param grantId The grant ID to be transferred.
  /// @param newManager The new manager address.
  function transferOwnership(bytes32 grantId, address newManager) external;

  /// @notice Get the grant data struct.
  /// Requirements:
  /// - The grant must exist.
  /// @param grantId The grant ID to be retrieved.
  function getGrant(bytes32 grantId) external view returns (Grant memory);

  /// @notice Get the manager address of a grant.
  /// @param grantId The grant ID to return the manager address.
  function getManager(bytes32 grantId) external view returns (address);

  /// @notice Generate a unique ID from a grant.
  /// @dev Have in mind that the generated ID will be unique at the time
  /// of creation, but when the grant data is updated, the ID will not change.
  /// @param grant The grant struct to generate the ID from
  function generateId(Grant calldata grant) external pure returns (bytes32);
}
