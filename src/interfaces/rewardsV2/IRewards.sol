    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

/**
 * @title IRewards
 * @notice Interface for the Symbiotic Rewards V2 system
 * @dev This interface defines the core functionality for distributing and claiming rewards
 * across networks using Merkle trees and cumulative distributions.
 *
 * The system supports:
 * - Merkle tree-based reward distribution
 * - Cumulative distribution updates
 * - Top-up functionality for reward balances
 * - Claim verification using Merkle proofs
 * - Network-specific reward management
 *
 * @custom:security This interface is part of a rewards system that handles value transfers.
 * Implementations should include proper access controls and validation mechanisms.
 */
interface IRewards {
    /* ERRORS */

    /// @notice Error thrown when there are insufficient funds to process a claim
    error InsufficientBalance();

    /// @notice Error thrown when the claimable amount is less than requested
    error InsufficientClaimableAmount();

    /// @notice Error thrown when the provided Merkle proof is invalid
    error InvalidProof();

    /// @notice Error thrown when the caller is not authorized as a network rewarder
    error NotNetworkRewarder();

    /// @notice Error thrown when attempting to use a Merkle root that hasn't been set
    error RootNotSet();

    /// @notice Error thrown when the provided timestamp is invalid
    error InvalidTimestamp();

    /* EVENTS */

    /**
     * @notice Emitted when rewards are successfully claimed
     * @param network The address of the network for which rewards were claimed
     * @param token The address of the token being claimed
     * @param claimer The address of the account that initiated the claim
     * @param rewardee The address of the account receiving the rewards
     * @param amount The amount of rewards claimed
     */
    event ClaimRewards(
        address indexed network, address indexed token, address indexed claimer, address rewardee, uint256 amount
    );

    /**
     * @notice Emitted when the balance for a network-token pair is topped up
     * @param network The address of the network receiving the top-up
     * @param token The address of the token being topped up
     * @param amount The amount added to the balance
     */
    event TopUpBalance(address indexed network, address indexed token, uint256 amount);

    /* STRUCTS */

    /**
     * @notice Represents a cumulative distribution update for a network
     * @param timestamp The timestamp when this distribution was created
     * @param merkleRoot The Merkle root of the reward distribution tree
     * @param daData Additional data associated with the distribution
     */
    struct CumulativeDistribution {
        uint48 timestamp;
        bytes32 merkleRoot;
        bytes daData;
    }

    /**
     * @notice Represents a leaf in the reward distribution Merkle tree
     * @param token The address of the token being distributed
     * @param rewardee The address of the account eligible for rewards
     * @param amount The amount of rewards allocated to this account
     * @param rewardeeType The type of rewardee
     * @param rewardeeDataHash The hash of the rewardee data
     */
    struct CumulativeDistributionLeaf {
        address token;
        address rewardee;
        uint256 amount;
        uint256 rewardeeType;
        bytes32 rewardeeDataHash;
    }

    /**
     * @notice Represents a top-up operation for a specific token
     * @param token The address of the token being topped up
     * @param amount The amount to add to the balance
     */
    struct TopUp {
        address token;
        uint256 amount;
    }

    /**
     * @notice Represents distribution data for a specific token
     * @param token The address of the token
     * @param data Additional data associated with the token's distribution
     */
    struct DistributionData {
        address token;
        bytes32 data;
    }

    /* FUNCTIONS */

    /**
     * @notice Get the cumulative distribution data for a specific network
     * @param network The address of the network
     * @return timestamp The timestamp of the cumulative distribution
     * @return merkleRoot The Merkle root of the cumulative distribution
     * @return daData The DA data of the cumulative distribution
     */
    function cumulativeDistributions(
        address network
    ) external view returns (uint48 timestamp, bytes32 merkleRoot, bytes memory daData);

    /**
     * @notice Check if a specific Merkle root has been set for a network's cumulative distribution
     * @param network The address of the network
     * @param root The Merkle root to check
     * @return True if the root is set, false otherwise
     */
    function isCumulativeDistributionRoot(address network, bytes32 root) external view returns (bool);

    /**
     * @notice Get the DA (Data Availability) data for a specific network and Merkle root combination
     * @param network The address of the network
     * @param root The Merkle root associated with the DA data
     * @return The DA data as bytes
     */
    function cumulativeDistributionDaData(address network, bytes32 root) external view returns (bytes memory);

