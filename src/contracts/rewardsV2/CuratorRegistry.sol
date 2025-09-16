// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ICuratorRegistry} from "../../interfaces/rewardsV2/ICuratorRegistry.sol";

import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {StaticDelegateCallable} from "@symbioticfi/core/src/contracts/common/StaticDelegateCallable.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";

/**
 * @title CuratorRegistry
 * @notice Manages curator assignments for networks and vaults with historical tracking
 * @dev This contract handles curator management and access control through network middleware and network itself
 */
contract CuratorRegistry is ICuratorRegistry, StaticDelegateCallable, Multicall {
    using Checkpoints for Checkpoints.Trace208;

    /* STATE VARIABLES */

    mapping(address vault => Checkpoints.Trace208) internal _curators;

    /* PUBLIC FUNCTIONS */

    /**
     * @inheritdoc ICuratorRegistry
     */
    function getCuratorAt(address vault, uint48 timestamp, bytes memory hint) public view returns (address) {
        return address(uint160(_curators[vault].upperLookupRecent(timestamp, hint)));
    }

    /**
     * @inheritdoc ICuratorRegistry
     */
    function getCurator(
        address vault
    ) public view returns (address) {
        return address(uint160(_curators[vault].latest()));
    }

    /**
     * @inheritdoc ICuratorRegistry
     */
    function setCurator(address vault, address curator) public {
        address currentCurator = getCurator(vault);
        address vaultOwner = Ownable(vault).owner();

        if (currentCurator != address(0)) {
            if (currentCurator != msg.sender) {
                revert NotAuthorized();
            }
        } else if (vaultOwner != address(0)) {
            if (vaultOwner != msg.sender) {
                revert NotAuthorized();
            }
        } else {
            revert NotAuthorized();
        }

        _curators[vault].push(uint48(block.timestamp), uint208(uint160(curator)));
        emit SetCurator(vault, curator);
    }
}
