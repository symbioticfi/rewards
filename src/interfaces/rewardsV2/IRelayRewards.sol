// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IRewards} from "./IRewards.sol";

import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {INetworkManager} from "@symbioticfi/relay-contracts/src/interfaces/modules/base/INetworkManager.sol";

/**
 * @title IRelayRewards
 * @notice Interface for managing relay rewards distribution and configuration
 * @dev This interface defines the core functionality for relay rewards, including
 *      distribution of rewards, setting distribution types, and querying historical
 *      distribution type data using checkpoints.
 * @custom:security This interface is part of the Symbiotic rewards system and should
 *                  be used with appropriate access controls and validation.
 */
interface IRelayRewards {
    /* ERRORS */

    /**
     * @notice Error thrown when the rewards epoch is invalid
     */
    error RewardsEpochIsInvalid();

    /**
     * @notice Error thrown when the validator set epoch is stale
     */
    error ValidatorSetEpochIsStale();

    /* STRUCTS */

    /**
     * @notice Storage structure for relay rewards configuration
     * @dev This struct contains the core state variables for relay rewards
     * @param settlement The address responsible for settling rewards
     * @param unrewardedEpoch The epoch from which rewards distribution should start
     * @param requiredKeyTag The key tag required for rewards distribution
     * @param distributionType Checkpoint trace for tracking distribution type changes over time
     */
    struct RelayRewardsStorage {
        address settlement;
        uint48 unrewardedEpoch;
        uint8 requiredKeyTag;
        Checkpoints.Trace208 distributionType;
    }

    /**
     * @notice Initialization parameters for relay rewards
     * @dev Used when deploying or initializing a new relay rewards contract
     * @param settlement The settlement address for rewards
     * @param unrewardedEpoch The starting epoch for rewards distribution
     * @param requiredKeyTag The key tag required for rewards distribution
     * @param networkInitParams Network manager initialization parameters
     */
    struct RelayRewardsInitParams {
        address settlement;
        uint48 unrewardedEpoch;
        uint8 requiredKeyTag;
        INetworkManager.NetworkManagerInitParams networkInitParams;
    }

    /* EVENTS */
    /**
     * @notice Emitted when the distribution type is updated
     * @param newType The new distribution type that was set
     * @dev This event allows external systems to track changes in distribution strategy
     */
    event SetDistributionType(uint32 indexed newType);

    /* FUNCTIONS */

    /**
     * @notice Distributes rewards for a specific epoch
     * @dev This function handles the core rewards distribution logic, including
     *      validation of epochs and processing of top-up rewards
     * @param rewardsEpoch The epoch for which rewards are being distributed
     * @param cumulativeDistributionRoot The merkle root representing the cumulative distribution
     * @param daData Data availability information for the distribution
     * @param topUps Array of top-up rewards to be distributed
     * @param validatorSetEpoch The epoch of the validator set used for validation
     * @param proof Proof data for validating the distribution
     * @param hints Optional hints for the distribution
     */
    function distributeRewards(
        uint48 rewardsEpoch,
        bytes32 cumulativeDistributionRoot,
        bytes calldata daData,
        IRewards.TopUp[] calldata topUps,
        uint48 validatorSetEpoch,
        bytes calldata proof,
        bytes calldata hints
    ) external;

    /**
     * @notice Sets a new distribution type for rewards
     * @dev This function allows updating the distribution strategy used for rewards
     * @param newDistributionType The new distribution type to be set
     * @custom:security This function should only be called by authorized administrators
     *                  and should emit the DistributionTypeUpdated event
     */
    function setDistributionType(
        uint32 newDistributionType
    ) external;

    /**
     * @notice Retrieves the distribution type at a specific epoch
     * @dev Uses checkpoints to efficiently query historical distribution type data
     * @param epoch The epoch for which to retrieve the distribution type
     * @param hint Optional hint to optimize the checkpoint lookup
     * @return The distribution type that was active at the specified epoch
     */
    function getDistributionTypeAt(uint48 epoch, bytes memory hint) external view returns (uint32);

    /**
     * @notice Retrieves the current distribution type
     * @dev Returns the most recent distribution type that has been set
     * @return The current distribution type
     */
    function getDistributionType() external view returns (uint32);

    /**
     * @notice Sets the required key tag for rewards distribution
     * @param requiredKeyTag The new required key tag to be set
     */
    function setRequiredKeyTag(
        uint8 requiredKeyTag
    ) external;

    /**
     * @notice Retrieves the current required key tag
     * @return The current required key tag
     */
    function getRequiredKeyTag() external view returns (uint8);
}
