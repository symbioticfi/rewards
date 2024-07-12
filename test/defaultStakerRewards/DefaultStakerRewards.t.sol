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

contract RewardsTest is Test {
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
        networkVaultOptInService = new OptInService(address(networkRegistry), address(vaultFactory));
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
                address(networkVaultOptInService),
                address(operatorVaultOptInService),
                address(operatorNetworkOptInService),
                address(slasherFactory),
                slasherFactory.totalTypes()
            )
        );
        slasherFactory.whitelist(slasherImpl);

        address vetoSlasherImpl = address(
            new VetoSlasher(
                address(vaultFactory),
                address(networkMiddlewareService),
                address(networkVaultOptInService),
                address(operatorVaultOptInService),
                address(operatorNetworkOptInService),
                address(networkRegistry),
                address(slasherFactory),
                slasherFactory.totalTypes()
            )
        );
        slasherFactory.whitelist(vetoSlasherImpl);

        Token token = new Token("Token");
        collateral = new SimpleCollateral(address(token));

        collateral.mint(token.totalSupply());

        vaultConfigurator =
            new VaultConfigurator(address(vaultFactory), address(delegatorFactory), address(slasherFactory));

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

    function test_ReinitRevert() public {
        defaultStakerRewards = _getStakerDefaultRewards();

        vm.expectRevert();
        DefaultStakerRewards(address(defaultStakerRewards)).initialize(address(vault));
    }

    function test_SetNetworkWhitelistStatus() public {
        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;
        _registerNetwork(network, bob);

        _setNetworkWhitelistStatus(alice, network, true);
        assertEq(defaultStakerRewards.isNetworkWhitelisted(network), true);
    }

    function test_SetNetworkWhitelistStatusRevertAlreadySet() public {
        defaultStakerRewards = _getStakerDefaultRewards();

        address network = bob;
        _registerNetwork(network, bob);

        _setNetworkWhitelistStatus(alice, network, true);

        vm.expectRevert(IDefaultStakerRewards.AlreadySet.selector);
        _setNetworkWhitelistStatus(alice, network, true);
    }

    function test_DistributeRewards(uint256 amount, uint256 ditributeAmount, uint256 adminFee) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 2, 100 * 10 ** 18);

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

        IERC20 feeOnTransferToken = IERC20(new FeeOnTransferToken("FeeOnTransferToken"));
        feeOnTransferToken.transfer(bob, 100_000 * 1e18);
        vm.startPrank(bob);
        feeOnTransferToken.approve(address(defaultStakerRewards), type(uint256).max);
        vm.stopPrank();

        uint256 balanceBefore = feeOnTransferToken.balanceOf(address(defaultStakerRewards));
        uint256 balanceBeforeBob = feeOnTransferToken.balanceOf(bob);
        _setNetworkWhitelistStatus(alice, network, true);
        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(bob, network, address(feeOnTransferToken), ditributeAmount, timestamp);
        assertEq(feeOnTransferToken.balanceOf(address(defaultStakerRewards)) - balanceBefore, ditributeAmount - 1);
        assertEq(balanceBeforeBob - feeOnTransferToken.balanceOf(bob), ditributeAmount);

        uint256 amount__ = ditributeAmount - 1;
        uint256 adminFeeAmount = amount__.mulDiv(adminFee, defaultStakerRewards.ADMIN_FEE_BASE());
        amount__ -= adminFeeAmount;

        if (amount__ != 0) {
            assertEq(defaultStakerRewards.rewardsLength(address(feeOnTransferToken)), 1);
            (address network_, uint256 amount_, uint48 timestamp_, uint48 creation) =
                defaultStakerRewards.rewards(address(feeOnTransferToken), 0);
            assertEq(network_, network);
            assertEq(amount_, amount__);
            assertEq(timestamp_, timestamp);
            assertEq(creation, blockTimestamp);
        } else {
            assertEq(defaultStakerRewards.rewardsLength(address(feeOnTransferToken)), 0);
        }

        assertEq(defaultStakerRewards.claimableAdminFee(address(feeOnTransferToken)), adminFeeAmount);

        assertEq(
            defaultStakerRewards.claimable(address(feeOnTransferToken), alice, abi.encode(type(uint256).max)), amount__
        );
        assertEq(defaultStakerRewards.claimable(address(feeOnTransferToken), alice, abi.encode(1)), amount__);
        assertEq(defaultStakerRewards.claimable(address(feeOnTransferToken), alice, abi.encode(0)), 0);
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

        _setNetworkWhitelistStatus(alice, network, true);
        uint48 timestamp = 1_720_700_948 + 3;
        vm.expectRevert(IDefaultStakerRewards.NotNetworkMiddleware.selector);
        _distributeRewards(alice, network, address(feeOnTransferToken), ditributeAmount, timestamp);
    }

    function test_DistributeRewardsRevertNotWhitelistedNetwork(uint256 amount, uint256 ditributeAmount) public {
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
        vm.expectRevert(IDefaultStakerRewards.NotWhitelistedNetwork.selector);
        _distributeRewards(bob, network, address(feeOnTransferToken), ditributeAmount, timestamp);
    }

    function test_DistributeRewardsRevertInvalidRewardTimestamp(uint256 amount, uint256 ditributeAmount) public {
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

        _setNetworkWhitelistStatus(alice, network, true);
        vm.expectRevert(IDefaultStakerRewards.InvalidRewardTimestamp.selector);
        _distributeRewards(bob, network, address(feeOnTransferToken), ditributeAmount, uint48(blockTimestamp));
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

        _setNetworkWhitelistStatus(alice, network, true);
        uint48 timestamp = 1_720_700_948 + 3;
        vm.expectRevert(IDefaultStakerRewards.InsufficientReward.selector);
        _distributeRewards(bob, network, address(feeOnTransferToken), 1, timestamp);
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

        _setNetworkWhitelistStatus(alice, network, true);

        _distributeRewards(bob, network, address(token), ditributeAmount1, uint48(blockTimestamp - 1));

        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(bob, network, address(token), ditributeAmount2, timestamp);

        uint256 balanceBefore = token.balanceOf(alice);
        uint32[] memory activeSharesOfHints = new uint32[](2);
        _claimRewards(alice, address(token), 2, activeSharesOfHints);
        assertEq(token.balanceOf(alice) - balanceBefore, ditributeAmount1 + ditributeAmount2);

        assertEq(defaultStakerRewards.lastUnclaimedReward(alice, address(token)), 2);
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

        _setNetworkWhitelistStatus(alice, network, true);

        _distributeRewards(bob, network, address(token), ditributeAmount1, uint48(blockTimestamp - 1));

        assertEq(
            defaultStakerRewards.claimable(address(token), alice, abi.encode(type(uint256).max)),
            ditributeAmount1.mulDiv(aliceN, aliceN + bobN)
        );
        assertEq(
            defaultStakerRewards.claimable(address(token), bob, abi.encode(type(uint256).max)),
            ditributeAmount1.mulDiv(bobN, aliceN + bobN)
        );

        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(bob, network, address(token), ditributeAmount2, timestamp);

        assertEq(
            defaultStakerRewards.claimable(address(token), alice, abi.encode(type(uint256).max)),
            ditributeAmount1.mulDiv(aliceN, aliceN + bobN) + ditributeAmount2
        );
        assertEq(
            defaultStakerRewards.claimable(address(token), bob, abi.encode(type(uint256).max)),
            ditributeAmount1.mulDiv(bobN, aliceN + bobN)
        );

        uint256 balanceBefore = token.balanceOf(alice);
        uint32[] memory activeSharesOfHints = new uint32[](2);
        _claimRewards(alice, address(token), 2, activeSharesOfHints);
        assertEq(
            token.balanceOf(alice) - balanceBefore, ditributeAmount1.mulDiv(aliceN, aliceN + bobN) + ditributeAmount2
        );

        balanceBefore = token.balanceOf(bob);
        _claimRewards(bob, address(token), 2, activeSharesOfHints);
        assertEq(token.balanceOf(bob) - balanceBefore, ditributeAmount1.mulDiv(bobN, aliceN + bobN));

        assertEq(defaultStakerRewards.lastUnclaimedReward(alice, address(token)), 2);
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

        _setNetworkWhitelistStatus(alice, network, true);
        uint256 numRewards = 50;
        for (uint48 i = 1; i < numRewards + 1; ++i) {
            _distributeRewards(bob, network, address(token), ditributeAmount, 1_720_700_948 + i);
        }

        uint32[] memory activeSharesOfHints = new uint32[](0);

        uint256 gasLeft = gasleft();
        _claimRewards(alice, address(token), type(uint256).max, activeSharesOfHints);
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

        _setNetworkWhitelistStatus(alice, network, true);
        uint256 numRewards = 50;
        for (uint48 i = 1; i < numRewards + 1; ++i) {
            _distributeRewards(bob, network, address(token), ditributeAmount, 1_720_700_948 + i);
        }

        uint32[] memory activeSharesOfHints = new uint32[](numRewards);
        for (uint32 i; i < numRewards; ++i) {
            (,,, uint256 pos) = vault.activeSharesOfCheckpointAt(alice, 1_720_700_948 + i + 1);
            activeSharesOfHints[i] = uint32(pos);
        }

        uint256 gasLeft = gasleft();
        _claimRewards(alice, address(token), type(uint256).max, activeSharesOfHints);
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

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));

        uint32[] memory activeSharesOfHints = new uint32[](0);
        vm.startPrank(alice);
        vm.expectRevert(IDefaultStakerRewards.InvalidRecipient.selector);
        defaultStakerRewards.claimRewards(
            address(0), address(token), abi.encode(type(uint256).max, activeSharesOfHints)
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

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));

        uint32[] memory activeSharesOfHints = new uint32[](1);
        vm.expectRevert(IDefaultStakerRewards.NoRewardsToClaim.selector);
        _claimRewards(alice, address(token), type(uint256).max, activeSharesOfHints);
    }

    function test_ClaimRewardsRevertNoRewardsToClaim2(uint256 amount, uint256 ditributeAmount) public {
        amount = bound(amount, 1, 100 * 10 ** 18);
        ditributeAmount = bound(ditributeAmount, 1, 100 * 10 ** 18);

        uint256 blockTimestamp = block.timestamp * block.timestamp / block.timestamp * block.timestamp / block.timestamp;
        blockTimestamp = blockTimestamp + 1_720_700_948;
        vm.warp(blockTimestamp);

        defaultStakerRewards = _getStakerDefaultRewards();

        for (uint256 i; i < 10; ++i) {
            _deposit(alice, amount);

            blockTimestamp = blockTimestamp + 1;
            vm.warp(blockTimestamp);
        }

        IERC20 token = IERC20(new Token("Token"));

        uint32[] memory activeSharesOfHints = new uint32[](1);
        vm.expectRevert(IDefaultStakerRewards.NoRewardsToClaim.selector);
        _claimRewards(alice, address(token), 0, activeSharesOfHints);
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

        _setNetworkWhitelistStatus(alice, network, true);
        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(bob, network, address(token), ditributeAmount, timestamp);

        uint32[] memory activeSharesOfHints = new uint32[](2);
        vm.expectRevert(IDefaultStakerRewards.InvalidHintsLength.selector);
        _claimRewards(alice, address(token), type(uint256).max, activeSharesOfHints);
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

        _setNetworkWhitelistStatus(alice, network, true);
        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(bob, network, address(token), ditributeAmount, timestamp);

        uint256 adminFeeAmount = ditributeAmount.mulDiv(adminFee, defaultStakerRewards.ADMIN_FEE_BASE());
        vm.assume(adminFeeAmount != 0);
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

        _setNetworkWhitelistStatus(alice, network, true);
        uint48 timestamp = 1_720_700_948 + 3;
        _distributeRewards(bob, network, address(token), ditributeAmount, timestamp);

        vm.assume(defaultStakerRewards.claimableAdminFee(address(token)) != 0);
        _claimAdminFee(alice, address(token));

        vm.expectRevert(IDefaultStakerRewards.InsufficientAdminFee.selector);
        _claimAdminFee(alice, address(token));
    }

    function _getStakerDefaultRewards() internal returns (IDefaultStakerRewards) {
        return IDefaultStakerRewards(defaultStakerRewardsFactory.create(address(vault)));
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

    function _claim(address user, uint256 epoch) internal returns (uint256 amount) {
        vm.startPrank(user);
        amount = vault.claim(user, epoch);
        vm.stopPrank();
    }

    function _grantAdminFeeSetRole(address user, address account) internal {
        vm.startPrank(user);
        Vault(address(vault)).grantRole(defaultStakerRewards.ADMIN_FEE_SET_ROLE(), account);
        vm.stopPrank();
    }

    function _setNetworkWhitelistStatus(address user, address network, bool status) internal {
        vm.startPrank(user);
        defaultStakerRewards.setNetworkWhitelistStatus(network, status);
        vm.stopPrank();
    }

    function _distributeRewards(
        address user,
        address network,
        address token,
        uint256 amount,
        uint48 timestamp
    ) internal {
        vm.startPrank(user);
        defaultStakerRewards.distributeRewards(network, token, amount, abi.encode(timestamp));
        vm.stopPrank();
    }

    function _claimRewards(
        address user,
        address token,
        uint256 maxRewards,
        uint32[] memory activeSharesOfHints
    ) internal {
        vm.startPrank(user);
        defaultStakerRewards.claimRewards(user, token, abi.encode(maxRewards, activeSharesOfHints));
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

    function _claimable(address user, address token, uint256 maxRewards) internal view returns (uint256) {
        return defaultStakerRewards.claimable(user, token, abi.encode(maxRewards));
    }
}
