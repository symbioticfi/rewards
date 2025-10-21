// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ICuratorRegistry} from "../../interfaces/rewardsV2/ICuratorRegistry.sol";

import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {StaticDelegateCallable} from "@symbioticfi/core/src/contracts/common/StaticDelegateCallable.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MulticallUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";

/**
 * @title CuratorRegistry
 * @notice Manages curator assignments for networks and vaults with historical tracking
 * @dev This contract handles curator management and access control through network middleware and network itself
 */
contract CuratorRegistry is StaticDelegateCallable, MulticallUpgradeable, ICuratorRegistry {
    using Checkpoints for Checkpoints.Trace208;

    /* STORAGE */

    struct CuratorRegistryStorage {
        mapping(address vault => Checkpoints.Trace208) _curators;
    }

    // keccak256(abi.encode(uint256(keccak256("symbiotic.rewards.CuratorRegistry")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CURATOR_REGISTRY_STORAGE_POSITION =
        0x50b0c8278802d3abbb2e677eb0a65452a0e12cbdc7ef8b06b4325691f656bc00;

    function _curatorRegistryStorage() private pure returns (CuratorRegistryStorage storage $) {
        assembly {
            $.slot := CURATOR_REGISTRY_STORAGE_POSITION
        }
    }

    /* PUBLIC FUNCTIONS */

    /**
     * @inheritdoc ICuratorRegistry
     */
    function getCuratorAt(
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (address) {
        return address(uint160(_curatorRegistryStorage()._curators[vault].upperLookupRecent(timestamp, hint)));
    }

    /**
     * @inheritdoc ICuratorRegistry
     */
    function getCurator(
        address vault
    ) public view returns (address) {
        return address(uint160(_curatorRegistryStorage()._curators[vault].latest()));
    }

    /**
     * @inheritdoc ICuratorRegistry
     */
    function setCurator(
        address vault,
        address curator
    ) public {
        (bool exists,, uint208 value) = _curatorRegistryStorage()._curators[vault].latestCheckpoint();

        if (exists) {
            if (address(uint160(value)) != msg.sender) {
                revert NotAuthorized();
            }
        } else if (Ownable(vault).owner() != msg.sender) {
            revert NotAuthorized();
        }

        _curatorRegistryStorage()._curators[vault].push(uint48(block.timestamp), uint208(uint160(curator)));
        emit SetCurator(vault, curator);
    }
}
