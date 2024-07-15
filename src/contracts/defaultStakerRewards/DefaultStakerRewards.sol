// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IDefaultStakerRewards} from "src/interfaces/defaultStakerRewards/IDefaultStakerRewards.sol";
import {INetworkMiddlewareService} from "@symbiotic/interfaces/service/INetworkMiddlewareService.sol";
import {IRegistry} from "@symbiotic/interfaces/common/IRegistry.sol";
import {IStakerRewards} from "src/interfaces/stakerRewards/IStakerRewards.sol";
import {IVault} from "@symbiotic/interfaces/vault/IVault.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Time} from "@openzeppelin/contracts/utils/types/Time.sol";

contract DefaultStakerRewards is AccessControlUpgradeable, ReentrancyGuardUpgradeable, IDefaultStakerRewards {
    using SafeERC20 for IERC20;
    using Math for uint256;

    /**
     * @inheritdoc IStakerRewards
     */
    uint64 public constant version = 1;

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    uint256 public constant ADMIN_FEE_BASE = 10_000;

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    bytes32 public constant ADMIN_FEE_CLAIM_ROLE = keccak256("ADMIN_FEE_CLAIM_ROLE");

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    bytes32 public constant NETWORK_WHITELIST_ROLE = keccak256("NETWORK_WHITELIST_ROLE");

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    bytes32 public constant ADMIN_FEE_SET_ROLE = keccak256("ADMIN_FEE_SET_ROLE");

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    address public immutable VAULT_FACTORY;

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    address public immutable NETWORK_REGISTRY;

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    address public immutable NETWORK_MIDDLEWARE_SERVICE;

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    address public VAULT;

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    uint256 public adminFee;

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    mapping(address account => bool values) public isNetworkWhitelisted;

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    mapping(address token => RewardDistribution[] rewards_) public rewards;

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    mapping(address account => mapping(address token => uint256 rewardIndex)) public lastUnclaimedReward;

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    mapping(address token => uint256 amount) public claimableAdminFee;

    mapping(uint48 timestamp => uint256 amount) private _activeSharesCache;

    constructor(address vaultFactory, address networkRegistry, address networkMiddlewareService) {
        _disableInitializers();

        VAULT_FACTORY = vaultFactory;
        NETWORK_REGISTRY = networkRegistry;
        NETWORK_MIDDLEWARE_SERVICE = networkMiddlewareService;
    }

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    function rewardsLength(address token) external view returns (uint256) {
        return rewards[token].length;
    }

    /**
     * @inheritdoc IStakerRewards
     */
    function claimable(
        address token,
        address account,
        bytes calldata data
    ) external view override returns (uint256 amount) {
        // maxRewards - maximum amount of rewards to process
        uint256 maxRewards = abi.decode(data, (uint256));

        RewardDistribution[] storage rewardsByToken = rewards[token];
        uint256 rewardIndex = lastUnclaimedReward[account][token];

        uint256 rewardsToClaim = Math.min(maxRewards, rewardsByToken.length - rewardIndex);

        for (uint256 i; i < rewardsToClaim;) {
            RewardDistribution storage reward = rewardsByToken[rewardIndex];

            amount += IVault(VAULT).activeSharesOfAt(account, reward.timestamp, new bytes(0)).mulDiv(
                reward.amount, _activeSharesCache[reward.timestamp]
            );

            unchecked {
                ++i;
                ++rewardIndex;
            }
        }
    }

    function initialize(InitParams calldata params) external initializer {
        if (!IRegistry(VAULT_FACTORY).isEntity(params.vault)) {
            revert NotVault();
        }

        __ReentrancyGuard_init();

        VAULT = params.vault;

        _setAdminFee(params.adminFee);

        if (params.defaultAdminRoleHolder == address(0)) {
            if (params.networkWhitelistRoleHolder == address(0)) {
                revert MissingRoleHolders();
            }
            if (adminFee != 0 && params.adminFeeClaimRoleHolder == address(0)) {
                revert MissingRoleHolders();
            }
        }

        if (params.defaultAdminRoleHolder != address(0)) {
            _grantRole(DEFAULT_ADMIN_ROLE, params.defaultAdminRoleHolder);
        }
        if (params.adminFeeClaimRoleHolder != address(0)) {
            _grantRole(ADMIN_FEE_CLAIM_ROLE, params.adminFeeClaimRoleHolder);
        }
        if (params.networkWhitelistRoleHolder != address(0)) {
            _grantRole(NETWORK_WHITELIST_ROLE, params.networkWhitelistRoleHolder);
        }
        if (params.adminFeeSetRoleHolder != address(0)) {
            _grantRole(ADMIN_FEE_SET_ROLE, params.adminFeeSetRoleHolder);
        }
    }

    /**
     * @inheritdoc IStakerRewards
     */
    function distributeRewards(
        address network,
        address token,
        uint256 amount,
        bytes calldata data
    ) external override nonReentrant {
        // timestamp - time point stakes must be taken into account at
        uint48 timestamp = abi.decode(data, (uint48));

        if (INetworkMiddlewareService(NETWORK_MIDDLEWARE_SERVICE).middleware(network) != msg.sender) {
            revert NotNetworkMiddleware();
        }

        if (!isNetworkWhitelisted[network]) {
            revert NotWhitelistedNetwork();
        }

        if (timestamp >= Time.timestamp()) {
            revert InvalidRewardTimestamp();
        }

        if (_activeSharesCache[timestamp] == 0) {
            uint256 activeShares_ = IVault(VAULT).activeSharesAt(timestamp, new bytes(0));
            uint256 activeStake_ = IVault(VAULT).activeStakeAt(timestamp, new bytes(0));

            if (activeShares_ == 0 || activeStake_ == 0) {
                revert InvalidRewardTimestamp();
            }

            _activeSharesCache[timestamp] = activeShares_;
        }

        uint256 balanceBefore = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        amount = IERC20(token).balanceOf(address(this)) - balanceBefore;

        if (amount == 0) {
            revert InsufficientReward();
        }

        uint256 adminFeeAmount = amount.mulDiv(adminFee, ADMIN_FEE_BASE);
        uint256 distributeAmount = amount - adminFeeAmount;

        claimableAdminFee[token] += adminFeeAmount;

        if (distributeAmount > 0) {
            rewards[token].push(
                RewardDistribution({
                    network: network,
                    amount: distributeAmount,
                    timestamp: timestamp,
                    creation: Time.timestamp()
                })
            );
        }

        emit DistributeRewards(network, token, amount, data);
    }

    /**
     * @inheritdoc IStakerRewards
     */
    function claimRewards(address recipient, address token, bytes calldata data) external override {
        // maxRewards - maximum amount of rewards to process
        // activeSharesOfHints - hint indexes to optimize `activeSharesOf()` processing
        (uint256 maxRewards, bytes[] memory activeSharesOfHints) = abi.decode(data, (uint256, bytes[]));

        if (recipient == address(0)) {
            revert InvalidRecipient();
        }

        RewardDistribution[] storage rewardsByToken = rewards[token];
        uint256 rewardIndex = lastUnclaimedReward[msg.sender][token];

        uint256 rewardsToClaim = Math.min(maxRewards, rewardsByToken.length - rewardIndex);

        if (rewardsToClaim == 0) {
            revert NoRewardsToClaim();
        }

        if (activeSharesOfHints.length != rewardsToClaim) {
            revert InvalidHintsLength();
        }

        uint256 amount;
        for (uint256 i; i < rewardsToClaim;) {
            RewardDistribution storage reward = rewardsByToken[rewardIndex];

            uint256 claimedAmount = IVault(VAULT).activeSharesOfAt(msg.sender, reward.timestamp, activeSharesOfHints[i])
                .mulDiv(reward.amount, _activeSharesCache[reward.timestamp]);
            amount += claimedAmount;

            emit ClaimRewards(token, rewardIndex, msg.sender, recipient, claimedAmount);

            unchecked {
                ++i;
                ++rewardIndex;
            }
        }

        lastUnclaimedReward[msg.sender][token] = rewardIndex;

        if (amount > 0) {
            IERC20(token).safeTransfer(recipient, amount);
        }
    }

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    function claimAdminFee(address recipient, address token) external onlyRole(ADMIN_FEE_CLAIM_ROLE) {
        uint256 claimableAdminFee_ = claimableAdminFee[token];
        if (claimableAdminFee_ == 0) {
            revert InsufficientAdminFee();
        }

        claimableAdminFee[token] = 0;

        IERC20(token).safeTransfer(recipient, claimableAdminFee_);

        emit ClaimAdminFee(token, claimableAdminFee_);
    }

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    function setNetworkWhitelistStatus(address network, bool status) external onlyRole(NETWORK_WHITELIST_ROLE) {
        if (!IRegistry(NETWORK_REGISTRY).isEntity(network)) {
            revert NotNetwork();
        }

        if (isNetworkWhitelisted[network] == status) {
            revert AlreadySet();
        }

        isNetworkWhitelisted[network] = status;

        emit SetNetworkWhitelistStatus(network, status);
    }

    /**
     * @inheritdoc IDefaultStakerRewards
     */
    function setAdminFee(uint256 adminFee_) external onlyRole(ADMIN_FEE_SET_ROLE) {
        if (adminFee == adminFee_) {
            revert AlreadySet();
        }

        _setAdminFee(adminFee_);

        emit SetAdminFee(adminFee_);
    }

    function _setAdminFee(uint256 adminFee_) private {
        if (adminFee_ > ADMIN_FEE_BASE) {
            revert InvalidAdminFee();
        }

        adminFee = adminFee_;
    }
}
