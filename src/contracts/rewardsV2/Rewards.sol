// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {VaultSnapshotRewards} from "./VaultSnapshotRewards.sol";
import {CumulativeMerkleRewards} from "./CumulativeMerkleRewards.sol";

import {IRewards} from "../../interfaces/rewardsV2/IRewards.sol";

import {MulticallUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

contract Rewards is VaultSnapshotRewards, CumulativeMerkleRewards, MulticallUpgradeable, IRewards {
    /* CONSTRUCTOR */

    constructor(
        address vaultFactory,
        address networkRegistry,
        address networkMiddlewareService,
        address curatorRegistry,
        address feeRegistry
    ) VaultSnapshotRewards(vaultFactory, networkRegistry, networkMiddlewareService, curatorRegistry, feeRegistry) {}

    /* FUNCTIONS */

    /**
     * @inheritdoc IRewards
     */
    function initialize(
        IRewards.RewardsInitParams calldata initParams
    ) external override initializer {
        __VaultSnapshotRewards_init(initParams.vaultSnapshotRewardsInitParams);
        __CumulativeMerkleRewards_init(initParams.cumulativeMerkleRewardsInitParams);
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
