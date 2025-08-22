// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";
import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";
import {ICuratorRegistry} from "../../interfaces/rewardsV2/ICuratorRegistry.sol";

/**
 * @title CuratorRegistry
 * @notice Manages curator assignments for networks and vaults with historical tracking
 * @dev This contract handles curator management and access control through network middleware and network itself
 */
contract CuratorRegistry is ICuratorRegistry, Multicall {
    using Checkpoints for Checkpoints.Trace208;

    /* IMMUTABLES */

    address public immutable NETWORK_MIDDLEWARE_SERVICE;

    /* STATE VARIABLES */

    mapping(address network => mapping(address vault => Checkpoints.Trace208)) internal _curators;

    constructor(
        address networkMiddlewareService
    ) {
        NETWORK_MIDDLEWARE_SERVICE = networkMiddlewareService;
    }

    /* EXTERNAL FUNCTIONS */

    /**
     * @inheritdoc ICuratorRegistry
     */
    function getCuratorAt(
        address network,
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (address curator) {
        return address(uint160(_curators[network][vault].upperLookupRecent(timestamp, hint)));
    }

    /**
     * @inheritdoc ICuratorRegistry
     */
    function getCurator(address network, address vault) external view returns (address curator) {
        return address(uint160(_curators[network][vault].latest()));
    }

    /**
     * @inheritdoc ICuratorRegistry
     */
    function setCurator(address network, address vault, address curator) external {
        if (INetworkMiddlewareService(NETWORK_MIDDLEWARE_SERVICE).middleware(network) != msg.sender) {
            revert NotNetworkMiddleware();
        }
        _curators[network][vault].push(uint48(block.timestamp), uint208(uint160(curator)));
        emit CuratorSet(network, vault, curator);
    }

    /**
     * @inheritdoc ICuratorRegistry
     */
    function setCurator(address vault, address curator) external {
        _curators[msg.sender][vault].push(uint48(block.timestamp), uint208(uint160(curator)));
        emit CuratorSet(msg.sender, vault, curator);
    }
}
