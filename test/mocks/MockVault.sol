// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";
import {IBaseDelegator} from "@symbioticfi/core/src/interfaces/delegator/IBaseDelegator.sol";

/**
 * @title MockVault
 * @notice Mock implementation of IVault for testing VaultSnapshotRewards
 */
contract MockVault is IVault {
    address public immutable override collateral;
    address public immutable override delegator;
    address public immutable override burner;
    address public immutable vaultOwner;

    mapping(uint48 => uint256) internal _activeSharesAt;
    mapping(address => mapping(uint48 => uint256)) internal _activeSharesOfAt;

    constructor(
        address _collateral,
        address _delegator,
        address _burner
    ) {
        collateral = _collateral;
        delegator = _delegator;
        burner = _burner;
        vaultOwner = _collateral; // Use collateral address as owner for testing
    }

    // Set active shares for a timestamp (for testing)
    function setActiveSharesAt(
        uint48 timestamp,
        uint256 shares
    ) external {
        _activeSharesAt[timestamp] = shares;
    }

    // Set active shares for an account at a timestamp (for testing)
    function setActiveSharesOfAt(
        address account,
        uint48 timestamp,
        uint256 shares
    ) external {
        _activeSharesOfAt[account][timestamp] = shares;
    }

    // Implement required IVault methods
    function activeSharesAt(
        uint48 timestamp,
        bytes memory
    ) external view override returns (uint256) {
        return _activeSharesAt[timestamp];
    }

    function activeSharesOfAt(
        address account,
        uint48 timestamp,
        bytes memory
    ) external view override returns (uint256) {
        return _activeSharesOfAt[account][timestamp];
    }

    // Stub implementations for other required interface methods
    function DEPOSIT_WHITELIST_SET_ROLE() external pure returns (bytes32) {
        return bytes32(0);
    }

    function DEPOSITOR_WHITELIST_ROLE() external pure returns (bytes32) {
        return bytes32(0);
    }

    function IS_DEPOSIT_LIMIT_SET_ROLE() external pure returns (bytes32) {
        return bytes32(0);
    }

    function DEPOSIT_LIMIT_SET_ROLE() external pure returns (bytes32) {
        return bytes32(0);
    }

    function DELEGATOR_FACTORY() external pure returns (address) {
        return address(0);
    }

    function SLASHER_FACTORY() external pure returns (address) {
        return address(0);
    }

    function isDelegatorInitialized() external pure returns (bool) {
        return true;
    }

    function slasher() external pure returns (address) {
        return address(0);
    }

    function isSlasherInitialized() external pure returns (bool) {
        return false;
    }

    function epochDurationInit() external pure returns (uint48) {
        return 0;
    }

    function epochDuration() external pure returns (uint48) {
        return 86_400;
    }

    function epochAt(
        uint48
    ) external pure returns (uint256) {
        return 0;
    }

    function currentEpoch() external pure returns (uint256) {
        return 0;
    }

    function currentEpochStart() external pure returns (uint48) {
        return 0;
    }

    function previousEpochStart() external pure returns (uint48) {
        return 0;
    }

    function nextEpochStart() external pure returns (uint48) {
        return 0;
    }

    function depositWhitelist() external pure returns (bool) {
        return false;
    }

    function isDepositorWhitelisted(
        address
    ) external pure returns (bool) {
        return true;
    }

    function isDepositLimit() external pure returns (bool) {
        return false;
    }

    function depositLimit() external pure returns (uint256) {
        return 0;
    }

    function activeShares() external pure returns (uint256) {
        return 0;
    }

    function activeStakeAt(
        uint48,
        bytes memory
    ) external pure returns (uint256) {
        return 0;
    }

    function activeStake() external pure returns (uint256) {
        return 0;
    }

    function activeSharesOf(
        address
    ) external pure returns (uint256) {
        return 0;
    }

    function withdrawals(
        uint256
    ) external pure returns (uint256) {
        return 0;
    }

    function withdrawalShares(
        uint256
    ) external pure returns (uint256) {
        return 0;
    }

    function withdrawalSharesOf(
        uint256,
        address
    ) external pure returns (uint256) {
        return 0;
    }

    function isWithdrawalsClaimed(
        uint256,
        address
    ) external pure returns (bool) {
        return false;
    }

    function activeBalanceOfAt(
        address,
        uint48,
        bytes memory
    ) external pure returns (uint256) {
        return 0;
    }

    function activeBalanceOf(
        address
    ) external pure returns (uint256) {
        return 0;
    }

    function withdrawalsOf(
        uint256,
        address
    ) external pure returns (uint256) {
        return 0;
    }

    function slashableBalanceOf(
        address
    ) external pure returns (uint256) {
        return 0;
    }

    function totalStake() external pure returns (uint256) {
        return 0;
    }

    // Stub implementations for IVault methods
    function deposit(
        address,
        uint256
    ) external pure returns (uint256, uint256) {
        return (0, 0);
    }
    function withdraw(
        uint256
    ) external pure {}

    function claimWithdrawals(
        uint256,
        address
    ) external pure returns (uint256) {
        return 0;
    }

    function redeem(
        uint256,
        address
    ) external pure returns (uint256) {
        return 0;
    }

    function onSlash(
        uint256,
        uint48
    ) external pure returns (uint256) {
        return 0;
    }
    function setDepositWhitelist(
        bool
    ) external pure {}
    function setDepositorWhitelistStatus(
        address,
        bool
    ) external pure {}
    function setIsDepositLimit(
        bool
    ) external pure {}
    function setDepositLimit(
        uint256
    ) external pure {}
    function setDelegator(
        address
    ) external pure {}
    function setSlasher(
        address
    ) external pure {}

    // Stub implementations for IMigratableEntity methods
    function FACTORY() external pure returns (address) {
        return address(0);
    }

    function version() external pure returns (uint64) {
        return 1;
    }
    function initialize(
        uint64,
        address,
        bytes calldata
    ) external pure {}
    function migrate(
        uint64,
        bytes calldata
    ) external pure {}

    function migrator() external pure returns (address) {
        return address(0);
    }
    function setMigrator(
        address
    ) external pure {}

    // Stub implementations for IEntity methods
    function owner() external view returns (address) {
        return vaultOwner;
    }
    function transferOwnership(
        address
    ) external pure {}
    function renounceOwnership() external pure {}
    function setEntityConfig(
        bytes32,
        bytes memory
    ) external pure {}

    function entityConfig(
        bytes32
    ) external pure returns (bytes memory) {
        return "";
    }

    function entityConfigKeys() external pure returns (bytes32[] memory) {
        return new bytes32[](0);
    }

    // Additional missing IVault methods
    function isInitialized() external pure returns (bool) {
        return true;
    }

    function claim(
        address,
        uint256
    ) external pure returns (uint256) {
        return 0;
    }

    function claimBatch(
        address,
        uint256[] calldata
    ) external pure returns (uint256) {
        return 0;
    }

    function redeem(
        address,
        uint256
    ) external pure returns (uint256, uint256) {
        return (0, 0);
    }

    function withdraw(
        address,
        uint256
    ) external pure returns (uint256, uint256) {
        return (0, 0);
    }
}
