// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IProtocolFees} from "./IProtocolFees.sol";

/**
 * @title IVaultSnapshotRewards
 * @notice Interface for distributing rewards to stakers and curators based on on-chain vault state
 * @dev Based on DefaultStakerRewards logic but adapted for the new rewards system.
 */
interface IVaultSnapshotRewards {
    /* ERRORS */

    error NotNetworkOrMiddleware();
    error NotCurator();
    error InvalidVault();
    error InvalidRewardTimestamp();
    error InsufficientReward();
    error NoRewardsToClaim();
    error InvalidHintsLength();
    error InvalidRecipient();
    error InvalidDelegatorType();
    error NotOperator();
    error HighFee();
    error InvalidLastUnclaimedReward();

    /* STRUCTS */

    struct RewardDistribution {
        uint96 subnetworkId;
        address delegator;
        uint64 delegatorType;
        uint48 timestamp;
        uint256 amount;
        uint256 operatorsFee;
    }

    struct ClaimOperatorFeeLocalVars {
        uint256 rewardIndex;
        uint256 rewardsToClaim;
        bool useHints;
        uint256 amount;
        uint256 networkRestakeDelegatorCounter;
    }

    /* EVENTS */

    event DistributeVaultSnapshotRewards(
        address indexed network,
        address indexed token,
        address indexed vault,
        uint96 subnetworkId,
        uint48 timestamp,
        uint256 amount,
        uint256 curatorFee,
        uint256 operatorsFee
    );

    event ClaimVaultSnapshotRewards(
        address indexed staker,
        address indexed network,
        address indexed token,
        address vault,
        uint256 amount,
        uint256 lastUnclaimedIndex
    );

    event ClaimCuratorFee(address indexed vault, address indexed token, uint256 amount);

    event ClaimOperatorFee(
        address indexed operator,
        address indexed network,
        address indexed token,
        address vault,
        uint256 amount,
        uint256 lastUnclaimedIndex
    );

    /* FUNCTIONS */

    /**
     * @notice Get the vault factory address
     * @return The vault factory address
     */
    function VAULT_FACTORY() external view returns (address);

    /**
     * @notice Get the network registry address
     * @return The network registry address
     */
    function NETWORK_REGISTRY() external view returns (address);

    /**
     * @notice Get the network middleware service address
     * @return The network middleware service address
     */
    function NETWORK_MIDDLEWARE_SERVICE() external view returns (address);

    /**
     * @notice Get the curator registry address
     * @return The curator registry address
     */
    function CURATOR_REGISTRY() external view returns (address);

    /**
     * @notice Get the length of rewards for a network and token
     * @param vault The vault address
     * @param network The network address
     * @param token The token address
     * @return The number of reward distributions
     */
    function rewardsLength(
        address vault,
        address network,
        address token
    ) external view returns (uint256);

    /**
     * @notice Get a reward distribution by index
     * @param vault The vault address
     * @param network The network address
     * @param token The token address
     * @param index The reward index
     * @return The reward distribution
     */
    function rewards(
        address vault,
        address network,
        address token,
        uint256 index
    ) external view returns (RewardDistribution memory);

    /**
     * @notice Get the last unclaimed reward index for an account
     * @param account The account address
     * @param vault The vault address
     * @param network The network address
     * @param token The token address
     * @return The last unclaimed reward index
     */
    function lastUnclaimedReward(
        address account,
        address vault,
        address network,
        address token
    ) external view returns (uint256);

    /**
     * @notice Get the last unclaimed operator reward index for an account
     * @param account The account address
     * @param vault The vault address
     * @param network The network address
     * @param token The token address
     * @return The last unclaimed operator reward index
     */
    function lastUnclaimedOperatorReward(
        address account,
        address vault,
        address network,
        address token
    ) external view returns (uint256);

    /**
     * @notice Distribute vault snapshot rewards (only network or middleware)
     * @param subnetwork The subnetwork identifier
     * @param token The token address
     * @param vault The vault address
     * @param amount The amount to distribute
     * @param timestamp The distribution timestamp
     * @param activeSharesHint Hint for active shares calculation
     */
    function distributeVaultSnapshotRewards(
        bytes32 subnetwork,
        address token,
        address vault,
        uint256 amount,
        uint48 timestamp,
        bytes calldata activeSharesHint
    ) external;

    /**
     * @notice Claim vault snapshot rewards
     * @param recipient The recipient address
     * @param network The network address
     * @param token The token address
     * @param vault The vault address
     * @param lastUnclaimedRewards The last unclaimed rewards index
     * @param firstRewardToClaim The first reward index to claim (optional)
     * @param maxRewards The maximum number of rewards to process
     * @param activeSharesOfHints Hints for active shares calculation
     */
    function claimVaultSnapshotRewards(
        address recipient,
        address network,
        address token,
        address vault,
        uint256 lastUnclaimedRewards,
        uint256 firstRewardToClaim,
        uint256 maxRewards,
        bytes[] memory activeSharesOfHints
    ) external;

    /**
     * @notice Claim curator fee (only curator)
     * @param recipient The recipient address
     * @param vault The vault address
     * @param token The token address
     */
    function claimCuratorFee(
        address recipient,
        address vault,
        address token
    ) external;

    /**
     * @notice Claim operator fee
     * @param recipient The recipient address
     * @param network The network address
     * @param token The token address
     * @param vault The vault address
     * @param lastUnclaimedRewards The last unclaimed rewards index
     * @param firstRewardToClaim The first reward index to claim (optional)
     * @param maxRewards The maximum number of rewards to process
     * @param extraData Additional data for operator type-specific logic
     */
    function claimOperatorFee(
        address recipient,
        address network,
        address token,
        address vault,
        uint256 lastUnclaimedRewards,
        uint256 firstRewardToClaim,
        uint256 maxRewards,
        bytes calldata extraData
    ) external;

    /**
     * @notice Claim rewards via the vault snapshot path
     * @param recipient The recipient address
     * @param token The token address
     * @param data The encoded claim data
     */
    function claimRewards(
        address recipient,
        address token,
        bytes calldata data
    ) external;
}
