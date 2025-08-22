// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {IRewardsReceiverRegistry} from "../../interfaces/rewardsV2/IRewardsReceiverRegistry.sol";

/**
 * @title RewardsReceiverRegistry
 * @notice Manages rewards receiver assignments for rewardees across different chains
 * @dev This contract handles historical tracking of rewards receiver assignments at global and chain-specific levels
 */
contract RewardsReceiverRegistry is IRewardsReceiverRegistry {
    using Checkpoints for Checkpoints.Trace208;

    /* STATE VARIABLES */

    mapping(address rewardee => mapping(uint64 chainId => Checkpoints.Trace208 receiver)) internal _chainRewardsReceiver;
    mapping(address rewardee => Checkpoints.Trace208 receiver) internal _globalRewardsReceiver;

    /* EXTERNAL FUNCTIONS */

    /**
     * @inheritdoc IRewardsReceiverRegistry
     */
    function getRewardsReceiverAt(
        address rewardee,
        uint64 chainId,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (address receiver) {
        uint208 value = _chainRewardsReceiver[rewardee][chainId].upperLookupRecent(timestamp, hint);
        if (value > 0) {
            return address(uint160(value));
        }
        value = _globalRewardsReceiver[rewardee].upperLookupRecent(timestamp, hint);
        if (value > 0) {
            return address(uint160(value));
        }

        return address(0);
    }

    /**
     * @inheritdoc IRewardsReceiverRegistry
     */
    function getRewardsReceiver(address rewardee, uint64 chainId) external view returns (address receiver) {
        uint208 value = _chainRewardsReceiver[rewardee][chainId].latest();
        if (value > 0) {
            return address(uint160(value));
        }
        value = _globalRewardsReceiver[rewardee].latest();
        if (value > 0) {
            return address(uint160(value));
        }
        return address(0);
    }

    /**
     * @inheritdoc IRewardsReceiverRegistry
     */
    function getGlobalRewardsReceiver(
        address rewardee
    ) external view returns (address receiver) {
        return address(uint160(_globalRewardsReceiver[rewardee].latest()));
    }

    /**
     * @inheritdoc IRewardsReceiverRegistry
     */
    function getChainRewardsReceiver(address rewardee, uint64 chainId) external view returns (address receiver) {
        return address(uint160(_chainRewardsReceiver[rewardee][chainId].latest()));
    }

    /**
     * @inheritdoc IRewardsReceiverRegistry
     */
    function setGlobalRewardsReceiver(
        address receiver
    ) external {
        if (receiver == address(0)) {
            revert InvalidReceiver();
        }
        _globalRewardsReceiver[msg.sender].push(uint48(block.timestamp), uint208(uint160(receiver)));
        emit GlobalRewardsReceiverSet(msg.sender, receiver);
    }

    /**
     * @inheritdoc IRewardsReceiverRegistry
     */
    function setChainRewardsReceiver(uint64 chainId, address receiver) external {
        if (receiver == address(0)) {
            revert InvalidReceiver();
        }
        _chainRewardsReceiver[msg.sender][chainId].push(uint48(block.timestamp), uint208(uint160(receiver)));
        emit ChainRewardsReceiverSet(msg.sender, chainId, receiver);
    }
}
