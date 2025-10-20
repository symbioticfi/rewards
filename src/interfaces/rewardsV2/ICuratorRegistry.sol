// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title ICuratorRegistry
 * @notice Manages curator assignments for vaults with historical tracking
 * @dev Allows the network to match curators to vaults and exposes historical lookups.
 */
interface ICuratorRegistry {
    /* ERRORS */

    error NotAuthorized();

    /* EVENTS */

    /**
     * @notice Emitted when a curator is set for vault
     * @param vault The vault address
     * @param curator The curator address
     */
    event SetCurator(address indexed vault, address indexed curator);

    /* FUNCTIONS */

    /**
     * @notice Get the curator for a vault at a specific timestamp
     * @param vault The vault address
     * @param timestamp The timestamp to query
     * @param hint Optional hint for optimization
     * @return The curator address at the specified timestamp
     */
    function getCuratorAt(
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (address);

    /**
     * @notice Get the current curator for a vault
     * @param vault The vault address
     * @return The current curator address
     */
    function getCurator(
        address vault
    ) external view returns (address);

    /**
     * @notice Set a curator for a vault
     * @param vault The vault address
     * @param curator The curator address to set
     * @dev Access control:
     * - If a curator is already set, only the current curator can change it
     * - If the vault has an owner, only the owner can set the curator
     */
    function setCurator(
        address vault,
        address curator
    ) external;
}
