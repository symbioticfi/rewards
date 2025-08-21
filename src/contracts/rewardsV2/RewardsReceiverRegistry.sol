// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {Time} from "@openzeppelin/contracts/utils/types/Time.sol";
import {IRewardsReceiverRegistry} from "../../interfaces/rewardsV2/IRewardsReceiverRegistry.sol";

/**
 * @title RewardsReceiverRegistry
 * @notice Manages rewards receiver assignments for rewardees across different chains
 * @dev This contract handles historical tracking of rewards receiver assignments at global and chain-specific levels
 */
contract RewardsReceiverRegistry is IRewardsReceiverRegistry {
    using Checkpoints for Checkpoints.Trace208;

    // State variables
    mapping(address rewardee => mapping(uint64 chainId => Checkpoints.Trace208 receiver)) chainRewardsReceiver;
    mapping(address rewardee => Checkpoints.Trace208 receiver) globalRewardsReceiver;

    // External functions
    /**
     * @inheritdoc IRewardsReceiverRegistry
     */
    function setGlobalRewardsReceiver(
        address receiver
    ) external {
        globalRewardsReceiver[msg.sender].push(Time.timestamp(), uint208(uint160(receiver)));
        emit GlobalRewardsReceiverSet(msg.sender, receiver);
    }

    /**
     * @inheritdoc IRewardsReceiverRegistry
     */
    function setChainRewardsReceiver(uint64 chainId, address receiver) external {
        chainRewardsReceiver[msg.sender][chainId].push(Time.timestamp(), uint208(uint160(receiver)));
        emit ChainRewardsReceiverSet(msg.sender, chainId, receiver);
    }

    /**
     * @inheritdoc IRewardsReceiverRegistry
     */
    function getRewardsReceiverAt(
        address rewardee,
        uint64 chainId,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (address receiver) {
        (bool exists,, uint208 value,) =
            chainRewardsReceiver[rewardee][chainId].upperLookupRecentCheckpoint(timestamp, hint);
        if (exists) {
            return address(uint160(value));
        }
        (exists,, value,) = globalRewardsReceiver[rewardee].upperLookupRecentCheckpoint(timestamp, hint);
        if (exists) {
            return address(uint160(value));
        }

        return rewardee;
    }

    /**
     * @inheritdoc IRewardsReceiverRegistry
     */
    function getRewardsReceiver(address rewardee, uint64 chainId) external view returns (address receiver) {
        (bool exists,, uint208 value) = chainRewardsReceiver[rewardee][chainId].latestCheckpoint();
        if (exists) {
            return address(uint160(value));
        }
        (exists,, value) = globalRewardsReceiver[rewardee].latestCheckpoint();
        if (exists) {
            return address(uint160(value));
        }
        return rewardee;
    }

    /**
     * @inheritdoc IRewardsReceiverRegistry
     */
    function getGlobalRewardsReceiver(
        address rewardee
    ) external view returns (address receiver) {
        (,, uint208 value) = globalRewardsReceiver[rewardee].latestCheckpoint();
        return address(uint160(value));
    }

    /**
     * @inheritdoc IRewardsReceiverRegistry
     */
    function getChainRewardsReceiver(address rewardee, uint64 chainId) external view returns (address receiver) {
        (,, uint208 value) = chainRewardsReceiver[rewardee][chainId].latestCheckpoint();
        return address(uint160(value));
    }
}
