// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";

import {ICuratorRegistry} from "../../interfaces/rewardsV2/ICuratorRegistry.sol";

import {MulticallUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CuratorRegistry is ICuratorRegistry, MulticallUpgradeable {
    using Checkpoints for Checkpoints.Trace208;

    /* STATE VARIABLES */

    mapping(address vault => Checkpoints.Trace208) internal _curators;

    /* PUBLIC FUNCTIONS */

    /**
     * @inheritdoc ICuratorRegistry
     */
    function getCuratorAt(
        address vault,
        uint48 timestamp
    ) public view returns (address curator) {
        return address(uint160(_curators[vault].upperLookupRecent(timestamp)));
    }

    /**
     * @inheritdoc ICuratorRegistry
     */
    function getCurator(
        address vault
    ) public view returns (address curator) {
        return address(uint160(_curators[vault].latest()));
    }

    /**
     * @inheritdoc ICuratorRegistry
     */
    function setCurator(
        address vault,
        address curator
    ) public {
        (bool exists,, uint208 value) = _curators[vault].latestCheckpoint();

        if (exists) {
            // If curator already exists, only current curator can change it
            if (address(uint160(value)) != msg.sender) {
                revert NotAuthorized();
            }
        } else {
            // If no curator exists, check if caller is vault owner
            address vaultOwner = Ownable(vault).owner();
            if (vaultOwner == address(0) || vaultOwner != msg.sender) {
                revert NotAuthorized();
            }
        }

        _curators[vault].push(uint48(block.timestamp), uint208(uint160(curator)));
        emit SetCurator(vault, curator);
    }
}
