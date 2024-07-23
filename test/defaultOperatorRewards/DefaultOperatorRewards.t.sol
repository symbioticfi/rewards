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

import {DefaultOperatorRewardsFactory} from "src/contracts/defaultOperatorRewards/DefaultOperatorRewardsFactory.sol";
import {DefaultOperatorRewards} from "src/contracts/defaultOperatorRewards/DefaultOperatorRewards.sol";
import {IDefaultOperatorRewards} from "src/interfaces/defaultOperatorRewards/IDefaultOperatorRewards.sol";

import {FeeOnTransferToken} from "@symbiotic/mocks/FeeOnTransferToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DefaultOperatorRewardsTest is Test {
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

    DefaultOperatorRewardsFactory defaultOperatorRewardsFactory;
    IDefaultOperatorRewards defaultOperatorRewards;

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

        address defaultOperatorRewards_ = address(new DefaultOperatorRewards(address(networkMiddlewareService)));

        defaultOperatorRewardsFactory = new DefaultOperatorRewardsFactory(defaultOperatorRewards_);
    }

    function test_Create() public {
        defaultOperatorRewards = _getOperatorDefaultRewards();
    }

    function test_DitributeRewards(uint256 amount) public {
        amount = bound(amount, 0, 1000);

        defaultOperatorRewards = _getOperatorDefaultRewards();

        address network = alice;
        address middleware = alice;
        _registerNetwork(network, middleware);

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(middleware, 100_000 * 1e18);
        vm.startPrank(middleware);
        token.approve(address(defaultOperatorRewards), type(uint256).max);
        vm.stopPrank();

        bytes32 leaf = keccak256(abi.encode(bob, amount));
        bytes32 root = leaf;
        _distributeRewards(middleware, network, address(token), amount, root);

        assertEq(defaultOperatorRewards.root(network, address(token)), root);
        assertEq(token.balanceOf(address(defaultOperatorRewards)), amount);
    }

    function test_DitributeRewardsFeeOnTransfer(uint256 amount) public {
        amount = bound(amount, 2, 1000);

        defaultOperatorRewards = _getOperatorDefaultRewards();

        address network = alice;
        address middleware = alice;
        _registerNetwork(network, middleware);

        IERC20 feeOnTransferToken = IERC20(new FeeOnTransferToken("FeeOnTransferToken"));
        feeOnTransferToken.transfer(middleware, 100_000 * 1e18);
        vm.startPrank(middleware);
        feeOnTransferToken.approve(address(defaultOperatorRewards), type(uint256).max);
        vm.stopPrank();

        bytes32 leaf = keccak256(abi.encode(bob, amount));
        bytes32 root = leaf;
        _distributeRewards(middleware, network, address(feeOnTransferToken), amount, root);

        assertEq(defaultOperatorRewards.root(network, address(feeOnTransferToken)), root);
        assertEq(feeOnTransferToken.balanceOf(address(defaultOperatorRewards)), amount - 1);
    }

    function test_DitributeRewardsFeeOnTransferRevertInsufficientTransfer() public {
        uint256 amount = 1;

        defaultOperatorRewards = _getOperatorDefaultRewards();

        address network = alice;
        address middleware = alice;
        _registerNetwork(network, middleware);

        IERC20 feeOnTransferToken = IERC20(new FeeOnTransferToken("FeeOnTransferToken"));
        feeOnTransferToken.transfer(middleware, 100_000 * 1e18);
        vm.startPrank(middleware);
        feeOnTransferToken.approve(address(defaultOperatorRewards), type(uint256).max);
        vm.stopPrank();

        bytes32 leaf = keccak256(abi.encode(bob, amount));
        bytes32 root = leaf;
        vm.expectRevert(IDefaultOperatorRewards.InsufficientTransfer.selector);
        _distributeRewards(middleware, network, address(feeOnTransferToken), amount, root);
    }

    function test_DitributeRewardsRevertNotNetworkMiddleware(uint256 amount) public {
        amount = bound(amount, 0, 1000);

        defaultOperatorRewards = _getOperatorDefaultRewards();

        address network = alice;
        address middleware = alice;
        _registerNetwork(network, middleware);

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(middleware, 100_000 * 1e18);
        vm.startPrank(middleware);
        token.approve(address(defaultOperatorRewards), type(uint256).max);
        vm.stopPrank();

        bytes32 leaf = keccak256(abi.encode(bob, amount));
        bytes32 root = leaf;
        vm.expectRevert(IDefaultOperatorRewards.NotNetworkMiddleware.selector);
        _distributeRewards(bob, network, address(token), amount, root);
    }

    function test_ClaimRewards(uint256 amount1, uint256 amount2) public {
        amount1 = bound(amount1, 1, 1000);
        amount2 = bound(amount2, 1, 1000);

        defaultOperatorRewards = _getOperatorDefaultRewards();

        address network = alice;
        address middleware = alice;
        _registerNetwork(network, middleware);

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(middleware, 100_000 * 1e18);
        vm.startPrank(middleware);
        token.approve(address(defaultOperatorRewards), type(uint256).max);
        vm.stopPrank();

        bytes32 leaf = keccak256(abi.encode(bob, amount1));
        bytes32 root = leaf;
        _distributeRewards(middleware, network, address(token), amount1, root);

        bytes32[] memory proof;
        _claimRewards(bob, network, address(token), amount1, proof);

        assertEq(token.balanceOf(bob), amount1);
        assertEq(token.balanceOf(address(defaultOperatorRewards)), 0);
        assertEq(defaultOperatorRewards.claimed(network, address(token), bob), amount1);

        leaf = keccak256(abi.encode(bob, amount1 + amount2));
        root = leaf;
        _distributeRewards(middleware, network, address(token), amount2, root);

        assertEq(token.balanceOf(address(defaultOperatorRewards)), amount2);

        _claimRewards(bob, network, address(token), amount1 + amount2, proof);

        assertEq(token.balanceOf(bob), amount1 + amount2);
        assertEq(token.balanceOf(address(defaultOperatorRewards)), 0);
        assertEq(defaultOperatorRewards.claimed(network, address(token), bob), amount1 + amount2);
    }

    function test_ClaimRewardsRevertRootNotSet(uint256 amount1) public {
        amount1 = bound(amount1, 1, 1000);

        defaultOperatorRewards = _getOperatorDefaultRewards();

        address network = alice;
        address middleware = alice;
        _registerNetwork(network, middleware);

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(middleware, 100_000 * 1e18);
        vm.startPrank(middleware);
        token.approve(address(defaultOperatorRewards), type(uint256).max);
        vm.stopPrank();

        bytes32[] memory proof;
        vm.expectRevert(IDefaultOperatorRewards.RootNotSet.selector);
        _claimRewards(bob, network, address(token), amount1, proof);
    }

    function test_ClaimRewardsRevertInvalidProof(uint256 amount1) public {
        amount1 = bound(amount1, 1, 1000);

        defaultOperatorRewards = _getOperatorDefaultRewards();

        address network = alice;
        address middleware = alice;
        _registerNetwork(network, middleware);

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(middleware, 100_000 * 1e18);
        vm.startPrank(middleware);
        token.approve(address(defaultOperatorRewards), type(uint256).max);
        vm.stopPrank();

        bytes32 leaf = keccak256(abi.encode(bob, amount1));
        bytes32 root = leaf;
        _distributeRewards(middleware, network, address(token), amount1, root);

        bytes32[] memory proof;
        vm.expectRevert(IDefaultOperatorRewards.InvalidProof.selector);
        _claimRewards(alice, network, address(token), amount1, proof);

        vm.expectRevert(IDefaultOperatorRewards.InvalidProof.selector);
        _claimRewards(bob, network, address(token), amount1 + 1, proof);

        proof = new bytes32[](1);
        proof[0] = keccak256(abi.encode(bob, amount1));
        vm.expectRevert(IDefaultOperatorRewards.InvalidProof.selector);
        _claimRewards(bob, network, address(token), amount1 + 1, proof);
    }

    function test_ClaimRewardsRevertInsufficientTotalClaimable(uint256 amount1) public {
        amount1 = bound(amount1, 1, 1000);

        defaultOperatorRewards = _getOperatorDefaultRewards();

        address network = alice;
        address middleware = alice;
        _registerNetwork(network, middleware);

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(middleware, 100_000 * 1e18);
        vm.startPrank(middleware);
        token.approve(address(defaultOperatorRewards), type(uint256).max);
        vm.stopPrank();

        bytes32 leaf = keccak256(abi.encode(bob, amount1));
        bytes32 root = leaf;
        _distributeRewards(middleware, network, address(token), amount1, root);

        bytes32[] memory proof;
        _claimRewards(bob, network, address(token), amount1, proof);

        vm.expectRevert(IDefaultOperatorRewards.InsufficientTotalClaimable.selector);
        _claimRewards(bob, network, address(token), amount1, proof);
    }

    function test_ClaimRewardsRevertInsufficientBalance(uint256 amount1) public {
        amount1 = bound(amount1, 1, 1000);

        defaultOperatorRewards = _getOperatorDefaultRewards();

        address network = alice;
        address middleware = alice;
        _registerNetwork(network, middleware);

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(middleware, 100_000 * 1e18);
        vm.startPrank(middleware);
        token.approve(address(defaultOperatorRewards), type(uint256).max);
        vm.stopPrank();

        bytes32 leaf = keccak256(abi.encode(bob, amount1));
        bytes32 root = leaf;
        _distributeRewards(middleware, network, address(token), amount1 - 1, root);

        bytes32[] memory proof;
        vm.expectRevert(IDefaultOperatorRewards.InsufficientBalance.selector);
        _claimRewards(bob, network, address(token), amount1, proof);
    }

    function _getOperatorDefaultRewards() internal returns (IDefaultOperatorRewards) {
        return IDefaultOperatorRewards(defaultOperatorRewardsFactory.create());
    }

    function _registerNetwork(address user, address middleware) internal {
        vm.startPrank(user);
        networkRegistry.registerNetwork();
        networkMiddlewareService.setMiddleware(middleware);
        vm.stopPrank();
    }

    function _distributeRewards(address user, address network, address token, uint256 amount, bytes32 root) internal {
        vm.startPrank(user);
        defaultOperatorRewards.distributeRewards(network, token, amount, root);
        vm.stopPrank();
    }

    function _claimRewards(
        address user,
        address network,
        address token,
        uint256 totalClaimable,
        bytes32[] memory proof
    ) internal {
        vm.startPrank(user);
        defaultOperatorRewards.claimRewards(user, network, token, totalClaimable, proof);
        vm.stopPrank();
    }
}
