// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title ICuratorRegistry
 * @notice Interface for the CuratorRegistry contract that manages curator assignments for vaults
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
     * @param hint Optional hint for checkpoint lookup optimization
     * @return curator The curator address at the specified timestamp
     */
    function getCuratorAt(address vault, uint48 timestamp, bytes memory hint) external view returns (address curator);

    /**
     * @notice Get the current curator for a vault
     * @param vault The vault address
     * @return curator The current curator address
     */
    function getCurator(
        address vault
    ) external view returns (address curator);

    /**
     * @notice Set a curator for a vault
     * @param vault The vault address
     * @param curator The curator address to set
     */
    function setCurator(address vault, address curator) external;
}
