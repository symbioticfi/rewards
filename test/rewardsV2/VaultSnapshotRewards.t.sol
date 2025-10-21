// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {RewardsV2TestBase} from "./RewardsV2TestBase.sol";

import {VaultSnapshotRewards} from "../../src/contracts/rewardsV2/VaultSnapshotRewards.sol";
import {CuratorRegistry} from "../../src/contracts/rewardsV2/CuratorRegistry.sol";
import {FeeRegistry} from "../../src/contracts/rewardsV2/FeeRegistry.sol";
import {IVaultSnapshotRewards} from "../../src/interfaces/rewardsV2/IVaultSnapshotRewards.sol";

import {Vault} from "@symbioticfi/core/src/contracts/vault/Vault.sol";
import {IVault} from "@symbioticfi/core/src/interfaces/vault/IVault.sol";
import {VaultFactory} from "@symbioticfi/core/src/contracts/VaultFactory.sol";
import {DelegatorFactory} from "@symbioticfi/core/src/contracts/DelegatorFactory.sol";
import {SlasherFactory} from "@symbioticfi/core/src/contracts/SlasherFactory.sol";
import {VaultConfigurator, IVaultConfigurator} from "@symbioticfi/core/src/contracts/VaultConfigurator.sol";
import {NetworkRegistry} from "@symbioticfi/core/src/contracts/NetworkRegistry.sol";
import {OperatorRegistry} from "@symbioticfi/core/src/contracts/OperatorRegistry.sol";
import {NetworkMiddlewareService} from "@symbioticfi/core/src/contracts/service/NetworkMiddlewareService.sol";
import {OptInService} from "@symbioticfi/core/src/contracts/service/OptInService.sol";

import {Subnetwork} from "@symbioticfi/core/src/contracts/libraries/Subnetwork.sol";
import {IBaseDelegator} from "@symbioticfi/core/src/interfaces/delegator/IBaseDelegator.sol";
import {INetworkRestakeDelegator} from "@symbioticfi/core/src/interfaces/delegator/INetworkRestakeDelegator.sol";
import {
    IOperatorNetworkSpecificDelegator
} from "@symbioticfi/core/src/interfaces/delegator/IOperatorNetworkSpecificDelegator.sol";
import {IOperatorSpecificDelegator} from "@symbioticfi/core/src/interfaces/delegator/IOperatorSpecificDelegator.sol";
import {IFullRestakeDelegator} from "@symbioticfi/core/src/interfaces/delegator/IFullRestakeDelegator.sol";

import {NetworkRestakeDelegator} from "@symbioticfi/core/src/contracts/delegator/NetworkRestakeDelegator.sol";
import {
    OperatorNetworkSpecificDelegator
} from "@symbioticfi/core/src/contracts/delegator/OperatorNetworkSpecificDelegator.sol";
import {OperatorSpecificDelegator} from "@symbioticfi/core/src/contracts/delegator/OperatorSpecificDelegator.sol";
import {FullRestakeDelegator} from "@symbioticfi/core/src/contracts/delegator/FullRestakeDelegator.sol";

/**
 * @title TestableVaultSnapshotRewards
 * @notice Concrete implementation of VaultSnapshotRewards for testing purposes
 */
contract TestableVaultSnapshotRewards is VaultSnapshotRewards {
    constructor(
        address vaultFactory,
        address networkRegistry,
        address networkMiddlewareService,
        address curatorRegistry,
        address feeRegistry
    ) VaultSnapshotRewards(vaultFactory, networkRegistry, networkMiddlewareService, curatorRegistry, feeRegistry) {}

    // Expose internal methods for testing
    function deductProtocolFees(
        uint64 rewardsType,
        address network,
        address rewardsToken,
        uint256 amount
    ) external returns (uint256 fees) {
        return _deductProtocolFees(rewardsType, network, rewardsToken, amount);
    }
}