    /**
     * @notice Get the token balance for a specific network-token pair
     * @param network The address of the network
     * @param token The address of the token
     * @return The current balance amount for the network-token pair
     */
    function balances(address network, address token) external view returns (uint256);

    /**
     * @notice Get the claimed amount for a specific network, token, and rewardee combination
     * @param network The address of the network
     * @param token The address of the token
     * @param rewardee The address of the account that claimed rewards
     * @param rewardeeType The type of rewardee
     * @return The total amount claimed by this rewardee for this network-token pair
     */
    function claimed(
        address network,
        address token,
        address rewardee,
        uint256 rewardeeType
    ) external view returns (uint256);

    /**
     * @notice Get the authorized rewarder address for a specific network
     * @param network The address of the network
     * @return The address of the authorized rewarder for this network
     */
    function rewarder(
        address network
    ) external view returns (address);

    /**
     * @notice Calculate the claimable amount for a specific token and rewardee
     * @param token The address of the token to check
     * @param rewardee The address of the account to check claimable amount for
     * @param data Additional data needed for the calculation
     * @return The amount of tokens that can be claimed
     */
    function claimable(address token, address rewardee, bytes calldata data) external view returns (uint256);

    /**
     * @notice Get the distribution data for a specific network
     * @param network The address of the network
     * @return Array of distribution data for all tokens in the network
     */
    function getDistributionData(
        address network
    ) external view returns (DistributionData[] memory);

    /**
     * @notice Update the cumulative distribution for a network
     * @param network The address of the network to update
     * @param cumulativeDistribution The new cumulative distribution data
     * @param topUps Array of top-up operations to perform
     * @dev This function should only be callable by authorized network rewarders
     */
    function updateCumulativeDistribution(
        address network,
        CumulativeDistribution memory cumulativeDistribution,
        TopUp[] memory topUps
    ) external;

    /**
     * @notice Distribute rewards to a network for a specific token
     * @param network The address of the network to distribute rewards to
     * @param token The address of the token being distributed
     * @param amount The amount of tokens to distribute
     * @param data Additional data for the distribution
     * @dev This function should only be callable by authorized network rewarders
     */
    function distributeRewards(address network, address token, uint256 amount, bytes calldata data) external;

    /**
     * @notice Top up the balance for a network-token pair
     * @param network The address of the network
     * @param topUp The top-up operation details
     * @dev This function should only be callable by authorized network rewarders
     */
    function topUpBalance(address network, TopUp memory topUp) external;

    /**
     * @notice Claim rewards using a specific Merkle root and proof
     * @param network The address of the network to claim from
     * @param rewardee The address of the account claiming rewards
     * @param leaf The leaf data containing the reward information
     * @param proof The Merkle proof to verify the leaf
     * @param merkleRoot The Merkle root to verify against
     * @dev This function allows claiming against a specific root, useful for historical claims
     */
    function claimByRoot(
        address network,
        address rewardee,
        CumulativeDistributionLeaf calldata leaf,
        bytes32[] calldata proof,
        bytes32 merkleRoot
    ) external;

    /**
     * @notice Claim rewards using the current cumulative distribution
     * @param network The address of the network to claim from
     * @param rewardee The address of the account claiming rewards
     * @param leaf The leaf data containing the reward information
     * @param proof The Merkle proof to verify the leaf
     * @dev This function claims against the most recent cumulative distribution
     */
    function claim(
        address network,
        address rewardee,
        CumulativeDistributionLeaf calldata leaf,
        bytes32[] calldata proof
    ) external;

    /**
     * @notice Add distribution data for a specific token
     * @param token The address of the token
     * @param data The distribution data to associate with the token
     * @dev This function should only be callable by authorized administrators
     */
    function addDistributionData(address token, bytes32 data) external;

    /**
     * @notice Remove distribution data for a specific token
     * @param token The address of the token to remove data for
     * @dev This function should only be callable by authorized administrators
     */
    function removeDistributionData(
        address token
    ) external;

    /**
     * @notice Set the address of the authorized rewarder
     * @param rewarder_ The new rewarder address
     * @dev This function should only be callable by authorized administrators
     */
    function setRewarder(
        address rewarder_
    ) external;

    /**
     * @notice Get the version of this rewards interface
     * @return The version number as a uint64
     */
    function version() external view returns (uint64);
}
