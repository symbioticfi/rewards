// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ICumulativeMerkleRewards} from "./ICumulativeMerkleRewards.sol";
import {IVaultSnapshotRewards} from "./IVaultSnapshotRewards.sol";

/**
 * @title IRewards
 * @notice Main rewards interface combining all reward types (VaultSnapshot and CumulativeMerkle)
 * @dev Deployed by Symbiotic on each chain where rewards are distributed. It combines
 * VaultSnapshotRewards and CumulativeMerkleRewards functionality under a unified API.
 */
interface IRewards {
    /* ERRORS */

    error InvalidDataLength();
    error InvalidRewardType();

    /* STRUCTS */

    enum RewardsType {
        VAULT_SNAPSHOT,
        CUMULATIVE_MERKLE
    }

    struct RewardsInitParams {
        ICumulativeMerkleRewards.CumulativeMerkleRewardsInitParams cumulativeMerkleRewardsInitParams;
        IVaultSnapshotRewards.VaultSnapshotRewardsInitParams vaultSnapshotRewardsInitParams;
        address owner;
    }

    /* FUNCTIONS */

    /**
     * @notice Initialize the main Rewards contract
     * @param initParams Initialization parameters containing all sub-contract parameters
     */
    function initialize(
        RewardsInitParams calldata initParams
    ) external;

    /**
     * @notice Claim rewards via a unified entrypoint
     * @param recipient The recipient address
     * @param token The token address
     * @param data The encoded claim data containing reward type and specific data
     * @dev The function routes to the appropriate reward type based on the first 8 bytes (uint64)
     * of the payload that identify the rewards type. Remaining bytes are reward-specific data.
     */
    function claimRewards(address recipient, address token, bytes calldata data) external;
}
