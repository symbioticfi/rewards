// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {FeeRegistry} from "./FeeRegistry.sol";
import {ProtocolFees} from "./ProtocolFees.sol";

import {ICuratorRegistry} from "../../interfaces/rewardsV2/ICuratorRegistry.sol";
import {IFeeRegistry} from "../../interfaces/rewardsV2/IFeeRegistry.sol";
import {IVaultSnapshotRewards} from "../../interfaces/rewardsV2/IVaultSnapshotRewards.sol";

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


abstract contract VaultSnapshotRewards is ProtocolFees, IVaultSnapshotRewards {
    using SafeERC20 for IERC20;
    using Math for uint256;
    using Subnetwork for bytes32;

    /* CONSTANTS */

    uint64 constant REWARDS_TYPE_VAULT_SNAPSHOT = 1;

    /* STRUCTS */

    /**
     * @notice Storage structure for vault snapshot rewards
     */
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

    /* STORAGE */

    // keccak256(abi.encode(uint256(keccak256("symbiotic.rewards.VaultSnapshotRewards")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant VAULT_SNAPSHOT_REWARDS_STORAGE_POSITION =
        0xea7ec811d4da20f680ecf87dbad2b956cc74e833cd99b5f63865df6b3d6b6800;

    address public immutable VAULT_FACTORY;
    address public immutable NETWORK_REGISTRY;
    address public immutable NETWORK_MIDDLEWARE_SERVICE;
    address public immutable CURATOR_REGISTRY;
    address public immutable FEE_REGISTRY;

    /* FUNCTIONS */

    constructor(
        address vaultFactory,
        address networkRegistry,
        address networkMiddlewareService,
        address curatorRegistry,
        address feeRegistry
    ) {
        VAULT_FACTORY = vaultFactory;
        NETWORK_REGISTRY = networkRegistry;
        NETWORK_MIDDLEWARE_SERVICE = networkMiddlewareService;
        CURATOR_REGISTRY = curatorRegistry;
        FEE_REGISTRY = feeRegistry;
    }

    function __VaultSnapshotRewards_init(
        VaultSnapshotRewardsInitParams calldata initParams
    ) internal onlyInitializing {
        __ProtocolFees_init(initParams.protocolFeesInitParams);
    }

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
        bytes calldata activeSharesHint,
        bytes calldata activeStakeHint
    ) public {
        // Check authorization - either network middleware or network itself
        address network = subnetwork.network();
        if (
            network != msg.sender
                && INetworkMiddlewareService(NETWORK_MIDDLEWARE_SERVICE).middleware(network) != msg.sender
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
            uint256 activeStake = IVault(vault).activeStakeAt(timestamp, activeStakeHint);

            if (activeShares == 0 || activeStake == 0) {
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

        uint256 maxFee = FeeRegistry(FEE_REGISTRY).MAX_FEE();
        // Get curator fee from FeeRegistry
        uint256 curatorFee = IFeeRegistry(FEE_REGISTRY).getCuratorFee(vault, network);
        uint256 curatorFeeAmount = amount.mulDiv(curatorFee, maxFee); // Assuming 10000 as base

        // Get operators fee from FeeRegistry
        uint256 operatorsFee = IFeeRegistry(FEE_REGISTRY).getOperatorsFee(vault, network);
        uint256 operatorsFeeAmount = amount.mulDiv(operatorsFee, maxFee);

        // Deduct protocol fees from the remaining amount
        uint256 protocolFees = _deductProtocolFees(REWARDS_TYPE_VAULT_SNAPSHOT, network, token, amount);

        // Calculate final distribution amount
        uint256 distributeAmount = amount - curatorFeeAmount - operatorsFeeAmount - protocolFees;

        // Update curator fees
        _vaultSnapshotRewardsStorage()._curatorFees[vault][token] += curatorFeeAmount;

        // Store reward distribution
        _vaultSnapshotRewardsStorage()._rewards[vault][network][token]
        .push(
            RewardDistribution({
                subnetworkId: uint96(uint256(subnetwork)),
                timestamp: timestamp,
                amount: distributeAmount,
                operatorsFee: operatorsFeeAmount
            })
        );

        emit DistributeVaultSnapshotRewards(
            msg.sender,
            token,
            vault,
            uint96(uint256(subnetwork)),
            timestamp,
            distributeAmount,
            curatorFeeAmount,
            operatorsFeeAmount
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
        bytes[] memory activeSharesOfHints
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

        uint256 startIndex = firstRewardToClaim > 0 ? firstRewardToClaim : lastUnclaimedReward_;
        if (startIndex > rewardsByTokenNetwork.length) {
            revert NoRewardsToClaim();
        }

        uint256 rewardsToClaim = Math.min(maxRewards, rewardsByTokenNetwork.length - startIndex);

        if (rewardsToClaim == 0) {
            revert NoRewardsToClaim();
        }

        bytes[] memory hints = activeSharesOfHints;
        if (hints.length == 0) {
            hints = new bytes[](rewardsToClaim);
        } else if (hints.length != rewardsToClaim) {
            revert InvalidHintsLength();
        }

        uint256 amount;
        uint256 rewardIndex = startIndex;
        for (uint256 i; i < rewardsToClaim; ++i) {
            RewardDistribution storage reward = rewardsByTokenNetwork[rewardIndex];

            amount += IVault(vault).activeSharesOfAt(msg.sender, reward.timestamp, hints[i])
                .mulDiv(reward.amount, _vaultSnapshotRewardsStorage()._activeSharesCache[vault][reward.timestamp]);

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
        address curator = ICuratorRegistry(CURATOR_REGISTRY).getCurator(vault);
        if (curator != msg.sender) {
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

        uint256 startIndex = firstRewardToClaim > 0 ? firstRewardToClaim : lastUnclaimedReward_;
        if (startIndex > rewardsByTokenNetwork.length) {
            revert NoRewardsToClaim();
        }

        uint256 rewardsToClaim = Math.min(maxRewards, rewardsByTokenNetwork.length - startIndex);

        if (rewardsToClaim == 0) {
            revert NoRewardsToClaim();
        }

        address delegatorAddress = IVault(vault).delegator();
        uint64 delegatorType = IBaseDelegator(delegatorAddress).TYPE();
        uint256 amount;
        uint256 rewardIndex = startIndex;

        for (uint256 i; i < rewardsToClaim; ++i) {
            RewardDistribution storage reward = rewardsByTokenNetwork[rewardIndex];

            if (delegatorType == 0) {
                // Type 0: pro-rata based on operatorNetworkShares / totalOperatorNetworkShares
                (uint256[] memory operatorNetworkShares, uint256 totalOperatorNetworkShares) =
                    abi.decode(extraData, (uint256[], uint256));
                if (i < operatorNetworkShares.length) {
                    amount += operatorNetworkShares[i].mulDiv(reward.operatorsFee, totalOperatorNetworkShares);
                }
            } else if (delegatorType == 1) {
                revert InvalidDelegatorType();
            } else if (delegatorType == 2) {
                if (IOperatorSpecificDelegator(delegatorAddress).operator() != msg.sender) {
                    revert NotOperator();
                }
                amount += reward.operatorsFee;
            } else if (delegatorType == 3) {
                if (IOperatorNetworkSpecificDelegator(delegatorAddress).operator() != msg.sender) {
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
        (
            address network,
            address vault,
            uint256 lastUnclaimedRewards,
            uint256 firstRewardToClaim,
            uint256 maxRewards,
            bytes[] memory activeSharesOfHints
        ) = abi.decode(data, (address, address, uint256, uint256, uint256, bytes[]));

        claimVaultSnapshotRewards(
            recipient, network, token, vault, lastUnclaimedRewards, firstRewardToClaim, maxRewards, activeSharesOfHints
        );
    }

    /* INTERNAL FUNCTIONS */

    /**
     * @notice Get the vault snapshot rewards storage
     * @return $ The storage struct
     */
    function _vaultSnapshotRewardsStorage() private pure returns (VaultSnapshotRewardsStorage storage $) {
        assembly {
            $.slot := VAULT_SNAPSHOT_REWARDS_STORAGE_POSITION
        }
    }
}
