// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {FeeRegistry} from "./FeeRegistry.sol";
import {ProtocolFees} from "./ProtocolFees.sol";

import {ICuratorRegistry} from "../../interfaces/rewardsV2/ICuratorRegistry.sol";
import {IFeeRegistry} from "../../interfaces/rewardsV2/IFeeRegistry.sol";
import {IVaultSnapshotRewards} from "../../interfaces/rewardsV2/IVaultSnapshotRewards.sol";
import {IRewards} from "../../interfaces/rewardsV2/IRewards.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {Subnetwork} from "@symbioticfi/core/src/contracts/libraries/Subnetwork.sol";

import {IBaseDelegator} from "@symbioticfi/core/src/interfaces/delegator/IBaseDelegator.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";
import {
    IOperatorNetworkSpecificDelegator
} from "@symbioticfi/core/src/interfaces/delegator/IOperatorNetworkSpecificDelegator.sol";
import {IOperatorSpecificDelegator} from "@symbioticfi/core/src/interfaces/delegator/IOperatorSpecificDelegator.sol";
import {IRegistry} from "@symbioticfi/core/src/interfaces/common/IRegistry.sol";
import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";
import {INetworkRestakeDelegator} from "@symbioticfi/core/src/interfaces/delegator/INetworkRestakeDelegator.sol";

