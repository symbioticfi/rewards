// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title ICuratorRegistry
 * @notice Interface for the CuratorRegistry contract that manages curator assignments for networks and vaults
 */
interface ICuratorRegistry {
    /**
     * @notice Emitted when a curator is set for a network and vault
     * @param network The network identifier
     * @param vault The vault address
     * @param curator The curator address
     */
    event CuratorSet(address indexed network, address indexed vault, address indexed curator);

    /**
     * @notice Error thrown when the caller is not the network middleware
     */
    error NotNetworkMiddleware();

    /**
     * @notice Get the curator for a network and vault at a specific timestamp
     * @param network The network identifier
     * @param vault The vault address
     * @param timestamp The timestamp to query
     * @param hint Optional hint for checkpoint lookup optimization
     * @return curator The curator address at the specified timestamp
     */
    function getCuratorAt(
        address network,
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (address curator);

    /**
     * @notice Get the current curator for a network and vault
     * @param network The network identifier
     * @param vault The vault address
     * @return curator The current curator address
     */
    function getCurator(address network, address vault) external view returns (address curator);

    /**
     * @notice Set a curator for a network and vault (only callable by network middleware)
     * @param network The network identifier
     * @param vault The vault address
     * @param curator The curator address to set
     */
    function setCurator(address network, address vault, address curator) external;

    /**
     * @notice Set a curator for a vault for the caller's network
     * @param vault The vault address
     * @param curator The curator address to set
     */
    function setCurator(address vault, address curator) external;
}
