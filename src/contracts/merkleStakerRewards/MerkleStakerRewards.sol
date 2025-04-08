// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IStakerRewards} from "../../interfaces/stakerRewards/IStakerRewards.sol";

import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";
import {IRegistry} from "@symbioticfi/core/src/interfaces/common/IRegistry.sol";
import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MulticallUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Time} from "@openzeppelin/contracts/utils/types/Time.sol";
import {IMerkleStakerRewards} from "../../interfaces/merkleStakerRewards/IMerkleStakerRewards.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract DefaultStakerRewards is
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    MulticallUpgradeable,
    IMerkleStakerRewards
{
    using SafeERC20 for IERC20;
    using Math for uint256;

    /**
     * @inheritdoc IStakerRewards
     */
    uint64 public constant version = 1;

    /**
     * @inheritdoc IMerkleStakerRewards
     */
    bytes32 public constant ROOT_UPDATER_ROLE = keccak256("ROOT_UPDATER_ROLE");

    /**
     * @inheritdoc IMerkleStakerRewards
     */
    bytes32 public constant DELAY_SET_ROLE = keccak256("DELAY_SET_ROLE");

    /**
     * @inheritdoc IMerkleStakerRewards
     */
    address public immutable VAULT_FACTORY;

    /**
     * @inheritdoc IMerkleStakerRewards
     */
    address public immutable NETWORK_MIDDLEWARE_SERVICE;

    /**
     * @inheritdoc IMerkleStakerRewards
     */
    address public VAULT;

    /**
     * @inheritdoc IMerkleStakerRewards
     */
    bytes32 public root;

    /**
     * @inheritdoc IMerkleStakerRewards
     */
    PendingRoot public pendingRoot;

    /**
     * @inheritdoc IMerkleStakerRewards
     */
    uint256 public delay;

    /**
     * @inheritdoc IMerkleStakerRewards
     */
    mapping(address account => mapping(address token => uint256 amount))
        public claimed;

    /**
     * @inheritdoc IMerkleStakerRewards
     */
    mapping(address token => mapping(address network => RewardDistribution[] rewards_))
        public rewards;

    constructor(address vaultFactory, address networkMiddlewareService) {
        _disableInitializers();

        VAULT_FACTORY = vaultFactory;
        NETWORK_MIDDLEWARE_SERVICE = networkMiddlewareService;
    }

    /**
     * @inheritdoc IStakerRewards
     */
    function claimable(
        address token,
        address account,
        bytes calldata data
    ) external view override returns (uint256 amount) {
        // tootalClaimable - the total claimable amount of token rewards for account
        // proof - the merkle proof to verify the claimable amount
        (uint256 totalClaimable, bytes32[] memory proof) = abi.decode(
            data,
            (uint256, bytes32[])
        );

        if (root == bytes32(0)) {
            return 0;
        }

        if (
            !MerkleProof.verify(
                proof,
                root,
                keccak256(
                    bytes.concat(
                        keccak256(abi.encode(account, token, totalClaimable))
                    )
                )
            )
        ) {
            revert InvalidProof();
        }

        uint256 claimed_ = claimed[account][token];
        if (totalClaimable <= claimed_) {
            return 0;
        }

        amount = totalClaimable - claimed_;
    }

    function initialize(InitParams calldata params) external initializer {
        if (!IRegistry(VAULT_FACTORY).isEntity(params.vault)) {
            revert NotVault();
        }

        if (params.defaultAdminRoleHolder == address(0)) {
            revert MissingRoles();
        }

        __ReentrancyGuard_init();

        VAULT = params.vault;

        _setDelay(params.delay);
        if (params.root != bytes32(0)) {
            _setRoot(params.root);
        }

        _grantRole(DEFAULT_ADMIN_ROLE, params.defaultAdminRoleHolder);
        if (params.rootUpdaterRoleHolder != address(0)) {
            _grantRole(ROOT_UPDATER_ROLE, params.rootUpdaterRoleHolder);
        }
        if (params.delaySetRoleHolder != address(0)) {
            _grantRole(DELAY_SET_ROLE, params.delaySetRoleHolder);
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
        // timestamp - a time point stakes must be taken into account at
        uint48 timestamp = abi.decode(data, (uint48));

        if (
            INetworkMiddlewareService(NETWORK_MIDDLEWARE_SERVICE).middleware(
                network
            ) != msg.sender
        ) {
            revert NotNetworkMiddleware();
        }

        if (timestamp >= Time.timestamp()) {
            revert InvalidRewardTimestamp();
        }

        uint256 balanceBefore = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        unchecked {
            amount = IERC20(token).balanceOf(address(this)) - balanceBefore;
        }

        if (amount == 0) {
            revert InsufficientReward();
        }

        rewards[token][network].push(
            RewardDistribution({amount: amount, timestamp: timestamp})
        );

        emit DistributeRewards(network, token, amount, data);
    }

    /**
     * @inheritdoc IStakerRewards
     */
    function claimRewards(
        address account,
        address token,
        bytes calldata data
    ) external override nonReentrant {
        // totalClaimable - the total claimable amount of token rewards for account
        // proof - the merkle proof to verify the claimable amount
        (uint256 totalClaimable, bytes32[] memory proof) = abi.decode(
            data,
            (uint256, bytes32[])
        );

        if (root == bytes32(0)) {
            revert RootNotSet();
        }

        if (
            !MerkleProof.verify(
                proof,
                root,
                keccak256(
                    bytes.concat(
                        keccak256(abi.encode(account, token, totalClaimable))
                    )
                )
            )
        ) {
            revert InvalidProof();
        }

        uint256 claimed_ = claimed[account][token];
        if (totalClaimable <= claimed_) {
            revert InsufficientTotalClaimable();
        }

        uint256 amount = totalClaimable - claimed_;
        claimed[account][token] = totalClaimable;
        IERC20(token).safeTransfer(account, amount);
        emit Claimed(account, token, amount);
    }
    /**
     * @inheritdoc IMerkleStakerRewards
     */

    function submitRoot(bytes32 newRoot) external onlyRole(ROOT_UPDATER_ROLE) {
        if (pendingRoot.root == newRoot) {
            revert AlreadySet();
        }

        pendingRoot = PendingRoot({
            root: newRoot,
            timestamp: Time.timestamp() + delay
        });

        emit SubmitRoot(newRoot);
    }

    /**
     * @inheritdoc IMerkleStakerRewards
     */
    function acceptRoot() external {
        if (pendingRoot.timestamp == 0) {
            revert NoPendingRoot();
        }
        if (pendingRoot.timestamp > Time.timestamp()) {
            revert NotReady();
        }

        _setRoot(pendingRoot.root);
    }
    /**
     * @inheritdoc IMerkleStakerRewards
     */

    function setDelay(uint256 newDelay) external onlyRole(DELAY_SET_ROLE) {
        if (delay == newDelay) {
            revert AlreadySet();
        }

        _setDelay(newDelay);
    }

    function _setRoot(bytes32 newRoot) internal {
        root = newRoot;
        delete pendingRoot;
        emit SetRoot(newRoot);
    }

    function _setDelay(uint256 newDelay) internal {
        delay = newDelay;
        emit SetDelay(newDelay);
    }
}
