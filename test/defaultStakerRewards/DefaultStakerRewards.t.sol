// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";

import {VaultFactory} from "@symbiotic/contracts/VaultFactory.sol";
import {DelegatorFactory} from "@symbiotic/contracts/DelegatorFactory.sol";
import {SlasherFactory} from "@symbiotic/contracts/SlasherFactory.sol";
import {NetworkRegistry} from "@symbiotic/contracts/NetworkRegistry.sol";
import {OperatorRegistry} from "@symbiotic/contracts/OperatorRegistry.sol";
import {MetadataService} from "@symbiotic/contracts/service/MetadataService.sol";
import {NetworkMiddlewareService} from "@symbiotic/contracts/service/NetworkMiddlewareService.sol";
import {OptInService} from "@symbiotic/contracts/service/OptInService.sol";

import {Vault} from "@symbiotic/contracts/vault/Vault.sol";
import {NetworkRestakeDelegator} from "@symbiotic/contracts/delegator/NetworkRestakeDelegator.sol";
import {FullRestakeDelegator} from "@symbiotic/contracts/delegator/FullRestakeDelegator.sol";
import {Slasher} from "@symbiotic/contracts/slasher/Slasher.sol";
import {VetoSlasher} from "@symbiotic/contracts/slasher/VetoSlasher.sol";

import {SimpleCollateral} from "@symbiotic/mocks/SimpleCollateral.sol";
import {Token} from "@symbiotic/mocks/Token.sol";
import {VaultConfigurator, IVaultConfigurator} from "@symbiotic/contracts/VaultConfigurator.sol";
import {IVault} from "@symbiotic/interfaces/IVaultConfigurator.sol";
import {INetworkRestakeDelegator} from "@symbiotic/interfaces/delegator/INetworkRestakeDelegator.sol";
import {IBaseDelegator} from "@symbiotic/interfaces/delegator/IBaseDelegator.sol";

import {DefaultStakerRewardsFactory} from "src/contracts/defaultStakerRewards/DefaultStakerRewardsFactory.sol";
import {IDefaultStakerRewards} from "src/interfaces/defaultStakerRewards/IDefaultStakerRewards.sol";

import {DefaultStakerRewards} from "src/contracts/defaultStakerRewards/DefaultStakerRewards.sol";

import {FeeOnTransferToken} from "@symbiotic/mocks/FeeOnTransferToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {VaultHints} from "@symbiotic/contracts/hints/VaultHints.sol";

