// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";
import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {Time} from "@openzeppelin/contracts/utils/types/Time.sol";
import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";
import {ICuratorRegistry} from "../../interfaces/rewardsV2/ICuratorRegistry.sol";

/**
 * @title CuratorRegistry
 * @notice Manages curator assignments for networks and vaults with historical tracking
 * @dev This contract handles curator management and access control through network middleware
 */
contract CuratorRegistry is ICuratorRegistry, Multicall {
    using Checkpoints for Checkpoints.Trace208;

    // State variables
    address public immutable NETWORK_MIDDLEWARE_SERVICE;

    // State mappings
    mapping(address network => mapping(address vault => Checkpoints.Trace208)) curators;

    // Constructor
    constructor(
        address networkMiddlewareService
    ) {
        NETWORK_MIDDLEWARE_SERVICE = networkMiddlewareService;
    }

    // Modifiers
    modifier onlyNetworkMiddleware(
        address network
    ) {
        _checkNetworkMiddleware(network);
        _;
    }

    // xternal functions
    /**
     * @inheritdoc ICuratorRegistry
     */
    function setCurator(address network, address vault, address curator) external onlyNetworkMiddleware(network) {
        curators[network][vault].push(Time.timestamp(), uint208(uint160(curator)));
        emit CuratorSet(network, vault, curator);
    }

    /**
     * @inheritdoc ICuratorRegistry
     */
    function setCurator(address vault, address curator) external {
        curators[msg.sender][vault].push(Time.timestamp(), uint208(uint160(curator)));
        emit CuratorSet(msg.sender, vault, curator);
    }

    /**
     * @inheritdoc ICuratorRegistry
     */
    function getCuratorAt(
        address network,
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (address curator) {
        (bool exists,, uint208 value,) = curators[network][vault].upperLookupRecentCheckpoint(timestamp, hint);
        if (exists) {
            return address(uint160(value));
        }
    }

    /**
     * @inheritdoc ICuratorRegistry
     */
    function getCurator(address network, address vault) external view returns (address curator) {
        (bool exists,, uint208 value) = curators[network][vault].latestCheckpoint();
        if (exists) {
            return address(uint160(value));
        }
    }

    // Internal functions
    /**
     * @dev Checks if the caller is the network middleware for the specified network
     * @param network The network to check
     */
    function _checkNetworkMiddleware(
        address network
    ) internal view {
        if (INetworkMiddlewareService(NETWORK_MIDDLEWARE_SERVICE).middleware(network) != msg.sender) {
            revert NotNetworkMiddleware();
        }
    }
}