contract VaultSnapshotRewardsTest is RewardsV2TestBase {
    TestableVaultSnapshotRewards vaultSnapshotRewards;
    Vault vault;
    Vault operatorSpecificVault;
    Vault operatorNetworkVault;
    Vault invalidDelegatorVault;

    DelegatorFactory delegatorFactory;
    SlasherFactory slasherFactory;
    VaultConfigurator vaultConfigurator;
    OperatorRegistry operatorRegistry;
    OptInService operatorVaultOptInService;
    OptInService operatorNetworkOptInService;

    NetworkRestakeDelegator networkRestakeDelegator;
    OperatorSpecificDelegator operatorSpecificDelegator;
    OperatorNetworkSpecificDelegator operatorNetworkSpecificDelegator;
    FullRestakeDelegator fullRestakeDelegator;

    address network;
    address curator;
    address staker;
    address operator;
    address otherOperator;
    address recipient;
    address middleware;

    // Test constants
    uint256 constant REWARD_AMOUNT = 1000 * 10 ** 18;
    uint48 TIMESTAMP;
    uint96 constant SUBNETWORK_ID = 0x123;
    uint64 constant NETWORK_RESTAKE_TYPE = 0;
    uint64 constant FULL_RESTAKE_TYPE = 1;
    uint64 constant OPERATOR_SPECIFIC_TYPE = 2;
    uint64 constant OPERATOR_NETWORK_SPECIFIC_TYPE = 3;

    function setUp() public {
        network = makeAddr("network");
        curator = makeAddr("curator");
        staker = makeAddr("staker");
        operator = makeAddr("operator");
        otherOperator = makeAddr("otherOperator");
        recipient = makeAddr("recipient");
        middleware = makeAddr("middleware");

        _deployRewardsInfra(address(this));

        uint256 allocation = 150_000 * 10 ** 18;
        rewardsToken.transfer(network, allocation);
        rewardsToken.transfer(middleware, allocation);
        rewardsToken.transfer(staker, allocation);
        rewardsToken.transfer(curator, allocation);
        rewardsToken.transfer(operator, allocation);
        rewardsToken.transfer(otherOperator, allocation);

        vaultFactory = new VaultFactory(address(this));
        delegatorFactory = new DelegatorFactory(address(this));
        slasherFactory = new SlasherFactory(address(this));
        networkRegistry = new NetworkRegistry();
        operatorRegistry = new OperatorRegistry();
        networkMiddlewareService = new NetworkMiddlewareService(address(networkRegistry));
        operatorVaultOptInService =
            new OptInService(address(operatorRegistry), address(vaultFactory), "OperatorVaultOptInService");
        operatorNetworkOptInService =
            new OptInService(address(operatorRegistry), address(networkRegistry), "OperatorNetworkOptInService");

        vm.prank(network);
        networkRegistry.registerNetwork();
        vm.prank(operator);
        operatorRegistry.registerOperator();
        vm.prank(otherOperator);
        operatorRegistry.registerOperator();

        address vaultImpl =
            address(new Vault(address(delegatorFactory), address(slasherFactory), address(vaultFactory)));
        vaultFactory.whitelist(vaultImpl);

        address networkRestakeDelegatorImpl = address(
            new NetworkRestakeDelegator(
                address(networkRegistry),
                address(vaultFactory),
                address(operatorVaultOptInService),
                address(operatorNetworkOptInService),
                address(delegatorFactory),
                delegatorFactory.totalTypes()
            )
        );
        delegatorFactory.whitelist(networkRestakeDelegatorImpl);

        address fullRestakeDelegatorImpl = address(
            new FullRestakeDelegator(
                address(networkRegistry),
                address(vaultFactory),
                address(operatorVaultOptInService),
                address(operatorNetworkOptInService),
                address(delegatorFactory),
                delegatorFactory.totalTypes()
            )
        );
        delegatorFactory.whitelist(fullRestakeDelegatorImpl);

        address operatorSpecificDelegatorImpl = address(
            new OperatorSpecificDelegator(
                address(operatorRegistry),
                address(networkRegistry),
                address(vaultFactory),
                address(operatorVaultOptInService),
                address(operatorNetworkOptInService),
                address(delegatorFactory),
                delegatorFactory.totalTypes()
            )
        );
        delegatorFactory.whitelist(operatorSpecificDelegatorImpl);

        address operatorNetworkSpecificDelegatorImpl = address(
            new OperatorNetworkSpecificDelegator(
                address(operatorRegistry),
                address(networkRegistry),
                address(vaultFactory),
                address(operatorVaultOptInService),
                address(operatorNetworkOptInService),
                address(delegatorFactory),
                delegatorFactory.totalTypes()
            )
        );
        delegatorFactory.whitelist(operatorNetworkSpecificDelegatorImpl);

        vaultConfigurator =
            new VaultConfigurator(address(vaultFactory), address(delegatorFactory), address(slasherFactory));

        curatorRegistry = new CuratorRegistry();
        feeRegistry = new FeeRegistry(address(curatorRegistry));
        feeRegistry.initialize(address(this));

        (vault, networkRestakeDelegator) = _createNetworkRestakeVault();
        (operatorSpecificVault, operatorSpecificDelegator) = _createOperatorSpecificVault(operator);
        (operatorNetworkVault, operatorNetworkSpecificDelegator) = _createOperatorNetworkVault(operator);
        (invalidDelegatorVault, fullRestakeDelegator) = _createFullRestakeVault();

        _configureCuratorAndFees(address(vault));
        _configureCuratorAndFees(address(operatorSpecificVault));
        _configureCuratorAndFees(address(operatorNetworkVault));
        _configureCuratorAndFees(address(invalidDelegatorVault));

        vm.prank(operator);
        operatorVaultOptInService.optIn(address(vault));
        vm.prank(otherOperator);
        operatorVaultOptInService.optIn(address(vault));
        vm.prank(operator);
        operatorVaultOptInService.optIn(address(operatorSpecificVault));
        vm.prank(operator);
        operatorVaultOptInService.optIn(address(operatorNetworkVault));

        vm.prank(operator);
        operatorNetworkOptInService.optIn(network);
        vm.prank(otherOperator);
        operatorNetworkOptInService.optIn(network);

        TIMESTAMP = uint48(block.timestamp + 10);
        vm.warp(TIMESTAMP);

        _deposit(address(vault), staker, 100 * 10 ** 18);
        _deposit(address(vault), curator, 900 * 10 ** 18);
        _deposit(address(operatorSpecificVault), curator, 1000 * 10 ** 18);
        _deposit(address(operatorNetworkVault), curator, 1000 * 10 ** 18);
        _deposit(address(invalidDelegatorVault), curator, 1000 * 10 ** 18);

        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);

        vm.prank(network);
        networkRestakeDelegator.setMaxNetworkLimit(SUBNETWORK_ID, 1000 * 10 ** 18);
        networkRestakeDelegator.setNetworkLimit(subnetwork, 1000 * 10 ** 18);
        networkRestakeDelegator.setOperatorNetworkShares(subnetwork, operator, 50 * 10 ** 18);
        networkRestakeDelegator.setOperatorNetworkShares(subnetwork, otherOperator, 150 * 10 ** 18);

        vm.prank(network);
        operatorSpecificDelegator.setMaxNetworkLimit(SUBNETWORK_ID, 1000 * 10 ** 18);
        operatorSpecificDelegator.setNetworkLimit(subnetwork, 1000 * 10 ** 18);

        vm.prank(network);
        operatorNetworkSpecificDelegator.setMaxNetworkLimit(SUBNETWORK_ID, 1000 * 10 ** 18);

        vm.prank(network);
        networkMiddlewareService.setMiddleware(middleware);

        vm.warp(TIMESTAMP + 1);

        vaultSnapshotRewards = new TestableVaultSnapshotRewards(
            address(vaultFactory),
            address(networkRegistry),
            address(networkMiddlewareService),
            address(curatorRegistry),
            address(feeRegistry)
        );

        vm.prank(network);
        rewardsToken.approve(address(vaultSnapshotRewards), type(uint256).max);

        vm.prank(middleware);
        rewardsToken.approve(address(vaultSnapshotRewards), type(uint256).max);
    }

    function _baseParams() internal view returns (IBaseDelegator.BaseParams memory) {
        return IBaseDelegator.BaseParams({
            defaultAdminRoleHolder: address(this), hook: address(0), hookSetRoleHolder: address(this)
        });
    }

    function _vaultInitParams() internal view returns (IVault.InitParams memory) {
        return IVault.InitParams({
            collateral: address(rewardsToken),
            burner: address(0xdEaD),
            epochDuration: 7 days,
            depositWhitelist: false,
            isDepositLimit: false,
            depositLimit: 0,
            defaultAdminRoleHolder: address(this),
            depositWhitelistSetRoleHolder: address(this),
            depositorWhitelistRoleHolder: address(this),
            isDepositLimitSetRoleHolder: address(this),
            depositLimitSetRoleHolder: address(this)
        });
    }

    function _toSingletonArray(
        address value
    ) internal pure returns (address[] memory array) {
        array = new address[](1);
        array[0] = value;
    }

    function _createNetworkRestakeVault() internal returns (Vault vault_, NetworkRestakeDelegator delegator_) {
        (address vaultAddr, address delegatorAddr,) = vaultConfigurator.create(
            IVaultConfigurator.InitParams({
                version: vaultFactory.lastVersion(),
                owner: address(this),
                vaultParams: abi.encode(_vaultInitParams()),
                delegatorIndex: NETWORK_RESTAKE_TYPE,
                delegatorParams: abi.encode(
                    INetworkRestakeDelegator.InitParams({
                        baseParams: _baseParams(),
                        networkLimitSetRoleHolders: _toSingletonArray(address(this)),
                        operatorNetworkSharesSetRoleHolders: _toSingletonArray(address(this))
                    })
                ),
                withSlasher: false,
                slasherIndex: 0,
                slasherParams: ""
            })
        );

        vault_ = Vault(vaultAddr);
        delegator_ = NetworkRestakeDelegator(delegatorAddr);
    }

    function _createOperatorSpecificVault(
        address operator_
    ) internal returns (Vault vault_, OperatorSpecificDelegator delegator_) {
        (address vaultAddr, address delegatorAddr,) = vaultConfigurator.create(
            IVaultConfigurator.InitParams({
                version: vaultFactory.lastVersion(),
                owner: address(this),
                vaultParams: abi.encode(_vaultInitParams()),
                delegatorIndex: OPERATOR_SPECIFIC_TYPE,
                delegatorParams: abi.encode(
                    IOperatorSpecificDelegator.InitParams({
                        baseParams: _baseParams(),
                        networkLimitSetRoleHolders: _toSingletonArray(address(this)),
                        operator: operator_
                    })
                ),
                withSlasher: false,
                slasherIndex: 0,
                slasherParams: ""
            })
        );

        vault_ = Vault(vaultAddr);
        delegator_ = OperatorSpecificDelegator(delegatorAddr);
    }

    function _createOperatorNetworkVault(
        address operator_
    ) internal returns (Vault vault_, OperatorNetworkSpecificDelegator delegator_) {
        (address vaultAddr, address delegatorAddr,) = vaultConfigurator.create(
            IVaultConfigurator.InitParams({
                version: vaultFactory.lastVersion(),
                owner: address(this),
                vaultParams: abi.encode(_vaultInitParams()),
                delegatorIndex: OPERATOR_NETWORK_SPECIFIC_TYPE,
                delegatorParams: abi.encode(
                    IOperatorNetworkSpecificDelegator.InitParams({
                        baseParams: _baseParams(), network: network, operator: operator_
                    })
                ),
                withSlasher: false,
                slasherIndex: 0,
                slasherParams: ""
            })
        );

        vault_ = Vault(vaultAddr);
        delegator_ = OperatorNetworkSpecificDelegator(delegatorAddr);
    }

    function _createFullRestakeVault() internal returns (Vault vault_, FullRestakeDelegator delegator_) {
        (address vaultAddr, address delegatorAddr,) = vaultConfigurator.create(
            IVaultConfigurator.InitParams({
                version: vaultFactory.lastVersion(),
                owner: address(this),
                vaultParams: abi.encode(_vaultInitParams()),
                delegatorIndex: FULL_RESTAKE_TYPE,
                delegatorParams: abi.encode(
                    IFullRestakeDelegator.InitParams({
                        baseParams: _baseParams(),
                        networkLimitSetRoleHolders: _toSingletonArray(address(this)),
                        operatorNetworkLimitSetRoleHolders: _toSingletonArray(address(this))
                    })
                ),
                withSlasher: false,
                slasherIndex: 0,
                slasherParams: ""
            })
        );

        vault_ = Vault(vaultAddr);
        delegator_ = FullRestakeDelegator(delegatorAddr);
    }

    function _deposit(
        address vault_,
        address depositor,
        uint256 amount
    ) internal {
        vm.startPrank(depositor);
        rewardsToken.approve(vault_, type(uint256).max);
        Vault(vault_).deposit(depositor, amount);
        vm.stopPrank();
    }

    function _configureCuratorAndFees(
        address vault_
    ) internal {
        curatorRegistry.setCurator(vault_, curator);

        vm.startPrank(curator);
        feeRegistry.setCuratorFee(vault_, 50_000);
        feeRegistry.setOperatorsFee(vault_, 30_000);
        vm.stopPrank();
    }

    function _deployOperatorSpecificVault(
        address operator_
    ) internal returns (Vault newVault, uint48 rewardTimestamp) {
        if (!operatorRegistry.isEntity(operator_)) {
            vm.prank(operator_);
            operatorRegistry.registerOperator();
        }

        OperatorSpecificDelegator newDelegator;
        (newVault, newDelegator) = _createOperatorSpecificVault(operator_);

        _configureCuratorAndFees(address(newVault));

        rewardTimestamp = uint48(block.timestamp + 1);
        vm.warp(rewardTimestamp);

        _deposit(address(newVault), curator, 1000 * 10 ** 18);

        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);

        vm.prank(network);
        newDelegator.setMaxNetworkLimit(SUBNETWORK_ID, 1000 * 10 ** 18);
        newDelegator.setNetworkLimit(subnetwork, 1000 * 10 ** 18);

        vm.prank(operator_);
        operatorVaultOptInService.optIn(address(newVault));
        vm.prank(operator_);
        operatorNetworkOptInService.optIn(network);

        vm.warp(uint256(rewardTimestamp) + 1);

        return (newVault, rewardTimestamp);
    }

    /* DISTRIBUTE VAULT SNAPSHOT REWARDS TESTS */

    function test_DistributeVaultSnapshotRewards_Success() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);

        vm.expectEmit(true, true, true, true);
        emit IVaultSnapshotRewards.DistributeVaultSnapshotRewards(
            network,
            address(rewardsToken),
            address(vault),
            SUBNETWORK_ID,
            TIMESTAMP,
            REWARD_AMOUNT - (REWARD_AMOUNT * 50_000 / 1_000_000) - (REWARD_AMOUNT * 30_000 / 1_000_000), // After fees
            REWARD_AMOUNT * 50_000 / 1_000_000, // Curator fee
            REWARD_AMOUNT * 30_000 / 1_000_000 // Operators fee
        );

        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        // Check rewards length
        assertEq(vaultSnapshotRewards.rewardsLength(address(vault), network, address(rewardsToken)), 1);

        // Check reward distribution
        IVaultSnapshotRewards.RewardDistribution memory reward =
            vaultSnapshotRewards.rewards(address(vault), network, address(rewardsToken), 0);

        assertEq(reward.subnetworkId, SUBNETWORK_ID);
        assertEq(reward.delegator, address(networkRestakeDelegator));
        assertEq(reward.delegatorType, 0);
        assertEq(reward.timestamp, TIMESTAMP);
        assertEq(
            reward.amount, REWARD_AMOUNT - (REWARD_AMOUNT * 50_000 / 1_000_000) - (REWARD_AMOUNT * 30_000 / 1_000_000)
        );
        assertEq(reward.operatorsFee, REWARD_AMOUNT * 30_000 / 1_000_000);
    }

    function test_DistributeVaultSnapshotRewards_RevertWhen_NotNetworkOrMiddleware() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);

        vm.expectRevert(IVaultSnapshotRewards.NotNetworkOrMiddleware.selector);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );
    }

    function test_DistributeVaultSnapshotRewards_RevertWhen_InvalidVault() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);

        vm.expectRevert(IVaultSnapshotRewards.InvalidVault.selector);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork,
            address(rewardsToken),
            address(0), // Invalid vault
            REWARD_AMOUNT,
            TIMESTAMP,
            new bytes(0)
        );
    }

    function test_DistributeVaultSnapshotRewards_RevertWhen_InvalidRewardTimestamp() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);

        vm.expectRevert(IVaultSnapshotRewards.InvalidRewardTimestamp.selector);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork,
            address(rewardsToken),
            address(vault),
            REWARD_AMOUNT,
            uint48(block.timestamp), // Future timestamp
            new bytes(0)
        );
    }

    function test_DistributeVaultSnapshotRewards_RevertWhen_ZeroActiveShares() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);

        uint48 emptyTimestamp = TIMESTAMP - 1;

        vm.expectRevert(IVaultSnapshotRewards.InvalidRewardTimestamp.selector);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, emptyTimestamp, new bytes(0)
        );
    }

    function test_DistributeVaultSnapshotRewards_RevertWhen_InsufficientReward() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);

        vm.expectRevert(IVaultSnapshotRewards.InsufficientReward.selector);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork,
            address(rewardsToken),
            address(vault),
            0, // Zero amount
            TIMESTAMP,
            new bytes(0)
        );
    }

    function test_DistributeVaultSnapshotRewards_WithMiddleware() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);

        vm.prank(middleware);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        assertEq(vaultSnapshotRewards.rewardsLength(address(vault), network, address(rewardsToken)), 1);
    }

    /* CLAIM VAULT SNAPSHOT REWARDS TESTS */

    function test_ClaimVaultSnapshotRewards_Success() public {
        // First distribute rewards
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        uint256 expectedAmount =
            (100
                * 10
                ** 18
                * (REWARD_AMOUNT - (REWARD_AMOUNT * 50_000 / 1_000_000) - (REWARD_AMOUNT * 30_000 / 1_000_000)))
            / (1000 * 10 ** 18);

        vm.expectEmit(true, true, true, true);
        emit IVaultSnapshotRewards.ClaimVaultSnapshotRewards(
            staker, network, address(rewardsToken), address(vault), expectedAmount, 1
        );

        vm.prank(staker);
        vaultSnapshotRewards.claimVaultSnapshotRewards(
            recipient,
            network,
            address(rewardsToken),
            address(vault),
            0, // lastUnclaimedRewards
            0, // firstRewardToClaim
            1, // maxRewards
            new bytes[](0) // activeSharesHints
        );

        assertEq(rewardsToken.balanceOf(recipient), expectedAmount);
        assertEq(vaultSnapshotRewards.lastUnclaimedReward(staker, address(vault), network, address(rewardsToken)), 1);
    }

    function test_ClaimVaultSnapshotRewards_RevertWhen_InvalidRecipient() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        vm.expectRevert(IVaultSnapshotRewards.InvalidRecipient.selector);
        vm.prank(staker);
        vaultSnapshotRewards.claimVaultSnapshotRewards(
            address(0), // Invalid recipient
            network,
            address(rewardsToken),
            address(vault),
            0,
            0,
            1,
            new bytes[](0)
        );
    }

    function test_ClaimVaultSnapshotRewards_RevertWhen_InvalidLastUnclaimedReward() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        vm.expectRevert(IVaultSnapshotRewards.InvalidLastUnclaimedReward.selector);
        vm.prank(staker);
        vaultSnapshotRewards.claimVaultSnapshotRewards(
            recipient,
            network,
            address(rewardsToken),
            address(vault),
            1, // Wrong lastUnclaimedRewards
            0,
            1,
            new bytes[](0)
        );
    }

    function test_ClaimVaultSnapshotRewards_RevertWhen_NoRewardsToClaim() public {
        vm.expectRevert(IVaultSnapshotRewards.NoRewardsToClaim.selector);
        vm.prank(staker);
        vaultSnapshotRewards.claimVaultSnapshotRewards(
            recipient, network, address(rewardsToken), address(vault), 0, 0, 1, new bytes[](0)
        );
    }

    /* CLAIM CURATOR FEE TESTS */

    function test_ClaimCuratorFee_Success() public {
        // First distribute rewards to generate curator fees
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        uint256 expectedCuratorFee = REWARD_AMOUNT * 50_000 / 1_000_000;

        vm.expectEmit(true, true, true, true);
        emit IVaultSnapshotRewards.ClaimCuratorFee(address(vault), address(rewardsToken), expectedCuratorFee);

        vm.prank(curator);
        vaultSnapshotRewards.claimCuratorFee(recipient, address(vault), address(rewardsToken));

        assertEq(rewardsToken.balanceOf(recipient), expectedCuratorFee);
    }

    function test_ClaimCuratorFee_RevertWhen_NotCurator() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        vm.expectRevert(IVaultSnapshotRewards.NotCurator.selector);
        vm.prank(staker); // Not the curator
        vaultSnapshotRewards.claimCuratorFee(recipient, address(vault), address(rewardsToken));
    }

    function test_ClaimCuratorFee_RevertWhen_NoRewardsToClaim() public {
        vm.expectRevert(IVaultSnapshotRewards.NoRewardsToClaim.selector);
        vm.prank(curator);
        vaultSnapshotRewards.claimCuratorFee(recipient, address(vault), address(rewardsToken));
    }

    /* CLAIM OPERATOR FEE TESTS */

    function test_ClaimOperatorFee_NetworkRestakeDelegator_Success() public {
        // First distribute rewards
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        assertGt(networkRestakeDelegator.totalOperatorNetworkShares(Subnetwork.subnetwork(network, SUBNETWORK_ID)), 0);
        assertGt(
            networkRestakeDelegator.totalOperatorNetworkSharesAt(
                Subnetwork.subnetwork(network, SUBNETWORK_ID), TIMESTAMP, new bytes(0)
            ),
            0
        );

        uint256 operatorsFee = REWARD_AMOUNT * 30_000 / 1_000_000;
        uint256 expectedAmount = ((50 * 10 ** 18 * operatorsFee) / (200 * 10 ** 18)) * 2;

        bytes[] memory operatorNetworkSharesHints = new bytes[](2);
        operatorNetworkSharesHints[0] = abi.encode(0);
        operatorNetworkSharesHints[1] = abi.encode(0);
        bytes[] memory totalOperatorNetworkSharesHint = new bytes[](2);
        totalOperatorNetworkSharesHint[0] = abi.encode(0);
        totalOperatorNetworkSharesHint[1] = abi.encode(0);
        bytes memory extraData = abi.encode(operatorNetworkSharesHints, totalOperatorNetworkSharesHint);

        vm.expectEmit(true, true, true, true);
        emit IVaultSnapshotRewards.ClaimOperatorFee(
            operator, network, address(rewardsToken), address(vault), expectedAmount, 2
        );

        vm.prank(operator);
        vaultSnapshotRewards.claimOperatorFee(
            recipient, network, address(rewardsToken), address(vault), 0, 0, 2, extraData
        );

        assertEq(rewardsToken.balanceOf(recipient), expectedAmount);
        assertEq(
            vaultSnapshotRewards.lastUnclaimedOperatorReward(operator, address(vault), network, address(rewardsToken)),
            2
        );
    }

    function test_ClaimOperatorFee_OperatorSpecificDelegator_Success() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(operatorSpecificVault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        uint256 operatorsFee = REWARD_AMOUNT * 30_000 / 1_000_000;

        vm.prank(operator);
        vaultSnapshotRewards.claimOperatorFee(
            recipient, network, address(rewardsToken), address(operatorSpecificVault), 0, 0, 1, new bytes(0)
        );

        assertEq(rewardsToken.balanceOf(recipient), operatorsFee);
    }

    function test_ClaimOperatorFee_OperatorNetworkSpecificDelegator_Success() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(operatorNetworkVault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        uint256 operatorsFee = REWARD_AMOUNT * 30_000 / 1_000_000;

        vm.prank(operator);
        vaultSnapshotRewards.claimOperatorFee(
            recipient, network, address(rewardsToken), address(operatorNetworkVault), 0, 0, 1, new bytes(0)
        );

        assertEq(rewardsToken.balanceOf(recipient), operatorsFee);
    }

    function test_ClaimOperatorFee_RevertWhen_InvalidRecipient() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        vm.expectRevert(IVaultSnapshotRewards.InvalidRecipient.selector);
        vm.prank(operator);
        vaultSnapshotRewards.claimOperatorFee(
            address(0), // Invalid recipient
            network,
            address(rewardsToken),
            address(vault),
            0,
            0,
            1,
            new bytes(0)
        );
    }

    function test_ClaimOperatorFee_RevertWhen_InvalidLastUnclaimedReward() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        vm.expectRevert(IVaultSnapshotRewards.InvalidHintsLength.selector);
        vm.prank(operator);
        vaultSnapshotRewards.claimOperatorFee(
            recipient,
            network,
            address(rewardsToken),
            address(vault),
            1, // Wrong lastUnclaimedRewards
            0,
            1,
            new bytes(0)
        );
    }

    function test_ClaimOperatorFee_RevertWhen_NoRewardsToClaim() public {
        vm.expectRevert(IVaultSnapshotRewards.NoRewardsToClaim.selector);
        vm.prank(operator);
        vaultSnapshotRewards.claimOperatorFee(
            recipient, network, address(rewardsToken), address(vault), 0, 0, 1, new bytes(0)
        );
    }

    function test_ClaimOperatorFee_RevertWhen_InvalidDelegatorType() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(invalidDelegatorVault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        vm.expectRevert(IVaultSnapshotRewards.InvalidDelegatorType.selector);
        vm.prank(operator);
        vaultSnapshotRewards.claimOperatorFee(
            recipient, network, address(rewardsToken), address(invalidDelegatorVault), 0, 0, 1, new bytes(0)
        );
    }

    function test_ClaimOperatorFee_RevertWhen_NotOperator() public {
        address wrongOperator = address(0x999);
        (Vault operatorVault, uint48 rewardTimestamp) = _deployOperatorSpecificVault(wrongOperator);

        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(operatorVault), REWARD_AMOUNT, rewardTimestamp, new bytes(0)
        );

        vm.expectRevert(IVaultSnapshotRewards.NotOperator.selector);
        vm.prank(operator); // Wrong operator
        vaultSnapshotRewards.claimOperatorFee(
            recipient, network, address(rewardsToken), address(operatorVault), 0, 0, 1, new bytes(0)
        );
    }

    /* VIEW FUNCTION TESTS */

    function test_RewardsLength() public {
        assertEq(vaultSnapshotRewards.rewardsLength(address(vault), network, address(rewardsToken)), 0);

        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        assertEq(vaultSnapshotRewards.rewardsLength(address(vault), network, address(rewardsToken)), 1);
    }

    function test_Rewards() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        IVaultSnapshotRewards.RewardDistribution memory reward =
            vaultSnapshotRewards.rewards(address(vault), network, address(rewardsToken), 0);

        assertEq(reward.subnetworkId, SUBNETWORK_ID);
        assertEq(reward.delegator, address(networkRestakeDelegator));
        assertEq(reward.delegatorType, 0);
        assertEq(reward.timestamp, TIMESTAMP);
    }

    function test_LastUnclaimedReward() public {
        assertEq(vaultSnapshotRewards.lastUnclaimedReward(staker, address(vault), network, address(rewardsToken)), 0);
    }

    function test_LastUnclaimedOperatorReward() public {
        assertEq(
            vaultSnapshotRewards.lastUnclaimedOperatorReward(operator, address(vault), network, address(rewardsToken)),
            0
        );
    }

    /* CLAIM REWARDS TESTS */

    function test_ClaimRewards_Success() public {
        // First distribute rewards
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        // Encode claim data
        bytes[] memory activeSharesHints = new bytes[](1);
        activeSharesHints[0] = new bytes(0);

        bytes memory data = abi.encode(
            network,
            address(vault),
            uint256(0), // lastUnclaimedRewards
            uint256(0), // firstRewardToClaim
            uint256(1), // maxRewards
            activeSharesHints
        );

        vm.prank(staker);
        vaultSnapshotRewards.claimRewards(recipient, address(rewardsToken), data);

        uint256 expectedAmount =
            (100
                * 10
                ** 18
                * (REWARD_AMOUNT - (REWARD_AMOUNT * 50_000 / 1_000_000) - (REWARD_AMOUNT * 30_000 / 1_000_000)))
            / (1000 * 10 ** 18);
        assertEq(rewardsToken.balanceOf(recipient), expectedAmount);
    }

    /* EDGE CASES AND ERROR CONDITIONS */

    function test_MultipleDistributions() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);

        // First distribution
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        // Second distribution
        uint48 secondTimestamp = TIMESTAMP + 1;
        vm.warp(uint256(secondTimestamp) + 1);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, secondTimestamp, new bytes(0)
        );

        assertEq(vaultSnapshotRewards.rewardsLength(address(vault), network, address(rewardsToken)), 2);
    }

    function test_PartialClaim() public {
        // Distribute multiple rewards
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);

        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        uint48 secondTimestamp = TIMESTAMP + 1;
        vm.warp(uint256(secondTimestamp) + 1);
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, secondTimestamp, new bytes(0)
        );

        // Claim only first reward
        vm.prank(staker);
        vaultSnapshotRewards.claimVaultSnapshotRewards(
            recipient,
            network,
            address(rewardsToken),
            address(vault),
            0,
            0,
            1, // maxRewards = 1
            new bytes[](0)
        );

        assertEq(vaultSnapshotRewards.lastUnclaimedReward(staker, address(vault), network, address(rewardsToken)), 1);

        // Claim second reward
        vm.prank(staker);
        vaultSnapshotRewards.claimVaultSnapshotRewards(
            recipient,
            network,
            address(rewardsToken),
            address(vault),
            1, // lastUnclaimedRewards = 1
            0,
            1,
            new bytes[](0)
        );

        assertEq(vaultSnapshotRewards.lastUnclaimedReward(staker, address(vault), network, address(rewardsToken)), 2);
    }

    function test_ZeroStakerShares() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);
        uint48 rewardTimestamp = uint48(block.timestamp + 1);
        vm.warp(rewardTimestamp);

        vm.prank(staker);
        vault.withdraw(staker, 100 * 10 ** 18);

        vm.warp(uint256(rewardTimestamp) + 1);

        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, rewardTimestamp, new bytes(0)
        );

        vm.warp(uint256(rewardTimestamp) + 2);

        vm.prank(staker);
        vaultSnapshotRewards.claimVaultSnapshotRewards(
            recipient, network, address(rewardsToken), address(vault), 0, 0, 1, new bytes[](0)
        );

        // Should not transfer any tokens
        assertEq(rewardsToken.balanceOf(recipient), 0);
    }

    function test_CachedActiveShares() public {
        bytes32 subnetwork = Subnetwork.subnetwork(network, SUBNETWORK_ID);

        // First distribution caches active shares
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        // Second distribution with same timestamp should use cached value
        vm.prank(network);
        vaultSnapshotRewards.distributeVaultSnapshotRewards(
            subnetwork, address(rewardsToken), address(vault), REWARD_AMOUNT, TIMESTAMP, new bytes(0)
        );

        assertEq(vaultSnapshotRewards.rewardsLength(address(vault), network, address(rewardsToken)), 2);
    }
}