contract DefaultStakerRewardsTest is Test {
    using Math for uint256;

    address owner;
    address alice;
    uint256 alicePrivateKey;
    address bob;
    uint256 bobPrivateKey;

    VaultFactory vaultFactory;
    DelegatorFactory delegatorFactory;
    SlasherFactory slasherFactory;
    NetworkRegistry networkRegistry;
    OperatorRegistry operatorRegistry;
    MetadataService operatorMetadataService;
    MetadataService networkMetadataService;
    NetworkMiddlewareService networkMiddlewareService;
    OptInService networkVaultOptInService;
    OptInService operatorVaultOptInService;
    OptInService operatorNetworkOptInService;

    SimpleCollateral collateral;
    VaultConfigurator vaultConfigurator;

    Vault vault;
    FullRestakeDelegator delegator;
    Slasher slasher;

    DefaultStakerRewardsFactory defaultStakerRewardsFactory;
    IDefaultStakerRewards defaultStakerRewards;

    function setUp() public {
        owner = address(this);
        (alice, alicePrivateKey) = makeAddrAndKey("alice");
        (bob, bobPrivateKey) = makeAddrAndKey("bob");

        vaultFactory = new VaultFactory(owner);
        delegatorFactory = new DelegatorFactory(owner);
        slasherFactory = new SlasherFactory(owner);
        networkRegistry = new NetworkRegistry();
        operatorRegistry = new OperatorRegistry();
        operatorMetadataService = new MetadataService(address(operatorRegistry));
        networkMetadataService = new MetadataService(address(networkRegistry));
        networkMiddlewareService = new NetworkMiddlewareService(address(networkRegistry));
        operatorVaultOptInService = new OptInService(address(operatorRegistry), address(vaultFactory));
        operatorNetworkOptInService = new OptInService(address(operatorRegistry), address(networkRegistry));

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

        address slasherImpl = address(
            new Slasher(
                address(vaultFactory),
                address(networkMiddlewareService),
                address(slasherFactory),
                slasherFactory.totalTypes()
            )
        );
        slasherFactory.whitelist(slasherImpl);

        address vetoSlasherImpl = address(
            new VetoSlasher(
                address(vaultFactory),
                address(networkMiddlewareService),
                address(networkRegistry),
                address(slasherFactory),
                slasherFactory.totalTypes()
            )
        );
        slasherFactory.whitelist(vetoSlasherImpl);

        vaultConfigurator =
            new VaultConfigurator(address(vaultFactory), address(delegatorFactory), address(slasherFactory));

        Token token = new Token("Token");
        collateral = new SimpleCollateral(address(token));

        collateral.mint(token.totalSupply());

        address[] memory networkLimitSetRoleHolders = new address[](1);
        networkLimitSetRoleHolders[0] = alice;
        address[] memory operatorNetworkSharesSetRoleHolders = new address[](1);
        operatorNetworkSharesSetRoleHolders[0] = alice;
        (address vault_,,) = vaultConfigurator.create(
            IVaultConfigurator.InitParams({
                version: vaultFactory.lastVersion(),
                owner: alice,
                vaultParams: IVault.InitParams({
                    collateral: address(collateral),
                    delegator: address(0),
                    slasher: address(0),
                    burner: address(0xdEaD),
                    epochDuration: 7 days,
                    depositWhitelist: false,
                    defaultAdminRoleHolder: alice,
                    depositorWhitelistRoleHolder: alice
                }),
                delegatorIndex: 0,
                delegatorParams: abi.encode(
                    INetworkRestakeDelegator.InitParams({
                        baseParams: IBaseDelegator.BaseParams({
                            defaultAdminRoleHolder: alice,
                            hook: address(0),
                            hookSetRoleHolder: alice
                        }),
                        networkLimitSetRoleHolders: networkLimitSetRoleHolders,
                        operatorNetworkSharesSetRoleHolders: operatorNetworkSharesSetRoleHolders
                    })
                ),
                withSlasher: false,
                slasherIndex: 0,
                slasherParams: ""
            })
        );

        vault = Vault(vault_);

        address defaultStakerRewards_ = address(
            new DefaultStakerRewards(address(vaultFactory), address(networkRegistry), address(networkMiddlewareService))
        );

        defaultStakerRewardsFactory = new DefaultStakerRewardsFactory(defaultStakerRewards_);
    }

    function test_Create() public {
        defaultStakerRewards = _getStakerDefaultRewards();
    }

    function test_CreateRevertMissingRoles(uint256 adminFee) public {
        adminFee = bound(adminFee, 1, 10_000);

        vm.expectRevert(IDefaultStakerRewards.MissingRoles.selector);
        defaultStakerRewardsFactory.create(
            IDefaultStakerRewards.InitParams({
                vault: address(vault),
                adminFee: adminFee,
                defaultAdminRoleHolder: address(0),
                adminFeeClaimRoleHolder: address(0),
                networkWhitelistRoleHolder: alice,
                adminFeeSetRoleHolder: alice
            })
        );
    }

    function test_CreateRevertInvalidAdminFee(uint256 adminFee) public {
        adminFee = bound(adminFee, 10_001, type(uint256).max);

        vm.expectRevert(IDefaultStakerRewards.InvalidAdminFee.selector);
        defaultStakerRewardsFactory.create(
            IDefaultStakerRewards.InitParams({
                vault: address(vault),
                adminFee: adminFee,
                defaultAdminRoleHolder: alice,
                adminFeeClaimRoleHolder: alice,
                networkWhitelistRoleHolder: alice,
                adminFeeSetRoleHolder: alice
            })
        );
    }

    function test_ReinitRevert() public {
        defaultStakerRewards = _getStakerDefaultRewards();

        vm.expectRevert();
        DefaultStakerRewards(address(defaultStakerRewards)).initialize(
            IDefaultStakerRewards.InitParams({
                vault: address(vault),
                adminFee: 0,
                defaultAdminRoleHolder: alice,
                adminFeeClaimRoleHolder: alice,
                networkWhitelistRoleHolder: alice,
                adminFeeSetRoleHolder: alice
            })
        );
    }

    function test_DistributeRewards(
        uint256 amount,
        uint256 ditributeAmount,
        uint256 adminFee,
        uint256 maxAdminFee
    ) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 2, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        adminFee = bound(adminFee, 1, defaultStakerRewards.ADMIN_FEE_BASE());
        maxAdminFee = bound(maxAdminFee, adminFee, type(uint256).max);

        _grantAdminFeeSetRole(alice, alice);
        _setAdminFee(alice, adminFee);

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 feeOnTransferToken = IERC20(new FeeOnTransferToken("FeeOnTransferToken"));
        feeOnTransferToken.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        feeOnTransferToken.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        uint256 balanceBefore = feeOnTransferToken.balanceOf(address(defaultStakerRewards));
        uint256 balanceBeforeBob = feeOnTransferToken.balanceOf(bob);
        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(bob, network, address(feeOnTransferToken), ditributeAmount, timestamp, maxAdminFee, "", "");
        console2.log("Gas1: ", vm.lastCallGas().gasTotalUsed);

        assertEq(feeOnTransferToken.balanceOf(address(defaultStakerRewards)) - balanceBefore, ditributeAmount - 1);
        assertEq(balanceBeforeBob - feeOnTransferToken.balanceOf(bob), ditributeAmount);

        uint256 amount__ = ditributeAmount - 1;
        uint256 adminFeeAmount = amount__.mulDiv(adminFee, defaultStakerRewards.ADMIN_FEE_BASE());
        amount__ -= adminFeeAmount;

        if (amount__ > 0) {
            assertEq(defaultStakerRewards.rewardsLength(address(feeOnTransferToken), network), 1);
            (uint256 amount_, uint48 timestamp_) = defaultStakerRewards.rewards(address(feeOnTransferToken), network, 0);
            assertEq(amount_, amount__);
            assertEq(timestamp_, timestamp);
        } else {
            assertEq(defaultStakerRewards.rewardsLength(address(feeOnTransferToken), network), 0);
        }

        assertEq(defaultStakerRewards.claimableAdminFee(address(feeOnTransferToken)), adminFeeAmount);

        assertEq(
            defaultStakerRewards.claimable(address(feeOnTransferToken), alice, abi.encode(network, type(uint256).max)),
            amount__
        );
        assertEq(defaultStakerRewards.claimable(address(feeOnTransferToken), alice, abi.encode(network, 1)), amount__);
        assertEq(defaultStakerRewards.claimable(address(feeOnTransferToken), alice, abi.encode(network, 0)), 0);
    }

    function test_DistributeRewardsHints(
        uint256 amount,
        uint256 ditributeAmount,
        uint256 adminFee,
        uint256 maxAdminFee
    ) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 2, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        adminFee = bound(adminFee, 1, defaultStakerRewards.ADMIN_FEE_BASE());
        maxAdminFee = bound(maxAdminFee, adminFee, type(uint256).max);

        _grantAdminFeeSetRole(alice, alice);
        _setAdminFee(alice, adminFee);

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 feeOnTransferToken = IERC20(new FeeOnTransferToken("FeeOnTransferToken"));
        feeOnTransferToken.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        feeOnTransferToken.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        VaultHints vaultHints = new VaultHints();

        uint256 balanceBefore = feeOnTransferToken.balanceOf(address(defaultStakerRewards));
        uint256 balanceBeforeBob = feeOnTransferToken.balanceOf(bob);
        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(
            bob,
            network,
            address(feeOnTransferToken),
            ditributeAmount,
            timestamp,
            maxAdminFee,
            vaultHints.activeSharesHint(address(vault), timestamp),
            vaultHints.activeStakeHint(address(vault), timestamp)
        );
        console2.log("Gas2: ", vm.lastCallGas().gasTotalUsed);

        assertEq(feeOnTransferToken.balanceOf(address(defaultStakerRewards)) - balanceBefore, ditributeAmount - 1);
        assertEq(balanceBeforeBob - feeOnTransferToken.balanceOf(bob), ditributeAmount);

        uint256 amount__ = ditributeAmount - 1;
        uint256 adminFeeAmount = amount__.mulDiv(adminFee, defaultStakerRewards.ADMIN_FEE_BASE());
        amount__ -= adminFeeAmount;

        if (amount__ > 0) {
            assertEq(defaultStakerRewards.rewardsLength(address(feeOnTransferToken), network), 1);
            (uint256 amount_, uint48 timestamp_) = defaultStakerRewards.rewards(address(feeOnTransferToken), network, 0);
            assertEq(amount_, amount__);
            assertEq(timestamp_, timestamp);
        } else {
            assertEq(defaultStakerRewards.rewardsLength(address(feeOnTransferToken), network), 0);
        }

        assertEq(defaultStakerRewards.claimableAdminFee(address(feeOnTransferToken)), adminFeeAmount);

        assertEq(
            defaultStakerRewards.claimable(address(feeOnTransferToken), alice, abi.encode(network, type(uint256).max)),
            amount__
        );
        assertEq(defaultStakerRewards.claimable(address(feeOnTransferToken), alice, abi.encode(network, 1)), amount__);
        assertEq(defaultStakerRewards.claimable(address(feeOnTransferToken), alice, abi.encode(network, 0)), 0);
    }

    function test_DistributeRewardsRevertNotNetworkMiddleware(uint256 amount, uint256 ditributeAmount) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 2, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 feeOnTransferToken = IERC20(new FeeOnTransferToken("FeeOnTransferToken"));
        feeOnTransferToken.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        feeOnTransferToken.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        uint48 timestamp = 1_720_700_948 + 3;
        vm.expectRevert(IDefaultStakerRewards.NotNetworkMiddleware.selector);
        _distributeRewards(
            alice, network, address(feeOnTransferToken), ditributeAmount, timestamp, type(uint256).max, "", ""
        );
    }

    function test_DistributeRewardsRevertInvalidRewardTimestamp1(uint256 amount, uint256 ditributeAmount) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 2, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 feeOnTransferToken = IERC20(new FeeOnTransferToken("FeeOnTransferToken"));
        feeOnTransferToken.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        feeOnTransferToken.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        vm.expectRevert(IDefaultStakerRewards.InvalidRewardTimestamp.selector);
        _distributeRewards(
            bob,
            network,
            address(feeOnTransferToken),
            ditributeAmount,
            uint48(blockTimestamp),
            type(uint256).max,
            "",
            ""
        );
    }

    function test_DistributeRewardsRevertInvalidRewardTimestamp2(uint256 amount, uint256 ditributeAmount) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 2, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 feeOnTransferToken = IERC20(new FeeOnTransferToken("FeeOnTransferToken"));
        feeOnTransferToken.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        feeOnTransferToken.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        vm.expectRevert(IDefaultStakerRewards.InvalidRewardTimestamp.selector);
        _distributeRewards(
            bob,
            network,
            address(feeOnTransferToken),
            ditributeAmount,
            uint48(blockTimestamp - 12),
            type(uint256).max,
            "",
            ""
        );
    }

    function test_DistributeRewardsRevertHighAdminFee(
        uint256 amount,
        uint256 adminFee,
        uint256 ditributeAmount,
        uint256 maxAdminFee
    ) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 2, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        adminFee = bound(adminFee, 1, defaultStakerRewards.ADMIN_FEE_BASE());
        _grantAdminFeeSetRole(alice, alice);
        _setAdminFee(alice, adminFee);
        maxAdminFee = bound(maxAdminFee, 0, adminFee - 1);

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 feeOnTransferToken = IERC20(new FeeOnTransferToken("FeeOnTransferToken"));
        feeOnTransferToken.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        feeOnTransferToken.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        uint48 timestamp = 1_720_700_948 + 3;
        vm.expectRevert(IDefaultStakerRewards.HighAdminFee.selector);
        _distributeRewards(bob, network, address(feeOnTransferToken), ditributeAmount, timestamp, maxAdminFee, "", "");
    }

    function test_DistributeRewardsRevertInsufficientReward(uint256 amount) public {
        amount = bound(amount, 1, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 feeOnTransferToken = IERC20(new FeeOnTransferToken("FeeOnTransferToken"));
        feeOnTransferToken.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        feeOnTransferToken.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        uint48 timestamp = 1_720_700_948 + 3;
        vm.expectRevert(IDefaultStakerRewards.InsufficientReward.selector);
        _distributeRewards(bob, network, address(feeOnTransferToken), 1, timestamp, type(uint256).max, "", "");
    }

    function test_ClaimRewards(uint256 amount, uint256 ditributeAmount1, uint256 ditributeAmount2) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount1 = bound(ditributeAmount1, 1, 100 * 10 ** 18);
        ditributeAmount2 = bound(ditributeAmount2, 1, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        token.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        _distributeRewards(
            bob, network, address(token), ditributeAmount1, uint48(blockTimestamp - 1), type(uint256).max, "", ""
        );

        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(bob, network, address(token), ditributeAmount2, timestamp, type(uint256).max, "", "");

        uint256 balanceBefore = token.balanceOf(alice);
        bytes[] memory activeSharesOfHints;
        _claimRewards(alice, address(token), network, 2, activeSharesOfHints);
        assertEq(token.balanceOf(alice) - balanceBefore, ditributeAmount1 + ditributeAmount2);

        assertEq(defaultStakerRewards.lastUnclaimedReward(alice, address(token), network), 2);
    }

    function test_ClaimRewardsBoth(uint256 amount, uint256 ditributeAmount1, uint256 ditributeAmount2) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount1 = bound(ditributeAmount1, 1, 100 * 10 ** 18);
        ditributeAmount2 = bound(ditributeAmount2, 1, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;
        _registerNetwork(network, bob);

        uint256 aliceN = 10;
        for (uint256 i; i < aliceN; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        uint256 bobN = 3;
        for (uint256 i; i < bobN; ++i) {
            _deposit(bob, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        token.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        _distributeRewards(
            bob, network, address(token), ditributeAmount1, uint48(blockTimestamp - 1), type(uint256).max, "", ""
        );

        assertEq(
            defaultStakerRewards.claimable(address(token), alice, abi.encode(network, type(uint256).max)),
            ditributeAmount1.mulDiv(aliceN, aliceN + bobN)
        );
        assertEq(
            defaultStakerRewards.claimable(address(token), bob, abi.encode(network, type(uint256).max)),
            ditributeAmount1.mulDiv(bobN, aliceN + bobN)
        );

        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(bob, network, address(token), ditributeAmount2, timestamp, type(uint256).max, "", "");

        assertEq(
            defaultStakerRewards.claimable(address(token), alice, abi.encode(network, type(uint256).max)),
            ditributeAmount1.mulDiv(aliceN, aliceN + bobN) + ditributeAmount2
        );
        assertEq(
            defaultStakerRewards.claimable(address(token), bob, abi.encode(network, type(uint256).max)),
            ditributeAmount1.mulDiv(bobN, aliceN + bobN)
        );

        uint256 balanceBefore = token.balanceOf(alice);
        bytes[] memory activeSharesOfHints;
        _claimRewards(alice, address(token), network, 2, activeSharesOfHints);
        assertEq(
            token.balanceOf(alice) - balanceBefore, ditributeAmount1.mulDiv(aliceN, aliceN + bobN) + ditributeAmount2
        );

        balanceBefore = token.balanceOf(bob);
        _claimRewards(bob, address(token), network, 2, activeSharesOfHints);
        assertEq(token.balanceOf(bob) - balanceBefore, ditributeAmount1.mulDiv(bobN, aliceN + bobN));

        assertEq(defaultStakerRewards.lastUnclaimedReward(alice, address(token), network), 2);
    }

    function test_ClaimRewardsManyWithoutHints(uint256 amount, uint256 ditributeAmount) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 1, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 105; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        token.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        uint256 numRewards = 50;
        for (uint48 i = 1; i < numRewards + 1; ++i) {
            _distributeRewards(
                bob, network, address(token), ditributeAmount, 1_720_700_948 + i, type(uint256).max, "", ""
            );
        }

        bytes[] memory activeSharesOfHints;

        uint256 gasLeft = gasleft();
        _claimRewards(alice, address(token), network, type(uint256).max, activeSharesOfHints);
        uint256 gasLeft2 = gasleft();
        console2.log("Gas1", gasLeft - gasLeft2 - 100);
    }

    function test_ClaimRewardsManyWithHints(uint256 amount, uint256 ditributeAmount) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 1, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        VaultHints vaultHints = new VaultHints();

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 105; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        token.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        uint256 numRewards = 50;
        for (uint48 i = 1; i < numRewards + 1; ++i) {
            _distributeRewards(
                bob, network, address(token), ditributeAmount, uint48(1_720_700_948 + i), type(uint256).max, "", ""
            );
        }

        bytes[] memory activeSharesOfHints = new bytes[](numRewards);
        for (uint256 i; i < numRewards; ++i) {
            activeSharesOfHints[i] = vaultHints.activeSharesOfHint(address(vault), alice, uint48(1_720_700_948 + i + 1));
        }

        uint256 gasLeft = gasleft();
        _claimRewards(alice, address(token), network, type(uint256).max, activeSharesOfHints);
        uint256 gasLeft2 = gasleft();
        console2.log("Gas2", gasLeft - gasLeft2 - 100);
    }

    function test_ClaimRewardsRevertInvalidRecipient(uint256 amount, uint256 ditributeAmount) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 1, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));

        bytes[] memory activeSharesOfHints;
        vm.startPrank(alice);
        vm.expectRevert(IDefaultStakerRewards.InvalidRecipient.selector);
        defaultStakerRewards.claimRewards(
            address(0), address(token), abi.encode(network, type(uint256).max, activeSharesOfHints)
        );
        vm.stopPrank();
    }

    function test_ClaimRewardsRevertNoRewardsToClaim1(uint256 amount, uint256 ditributeAmount) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 1, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));

        bytes[] memory activeSharesOfHints;
        vm.expectRevert(IDefaultStakerRewards.NoRewardsToClaim.selector);
        _claimRewards(alice, address(token), network, type(uint256).max, activeSharesOfHints);
    }

    function test_ClaimRewardsRevertNoRewardsToClaim2(uint256 amount, uint256 ditributeAmount) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 1, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));

        bytes[] memory activeSharesOfHints;
        vm.expectRevert(IDefaultStakerRewards.NoRewardsToClaim.selector);
        _claimRewards(alice, address(token), network, 0, activeSharesOfHints);
    }

    function test_ClaimRewardsRevertInvalidHintsLength(uint256 amount, uint256 ditributeAmount) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 1, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        token.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(bob, network, address(token), ditributeAmount, timestamp, type(uint256).max, "", "");

        bytes[] memory activeSharesOfHints = new bytes[](2);
        vm.expectRevert(IDefaultStakerRewards.InvalidHintsLength.selector);
        _claimRewards(alice, address(token), network, type(uint256).max, activeSharesOfHints);
    }

    function test_ClaimAdminFee(uint256 amount, uint256 ditributeAmount, uint256 adminFee) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 1, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        adminFee = bound(adminFee, 1, defaultStakerRewards.ADMIN_FEE_BASE());

        _grantAdminFeeSetRole(alice, alice);
        _setAdminFee(alice, adminFee);

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        token.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(bob, network, address(token), ditributeAmount, timestamp, type(uint256).max, "", "");

        uint256 adminFeeAmount = ditributeAmount.mulDiv(adminFee, defaultStakerRewards.ADMIN_FEE_BASE());
        vm.assume(adminFeeAmount > 0);
        uint256 balanceBefore = token.balanceOf(address(defaultStakerRewards));
        uint256 balanceBeforeAlice = token.balanceOf(alice);
        _claimAdminFee(alice, address(token));
        assertEq(balanceBefore - token.balanceOf(address(defaultStakerRewards)), adminFeeAmount);
        assertEq(token.balanceOf(alice) - balanceBeforeAlice, adminFeeAmount);
        assertEq(defaultStakerRewards.claimableAdminFee(address(token)), 0);
    }

    function test_ClaimAdminFeeRevertInsufficientAdminFee(
        uint256 amount,
        uint256 ditributeAmount,
        uint256 adminFee
    ) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 1, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        adminFee = bound(adminFee, 1, defaultStakerRewards.ADMIN_FEE_BASE());

        _grantAdminFeeSetRole(alice, alice);
        _setAdminFee(alice, adminFee);

        address network = bob;
        _registerNetwork(network, bob);

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        token.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(bob, network, address(token), ditributeAmount, timestamp, type(uint256).max, "", "");

        vm.assume(defaultStakerRewards.claimableAdminFee(address(token)) > 0);
        _claimAdminFee(alice, address(token));

        vm.expectRevert(IDefaultStakerRewards.InsufficientAdminFee.selector);
        _claimAdminFee(alice, address(token));
    }

    function test_SetAdminFee(uint256 adminFee) public {
        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        adminFee = bound(adminFee, 1, defaultStakerRewards.ADMIN_FEE_BASE());

        _grantAdminFeeSetRole(alice, alice);
        _setAdminFee(alice, adminFee);

        assertEq(defaultStakerRewards.adminFee(), adminFee);
    }

    function test_SetAdminFeeRevertAlreadySet(uint256 adminFee) public {
        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        adminFee = bound(adminFee, 1, defaultStakerRewards.ADMIN_FEE_BASE());

        _grantAdminFeeSetRole(alice, alice);
        _setAdminFee(alice, adminFee);

        vm.expectRevert(IDefaultStakerRewards.AlreadySet.selector);
        _setAdminFee(alice, adminFee);
    }

    function _getStakerDefaultRewards() internal returns (IDefaultStakerRewards) {
        IDefaultStakerRewards.InitParams memory params = IDefaultStakerRewards.InitParams({
            vault: address(vault),
            adminFee: 0,
            defaultAdminRoleHolder: alice,
            adminFeeClaimRoleHolder: alice,
            networkWhitelistRoleHolder: alice,
            adminFeeSetRoleHolder: alice
        });
        return IDefaultStakerRewards(defaultStakerRewardsFactory.create(params));
    }

    function _registerOperator(address user) internal {
        vm.startPrank(user);
        operatorRegistry.registerOperator();
        vm.stopPrank();
    }

    function _registerNetwork(address user, address middleware) internal {
        vm.startPrank(user);
        networkRegistry.registerNetwork();
        networkMiddlewareService.setMiddleware(middleware);
        vm.stopPrank();
    }

    function _deposit(address user, uint256 amount) internal returns (uint256 shares) {
        collateral.transfer(user, amount);
        vm.startPrank(user);
        collateral.approve(address(vault), amount);
        shares = vault.deposit(user, amount);
        vm.stopPrank();
    }

    function _withdraw(address user, uint256 amount) internal returns (uint256 burnedShares, uint256 mintedShares) {
        vm.startPrank(user);
        (burnedShares, mintedShares) = vault.withdraw(user, amount);
        vm.stopPrank();
    }

    function _grantAdminFeeSetRole(address user, address account) internal {
        vm.startPrank(user);
        Vault(address(vault)).grantRole(defaultStakerRewards.ADMIN_FEE_SET_ROLE(), account);
        vm.stopPrank();
    }

    function _distributeRewards(
        address user,
        address network,
        address token,
        uint256 amount,
        uint48 timestamp,
        uint256 maxAdminFee,
        bytes memory activeSharesHint,
        bytes memory activeStakeHint
    ) internal {
        vm.startPrank(user);
        defaultStakerRewards.distributeRewards(
            network, token, amount, abi.encode(timestamp, maxAdminFee, activeSharesHint, activeStakeHint)
        );
        vm.stopPrank();
    }

    function _claimRewards(
        address user,
        address token,
        address network,
        uint256 maxRewards,
        bytes[] memory activeSharesOfHints
    ) internal {
        vm.startPrank(user);
        defaultStakerRewards.claimRewards(user, token, abi.encode(network, maxRewards, activeSharesOfHints));
        vm.stopPrank();
    }

    function _setAdminFee(address user, uint256 adminFee) internal {
        vm.startPrank(user);
        defaultStakerRewards.setAdminFee(adminFee);
        vm.stopPrank();
    }

    function _claimAdminFee(address user, address token) internal {
        vm.startPrank(user);
        defaultStakerRewards.claimAdminFee(user, token);
        vm.stopPrank();
    }
}
