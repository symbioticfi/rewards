// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title IRewardsReceiverRegistry
 * @notice Interface for the RewardsReceiverRegistry contract that manages rewards receiver assignments
 */
interface IRewardsReceiverRegistry {
    /* ERRORS */

    error InvalidReceiver();

    /* EVENTS */

    /**
     * @notice Emitted when a global rewards receiver is set for a rewardee
     * @param rewardee The address that earns rewards
     * @param receiver The address that receives the rewards
     */
    event GlobalRewardsReceiverSet(address indexed rewardee, address indexed receiver);

    /**
     * @notice Emitted when a chain-specific rewards receiver is set for a rewardee
     * @param rewardee The address that earns rewards
     * @param chainId The chain ID for which the receiver is set
     * @param receiver The address that receives the rewards
     */
    event ChainRewardsReceiverSet(address indexed rewardee, uint256 indexed chainId, address indexed receiver);

    /**
     * @notice Get the rewards receiver for a rewardee at a specific timestamp on a specific chain
     * @param rewardee The address that earns rewards
     * @param chainId The chain ID to query
     * @param timestamp The timestamp to query
     * @param hint Optional hint for checkpoint lookup optimization
     * @return receiver The rewards receiver address at the specified timestamp, or the rewardee if no receiver is set
     */

    /* FUNCTIONS */

    function getRewardsReceiverAt(
        address rewardee,
        uint64 chainId,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (address receiver);

    /**
     * @notice Get the current rewards receiver for a rewardee on a specific chain
     * @param rewardee The address that earns rewards
     * @param chainId The chain ID to query
     * @return receiver The current rewards receiver address, or the rewardee if no receiver is set
     */
    function getRewardsReceiver(address rewardee, uint64 chainId) external view returns (address receiver);

    /**
     * @notice Get the current global rewards receiver for a rewardee
     * @param rewardee The address that earns rewards
     * @return receiver The current global rewards receiver address
     */
    function getGlobalRewardsReceiver(
        address rewardee
    ) external view returns (address receiver);

    /**
     * @notice Get the current chain-specific rewards receiver for a rewardee
     * @param rewardee The address that earns rewards
     * @param chainId The chain ID to query
     * @return receiver The current chain-specific rewards receiver address
     */
    function getChainRewardsReceiver(address rewardee, uint64 chainId) external view returns (address receiver);

    /**
     * @notice Set a global rewards receiver for the caller
     * @param receiver The address that should receive the caller's rewards globally
     */
    function setGlobalRewardsReceiver(
        address receiver
    ) external;

    /**
     * @notice Set a chain-specific rewards receiver for the caller
     * @param chainId The chain ID for which to set the receiver
     * @param receiver The address that should receive the caller's rewards on the specified chain
     */
    function setChainRewardsReceiver(uint64 chainId, address receiver) external;
}
