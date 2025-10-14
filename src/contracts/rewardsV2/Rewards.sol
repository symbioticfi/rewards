// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {VaultSnapshotRewards} from "./VaultSnapshotRewards.sol";
import {CumulativeMerkleRewards} from "./CumulativeMerkleRewards.sol";
import {IRewards} from "../../interfaces/rewardsV2/IRewards.sol";
import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

contract Rewards is VaultSnapshotRewards, CumulativeMerkleRewards, Multicall, IRewards {
    /* CONSTRUCTOR */

    constructor(
        address vaultFactory,
        address networkRegistry,
        address networkMiddlewareService,
        address curatorRegistry,
        address feeRegistry
    ) VaultSnapshotRewards(vaultFactory, networkRegistry, networkMiddlewareService, curatorRegistry, feeRegistry) {}

    /* CONTEXT OVERRIDES */

    function _msgSender() internal view override(Context, ContextUpgradeable) returns (address) {
        return super._msgSender();
    }

    function _msgData() internal view override(Context, ContextUpgradeable) returns (bytes calldata) {
        return super._msgData();
    }

    function _contextSuffixLength() internal view override(Context, ContextUpgradeable) returns (uint256) {
        return super._contextSuffixLength();
    }

    /* FUNCTIONS */

    /**
     * @inheritdoc IRewards
     */
    function initialize(
        IRewards.RewardsInitParams calldata initParams
    ) external override initializer {
        // Initialize VaultSnapshotRewards
        __VaultSnapshotRewards_init(initParams.vaultSnapshotRewardsInitParams);

        // Initialize CumulativeMerkleRewards
        __CumulativeMerkleRewards_init(initParams.cumulativeMerkleRewardsInitParams);

        // Set owner
        _transferOwnership(initParams.owner);
    }

    /**
     * @inheritdoc IRewards
     */
    function claimRewards(
        address recipient,
        address token,
        bytes calldata data
    ) public override(VaultSnapshotRewards, CumulativeMerkleRewards, IRewards) {
        if (data.length < 8) {
            revert InvalidDataLength();
        }

        // Extract reward type from first 8 bytes
        uint64 rewardsType;
        assembly {
            rewardsType := shr(192, calldataload(data.offset))
        }

        if (rewardsType == uint64(IRewards.RewardsType.VAULT_SNAPSHOT)) {
            VaultSnapshotRewards.claimRewards(recipient, token, data[8:]);
        } else if (rewardsType == uint64(IRewards.RewardsType.CUMULATIVE_MERKLE)) {
            CumulativeMerkleRewards.claimRewards(recipient, token, data[8:]);
        } else {
            revert InvalidRewardType();
        }
    }
}