abstract contract VaultSnapshotRewards is ProtocolFees, IVaultSnapshotRewards {
    using SafeERC20 for IERC20;
    using Math for uint256;
    using Subnetwork for bytes32;

    /* CONSTANTS */

    address public immutable VAULT_FACTORY;
    address public immutable NETWORK_REGISTRY;
    address public immutable NETWORK_MIDDLEWARE_SERVICE;
    address public immutable CURATOR_REGISTRY;

    /* STORAGE */

    struct VaultSnapshotRewardsStorage {
        mapping(
            address vault => mapping(address network => mapping(address token => RewardDistribution[] rewards_))
        ) _rewards;
        mapping(
            address account
                => mapping(address vault => mapping(address network => mapping(address token => uint256 rewardIndex)))
        ) _lastUnclaimedReward;
        mapping(
            address account
                => mapping(address vault => mapping(address network => mapping(address token => uint256 rewardIndex)))
        ) _lastUnclaimedOperatorReward;
        mapping(address vault => mapping(uint48 timestamp => uint256 amount)) _activeSharesCache;
        mapping(address vault => mapping(address token => uint256 fee)) _curatorFees;
    }

    // keccak256(abi.encode(uint256(keccak256("symbiotic.rewards.VaultSnapshotRewards")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant VAULT_SNAPSHOT_REWARDS_STORAGE_POSITION =
        0xea7ec811d4da20f680ecf87dbad2b956cc74e833cd99b5f63865df6b3d6b6800;

    function _vaultSnapshotRewardsStorage() private pure returns (VaultSnapshotRewardsStorage storage $) {
        assembly {
            $.slot := VAULT_SNAPSHOT_REWARDS_STORAGE_POSITION
        }
    }

    /* FUNCTIONS */

    constructor(
        address vaultFactory,
        address networkRegistry,
        address networkMiddlewareService,
        address curatorRegistry,
        address feeRegistry
    ) ProtocolFees(feeRegistry) {
        VAULT_FACTORY = vaultFactory;
        NETWORK_REGISTRY = networkRegistry;
        NETWORK_MIDDLEWARE_SERVICE = networkMiddlewareService;
        CURATOR_REGISTRY = curatorRegistry;
        FEE_REGISTRY = feeRegistry;
    }

    function __VaultSnapshotRewards_init(
        VaultSnapshotRewardsInitParams calldata initParams
    ) internal onlyInitializing {}

    /**
     * @inheritdoc IVaultSnapshotRewards
     */
    function rewardsLength(
        address vault,
        address network,
        address token
    ) public view returns (uint256) {
        return _vaultSnapshotRewardsStorage()._rewards[vault][network][token].length;
    }

    /**
     * @inheritdoc IVaultSnapshotRewards
     */
    function rewards(
        address vault,
        address network,
        address token,
        uint256 index
    ) public view returns (RewardDistribution memory) {
        return _vaultSnapshotRewardsStorage()._rewards[vault][network][token][index];
    }

    /**
     * @inheritdoc IVaultSnapshotRewards
     */
    function lastUnclaimedReward(
        address account,
        address vault,
        address network,
        address token
    ) public view returns (uint256) {
        return _vaultSnapshotRewardsStorage()._lastUnclaimedReward[account][vault][network][token];
    }

    /**
     * @inheritdoc IVaultSnapshotRewards
     */
    function distributeVaultSnapshotRewards(
        bytes32 subnetwork,
        address token,
        address vault,
        uint256 amount,
        uint48 timestamp,
        bytes calldata activeSharesHint
    ) public {
        // Check authorization - either network middleware or network itself
        address network = subnetwork.network();
        if (
            network != msg.sender
                && INetworkMiddlewareService(NETWORK_MIDDLEWARE_SERVICE).middleware(network) != msg.sender
                || !IRegistry(NETWORK_REGISTRY).isEntity(network)
        ) {
            revert NotNetworkOrMiddleware();
        }

        // Validate vault
        if (!IRegistry(VAULT_FACTORY).isEntity(vault)) {
            revert InvalidVault();
        }

        // Validate timestamp
        if (timestamp >= block.timestamp) {
            revert InvalidRewardTimestamp();
        }

        // Cache active shares if not already cached
        if (_vaultSnapshotRewardsStorage()._activeSharesCache[vault][timestamp] == 0) {
            uint256 activeShares = IVault(vault).activeSharesAt(timestamp, activeSharesHint);

            if (activeShares == 0) {
                revert InvalidRewardTimestamp();
            }

            _vaultSnapshotRewardsStorage()._activeSharesCache[vault][timestamp] = activeShares;
        }

        // Transfer tokens
        uint256 balanceBefore = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        amount = IERC20(token).balanceOf(address(this)) - balanceBefore;

        if (amount == 0) {
            revert InsufficientReward();
        }

        // Deduct protocol fees from the remaining amount
        uint256 protocolFees = _deductProtocolFees(uint64(IRewards.RewardsType.VAULT_SNAPSHOT), network, token, amount);
        uint256 remainingAmount = amount - protocolFees;

        uint256 maxFee = FeeRegistry(FEE_REGISTRY).MAX_FEE();
        // Get curator fee from FeeRegistry
        uint256 curatorFees = remainingAmount.mulDiv(IFeeRegistry(FEE_REGISTRY).getCuratorFee(vault, network), maxFee); // Assuming 10000 as base

        // Get operators fee from FeeRegistry
        uint256 operatorsFees =
            remainingAmount.mulDiv(IFeeRegistry(FEE_REGISTRY).getOperatorsFee(vault, network), maxFee);

        // Calculate final distribution amount
        uint256 distributeAmount = remainingAmount - curatorFees - operatorsFees;

        // Update curator fees
        _vaultSnapshotRewardsStorage()._curatorFees[vault][token] += curatorFees;

        // Store reward distribution
        _vaultSnapshotRewardsStorage()._rewards[vault][network][token]
        .push(
            RewardDistribution({
                subnetworkId: subnetwork.identifier(),
                delegator: IVault(vault).delegator(),
                delegatorType: IBaseDelegator(IVault(vault).delegator()).TYPE(),
                timestamp: timestamp,
                amount: distributeAmount,
                operatorsFee: operatorsFees
            })
        );

        emit DistributeVaultSnapshotRewards(
            network, token, vault, subnetwork.identifier(), timestamp, distributeAmount, curatorFees, operatorsFees
        );
    }

    /**
     * @inheritdoc IVaultSnapshotRewards
     */
    function claimVaultSnapshotRewards(
        address recipient,
        address network,
        address token,
        address vault,
        uint256 lastUnclaimedRewards,
        uint256 firstRewardToClaim,
        uint256 maxRewards,
        bytes[] calldata activeSharesHints
    ) public {
        if (recipient == address(0)) {
            revert InvalidRecipient();
        }

        uint256 lastUnclaimedReward_ =
            _vaultSnapshotRewardsStorage()._lastUnclaimedReward[msg.sender][vault][network][token];
        if (lastUnclaimedRewards != lastUnclaimedReward_) {
            revert InvalidLastUnclaimedReward();
        }

        RewardDistribution[] storage rewardsByTokenNetwork =
            _vaultSnapshotRewardsStorage()._rewards[vault][network][token];

        uint256 rewardIndex = firstRewardToClaim > 0 ? firstRewardToClaim : lastUnclaimedReward_;

        uint256 rewardsToClaim = Math.min(maxRewards, rewardsByTokenNetwork.length - rewardIndex);

        if (rewardsToClaim == 0) {
            revert NoRewardsToClaim();
        }

        uint256 amount;
        uint256 activeSharesHintsLength = activeSharesHints.length;
        for (uint256 i; i < rewardsToClaim; ++i) {
            RewardDistribution storage reward = rewardsByTokenNetwork[rewardIndex];

            amount += IVault(vault)
                .activeSharesOfAt(
                    msg.sender, reward.timestamp, activeSharesHintsLength > 0 ? activeSharesHints[i] : new bytes(0)
                ).mulDiv(reward.amount, _vaultSnapshotRewardsStorage()._activeSharesCache[vault][reward.timestamp]);

            ++rewardIndex;
        }

        _vaultSnapshotRewardsStorage()._lastUnclaimedReward[msg.sender][vault][network][token] = rewardIndex;

        if (amount > 0) {
            IERC20(token).safeTransfer(recipient, amount);
        }

        emit ClaimVaultSnapshotRewards(msg.sender, network, token, vault, amount, lastUnclaimedReward_);
    }

    /**
     * @inheritdoc IVaultSnapshotRewards
     */
    function claimCuratorFee(
        address recipient,
        address vault,
        address token
    ) public {
        if (ICuratorRegistry(CURATOR_REGISTRY).getCurator(vault) != msg.sender) {
            revert NotCurator();
        }

        uint256 claimableFee = _vaultSnapshotRewardsStorage()._curatorFees[vault][token];
        if (claimableFee == 0) {
            revert NoRewardsToClaim();
        }

        _vaultSnapshotRewardsStorage()._curatorFees[vault][token] = 0;
        IERC20(token).safeTransfer(recipient, claimableFee);

        emit ClaimCuratorFee(vault, token, claimableFee);
    }

    /**
     * @inheritdoc IVaultSnapshotRewards
     */
    function claimOperatorFee(
        address recipient,
        address network,
        address token,
        address vault,
        uint256 lastUnclaimedRewards,
        uint256 firstRewardToClaim,
        uint256 maxRewards,
        bytes calldata extraData
    ) public {
        if (recipient == address(0)) {
            revert InvalidRecipient();
        }

        // Check lastUnclaimedRewards vs on-chain for reorgs
        uint256 lastUnclaimedReward_ =
            _vaultSnapshotRewardsStorage()._lastUnclaimedOperatorReward[msg.sender][vault][network][token];
        if (lastUnclaimedRewards != lastUnclaimedReward_) {
            revert InvalidHintsLength(); // Reusing error
        }

        RewardDistribution[] storage rewardsByTokenNetwork =
            _vaultSnapshotRewardsStorage()._rewards[vault][network][token];

        uint256 rewardIndex = firstRewardToClaim > 0 ? firstRewardToClaim : lastUnclaimedReward_;
        if (rewardIndex > rewardsByTokenNetwork.length) {
            revert NoRewardsToClaim();
        }

        uint256 rewardsToClaim = Math.min(maxRewards, rewardsByTokenNetwork.length - rewardIndex);

        if (rewardsToClaim == 0) {
            revert NoRewardsToClaim();
        }

        (bytes[] memory operatorNetworkSharesHints, bytes memory totalOperatorNetworkSharesHint) =
            abi.decode(extraData, (bytes[], bytes));
        uint256 amount;

        for (uint256 i; i < rewardsToClaim; ++i) {
            RewardDistribution storage reward = rewardsByTokenNetwork[rewardIndex];

            if (reward.delegatorType == 0) {
                amount += INetworkRestakeDelegator(reward.delegator)
                    .operatorNetworkSharesAt(
                        Subnetwork.subnetwork(network, reward.subnetworkId),
                        msg.sender,
                        reward.timestamp,
                        operatorNetworkSharesHints[i]
                    )
                    .mulDiv(
                        reward.operatorsFee,
                        INetworkRestakeDelegator(reward.delegator)
                            .totalOperatorNetworkSharesAt(
                                Subnetwork.subnetwork(network, reward.subnetworkId),
                                reward.timestamp,
                                totalOperatorNetworkSharesHint
                            )
                    );
            } else if (reward.delegatorType == 1) {
                revert InvalidDelegatorType();
            } else if (reward.delegatorType == 2) {
                if (IOperatorSpecificDelegator(reward.delegator).operator() != msg.sender) {
                    revert NotOperator();
                }
                amount += reward.operatorsFee;
            } else if (reward.delegatorType == 3) {
                if (IOperatorNetworkSpecificDelegator(reward.delegator).operator() != msg.sender) {
                    revert NotOperator();
                }
                amount += reward.operatorsFee;
            } else {
                revert InvalidDelegatorType();
            }

            ++rewardIndex;
        }

        _vaultSnapshotRewardsStorage()._lastUnclaimedOperatorReward[msg.sender][vault][network][token] = rewardIndex;

        if (amount > 0) {
            IERC20(token).safeTransfer(recipient, amount);
        }

        emit ClaimOperatorFee(msg.sender, network, token, vault, amount, lastUnclaimedReward_);
    }

    /**
     * @inheritdoc IVaultSnapshotRewards
     */
    function claimRewards(
        address recipient,
        address token,
        bytes calldata data
    ) public virtual {
        // Decode data: network (32 bytes) + vault (32 bytes) + other parameters
        address network;
        address vault;
        uint256 lastUnclaimedRewards;
        uint256 firstRewardToClaim;
        uint256 maxRewards;
        bytes[] calldata activeSharesOfHints;
        assembly {
            network := calldataload(data.offset)
            vault := calldataload(add(data.offset, 0x20))
            lastUnclaimedRewards := calldataload(add(data.offset, 0x40))
            firstRewardToClaim := calldataload(add(data.offset, 0x60))
            maxRewards := calldataload(add(data.offset, 0x80))
            activeSharesOfHints.length := calldataload(add(data.offset, 0xA0))
            activeSharesOfHints.offset := add(data.offset, 0xC0)
        }
        claimVaultSnapshotRewards(
            recipient, network, token, vault, lastUnclaimedRewards, firstRewardToClaim, maxRewards, activeSharesOfHints
        );
    }
}
