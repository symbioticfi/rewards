// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IStakerRewards} from "../stakerRewards/IStakerRewards.sol";

interface IMerkleStakerRewards is IStakerRewards {
    error AlreadySet();
    error InsufficientReward();
    error InsufficientTotalClaimable();
    error InvalidProof();
    error InvalidRewardTimestamp();
    error MissingRoles();
    error NoPendingRoot();
    error NotNetwork();
    error NotNetworkMiddleware();
    error NotReady();
    error NotVault();
    error RootNotSet();

    /**
     * @notice Initial parameters needed for a staker rewards contract deployment.
     * @param vault address of the vault to get stakers' data from
     * @param delay delay for setting a new root
     * @param defaultAdminRoleHolder address of the initial DEFAULT_ADMIN_ROLE holder
     * @param rootUpdaterRoleHolder address of the initial ROOT_UPDATER_ROLE holder
     * @param delaySetRoleHolder address of the initial DELAY_SET_ROLE holder
     */
    struct InitParams {
        address vault;
        uint256 delay;
        bytes32 root;
        address defaultAdminRoleHolder;
        address rootUpdaterRoleHolder;
        address delaySetRoleHolder;
    }

    /**
     * @notice Structure for a pending root.
     * @param root root to be set
     * @param timestamp timestamp since which the root can be set
     */
    struct PendingRoot {
        bytes32 root;
        uint256 timestamp;
    }

    /**
     * @notice Structure for a reward distribution.
     * @param amount amount of tokens to be distributed (admin fee is excluded)
     * @param timestamp time point stakes must taken into account at
     */
    struct RewardDistribution {
        uint256 amount;
        uint48 timestamp;
    }

    /**
     * @notice Emitted when rewards are claimed.
     * @param account address for which rewards are claimed
     * @param token address of the token claimed
     * @param amount amount of tokens claimed
     */
    event Claimed(address indexed account, address indexed token, uint256 amount);

    /**
     * @notice Emitted when a pending root is set.
     * @param newPendingRoot new pending root
     */
    event SubmitRoot(bytes32 newPendingRoot);

    /**
     * @notice Emitted when a new root is set.
     * @param newRoot new root
     */
    event SetRoot(bytes32 newRoot);

    /**
     * @notice Emitted when a new delay is set.
     * @param newDelay new delay
     */
    event SetDelay(uint256 newDelay);

    /**
     * @notice Get the root updater's role.
     * @return identifier of the root updater role
     */
    function ROOT_UPDATER_ROLE() external view returns (bytes32);

    /**
     * @notice Get the delay setter's role.
     * @return identifier of the delay setter role
     */
    function DELAY_SET_ROLE() external view returns (bytes32);

    /**
     * @notice Get the vault factory's address.
     * @return address of the vault factory
     */
    function VAULT_FACTORY() external view returns (address);

    /**
     * @notice Get the network middleware service's address.
     * @return address of the network middleware service
     */
    function NETWORK_MIDDLEWARE_SERVICE() external view returns (address);

    /**
     * @notice Get the vault's address.
     * @return address of the vault
     */
    function VAULT() external view returns (address);

    /**
     * @notice Get the current root.
     * @return root of the merkle tree for claiming rewards
     */
    function root() external view returns (bytes32);

    /**
     * @notice Get the pending root.
     * @return root of the merkle tree
     * @return timestamp since which the root can be set
     */
    function pendingRoot() external view returns (bytes32, uint256);

    /**
     * @notice Get the delay.
     * @return delay for setting a new root (in seconds)
     */
    function delay() external view returns (uint256);

    /**
     * @notice Get the total amount of tokens that have been claimed for a particular account.
     * @param account address of the account
     * @param token address of the token
     * @return amount of tokens that have been claimed
     */
    function claimed(address account, address token) external view returns (uint256);

    /**
     * @notice Get a particular reward distribution.
     * @param token address of the token
     * @param network address of the network
     * @param rewardIndex index of the reward distribution using the token
     * @return amount amount of tokens to be distributed
     * @return timestamp time point stakes must taken into account at
     */
    function rewards(
        address token,
        address network,
        uint256 rewardIndex
    ) external view returns (uint256 amount, uint48 timestamp);

    /**
     * @notice Set a new merkle root for claiming rewards.
     * @param newRoot new merkle root for claiming rewards
     * @dev Only the ROOT_UPDATER_ROLE holder can call this function.
     */
    function submitRoot(
        bytes32 newRoot
    ) external;

    /**
     * @notice Set a new delay for setting a new merkle root.
     * @param newDelay new delay for setting a new root (in seconds)
     * @dev Only the DELAY_SET_ROLE holder can call this function.
     */
    function setDelay(
        uint256 newDelay
    ) external;

    /**
     * @notice Accept a pending root.
     */
    function acceptRoot() external;
}
