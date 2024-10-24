// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";

import {NetworkRegistry} from "@symbioticfi/core/src/contracts/NetworkRegistry.sol";
import {NetworkMiddlewareService} from "@symbioticfi/core/src/contracts/service/NetworkMiddlewareService.sol";
import {Token} from "@symbioticfi/core/test/mocks/Token.sol";

import {DefaultOperatorRewardsFactory} from
    "../../src/contracts/defaultOperatorRewards/DefaultOperatorRewardsFactory.sol";
import {DefaultOperatorRewards} from "../../src/contracts/defaultOperatorRewards/DefaultOperatorRewards.sol";
import {IDefaultOperatorRewards} from "../../src/interfaces/defaultOperatorRewards/IDefaultOperatorRewards.sol";

import {FeeOnTransferToken} from "@symbioticfi/core/test/mocks/FeeOnTransferToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DefaultOperatorRewardsTest is Test {
    address owner;
    address alice;
    uint256 alicePrivateKey;
    address bob;
    uint256 bobPrivateKey;

    NetworkRegistry networkRegistry;
    NetworkMiddlewareService networkMiddlewareService;

    DefaultOperatorRewardsFactory defaultOperatorRewardsFactory;
    IDefaultOperatorRewards defaultOperatorRewards;

    function setUp() public {
        owner = address(this);
        (alice, alicePrivateKey) = makeAddrAndKey("alice");
        (bob, bobPrivateKey) = makeAddrAndKey("bob");

        networkRegistry = new NetworkRegistry();
        networkMiddlewareService = new NetworkMiddlewareService(address(networkRegistry));

        address defaultOperatorRewards_ = address(new DefaultOperatorRewards(address(networkMiddlewareService)));

        defaultOperatorRewardsFactory = new DefaultOperatorRewardsFactory(defaultOperatorRewards_);
    }

    function test_Create() public {
        defaultOperatorRewards = _getOperatorDefaultRewards();
    }

    function test_DitributeRewards(
        uint256 amount
    ) public {
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

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(bob, amount))));
        bytes32 root = leaf;
        _distributeRewards(middleware, network, address(token), amount, root);

        assertEq(defaultOperatorRewards.root(network, address(token)), root);
        assertEq(token.balanceOf(address(defaultOperatorRewards)), amount);
    }

    function test_DitributeRewardsFeeOnTransfer(
        uint256 amount
    ) public {
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

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(bob, amount))));
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

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(bob, amount))));
        bytes32 root = leaf;
        vm.expectRevert(IDefaultOperatorRewards.InsufficientTransfer.selector);
        _distributeRewards(middleware, network, address(feeOnTransferToken), amount, root);
    }

    function test_DitributeRewardsRevertNotNetworkMiddleware(
        uint256 amount
    ) public {
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

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(bob, amount))));
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

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(bob, amount1))));
        bytes32 root = leaf;
        _distributeRewards(middleware, network, address(token), amount1, root);

        bytes32[] memory proof;
        _claimRewards(bob, network, address(token), amount1, proof);

        assertEq(token.balanceOf(bob), amount1);
        assertEq(token.balanceOf(address(defaultOperatorRewards)), 0);
        assertEq(defaultOperatorRewards.claimed(network, address(token), bob), amount1);

        leaf = keccak256(bytes.concat(keccak256(abi.encode(bob, amount1 + amount2))));
        root = leaf;
        _distributeRewards(middleware, network, address(token), amount2, root);

        assertEq(token.balanceOf(address(defaultOperatorRewards)), amount2);

        _claimRewards(bob, network, address(token), amount1 + amount2, proof);

        assertEq(token.balanceOf(bob), amount1 + amount2);
        assertEq(token.balanceOf(address(defaultOperatorRewards)), 0);
        assertEq(defaultOperatorRewards.claimed(network, address(token), bob), amount1 + amount2);
    }

    function test_ClaimRewardsRevertRootNotSet(
        uint256 amount1
    ) public {
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

    function test_ClaimRewardsRevertInvalidProof(
        uint256 amount1
    ) public {
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

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(bob, amount1))));
        bytes32 root = leaf;
        _distributeRewards(middleware, network, address(token), amount1, root);

        bytes32[] memory proof;
        vm.expectRevert(IDefaultOperatorRewards.InvalidProof.selector);
        _claimRewards(alice, network, address(token), amount1, proof);

        vm.expectRevert(IDefaultOperatorRewards.InvalidProof.selector);
        _claimRewards(bob, network, address(token), amount1 + 1, proof);

        proof = new bytes32[](1);
        proof[0] = keccak256(bytes.concat(keccak256(abi.encode(bob, amount1))));
        vm.expectRevert(IDefaultOperatorRewards.InvalidProof.selector);
        _claimRewards(bob, network, address(token), amount1 + 1, proof);
    }

    function test_ClaimRewardsRevertInsufficientTotalClaimable(
        uint256 amount1
    ) public {
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

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(bob, amount1))));
        bytes32 root = leaf;
        _distributeRewards(middleware, network, address(token), amount1, root);

        bytes32[] memory proof;
        _claimRewards(bob, network, address(token), amount1, proof);

        vm.expectRevert(IDefaultOperatorRewards.InsufficientTotalClaimable.selector);
        _claimRewards(bob, network, address(token), amount1, proof);
    }

    function test_ClaimRewardsRevertInsufficientBalance(
        uint256 amount1
    ) public {
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

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(bob, amount1))));
        bytes32 root = leaf;
        _distributeRewards(middleware, network, address(token), amount1 - 1, root);

        bytes32[] memory proof;
        vm.expectRevert(IDefaultOperatorRewards.InsufficientBalance.selector);
        _claimRewards(bob, network, address(token), amount1, proof);
    }

    function test_ClaimRewardsCustom() public {
        defaultOperatorRewards = _getOperatorDefaultRewards();

        address network = alice;
        address middleware = alice;
        _registerNetwork(network, middleware);

        IERC20 token = IERC20(new Token("Token"));
        token.transfer(middleware, 100_000 * 1e18);
        vm.startPrank(middleware);
        token.approve(address(defaultOperatorRewards), type(uint256).max);
        vm.stopPrank();

        address operator = 0x0000000000000000000000000000000000000003;
        uint256 amount = 600_000_000_000_000_000;
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = 0x92864efb389a13533b2b5d94eda464bce7dbe336d06c6d5feb673c30460c10ee;
        proof[1] = 0xb77d490dc0f9580cc767909bba59fd55900dec274b637ed820a391c018c8858a;
        bytes32 root = 0x1421466e8f910cab140a44dd533adb90ebc2d87e0ab91e851737a77ecd394224;

        _distributeRewards(middleware, network, address(token), amount, root);

        _claimRewards(operator, network, address(token), amount, proof);
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
