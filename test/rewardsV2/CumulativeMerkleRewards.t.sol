// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Vm} from "forge-std/Vm.sol";

import {CumulativeMerkleRewards} from "../../src/contracts/rewardsV2/CumulativeMerkleRewards.sol";
import {ProtocolFees} from "../../src/contracts/rewardsV2/ProtocolFees.sol";
import {ICumulativeMerkleRewards} from "../../src/interfaces/rewardsV2/ICumulativeMerkleRewards.sol";

import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {RewardsV2TestBase} from "./RewardsV2TestBase.sol";
import {Token} from "@symbioticfi/core/test/mocks/Token.sol";
import {FeeOnTransferToken} from "@symbioticfi/core/test/mocks//FeeOnTransferToken.sol";
import {MerkleTreeUtils} from "../mocks/MerkleTreeUtils.sol";

/**
 * @title TestCumulativeMerkleRewards
 * @notice Concrete implementation of CumulativeMerkleRewards for testing
 */
contract TestCumulativeMerkleRewards is CumulativeMerkleRewards {
    constructor(
        address feeRegistry
    ) ProtocolFees(feeRegistry) {}

    function initialize(
        address owner
    ) external initializer {
        __CumulativeMerkleRewards_init();
        __ProtocolFees_init(owner);
    }

    /**
     * @notice Expose internal function for testing
     */
    function hashCumulativeDistributionPayload(
        CumulativeDistribution calldata cumulativeDistribution,
        TokenAmount[] calldata totalAmounts
    ) external view returns (bytes32) {
        return _hashCumulativeDistributionPayload(cumulativeDistribution, totalAmounts);
    }
}

contract CumulativeMerkleRewardsTest is RewardsV2TestBase {
    TestCumulativeMerkleRewards cumulativeMerkleRewards;
    FeeOnTransferToken feeToken;
    MerkleTreeUtils merkleUtils;

    address owner;
    address rewarder;
    address recipient;
    address network;
    address alice;
    address bob;

    uint256 constant DEPOSIT_AMOUNT = 100_000e18;
    uint256 constant REWARD_AMOUNT1 = 1000e18;
    uint256 constant REWARD_AMOUNT2 = 2000e18;

    function setUp() public {
        owner = vm.addr(1);
        rewarder = vm.addr(2);
        recipient = makeAddr("recipient");
        network = makeAddr("network");
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        _deployRewardsInfra(owner);
        _registerNetwork(network);

        feeToken = new FeeOnTransferToken("Fee Token");
        merkleUtils = new MerkleTreeUtils();

        cumulativeMerkleRewards = new TestCumulativeMerkleRewards(address(feeRegistry));
        cumulativeMerkleRewards.initialize(owner);
        vm.prank(owner);
        cumulativeMerkleRewards.setProtocol(owner);

        rewardsToken.transfer(alice, DEPOSIT_AMOUNT);
        rewardsToken.transfer(bob, DEPOSIT_AMOUNT);

        vm.prank(network);
        cumulativeMerkleRewards.setRewarder(rewarder);

        // Deposit tokens
        vm.prank(alice);
        rewardsToken.approve(address(cumulativeMerkleRewards), DEPOSIT_AMOUNT);
        vm.prank(alice);
        cumulativeMerkleRewards.depositCumulativeMerkleRewards(network, address(rewardsToken), DEPOSIT_AMOUNT);

        vm.prank(bob);
        rewardsToken.approve(address(cumulativeMerkleRewards), DEPOSIT_AMOUNT);
        vm.prank(bob);
        cumulativeMerkleRewards.depositCumulativeMerkleRewards(network, address(rewardsToken), DEPOSIT_AMOUNT);
    }

    /* ============ Tests for distributeCumulativeMerkleRewards ============ */

    function test_DistributeCumulativeMerkleRewards() public {
        // Create merkle tree
        ICumulativeMerkleRewards.CumulativeDistributionLeaf[] memory leaves =
            new ICumulativeMerkleRewards.CumulativeDistributionLeaf[](2);
        leaves[0] = ICumulativeMerkleRewards.CumulativeDistributionLeaf({
            chainId: 31_337,
            token: address(rewardsToken),
            rewardeeType: 1,
            amount: REWARD_AMOUNT1,
            rewardeeDataHash: keccak256("alice-data")
        });
        leaves[1] = ICumulativeMerkleRewards.CumulativeDistributionLeaf({
            chainId: 31_337,
            token: address(rewardsToken),
            rewardeeType: 2,
            amount: REWARD_AMOUNT2,
            rewardeeDataHash: keccak256("bob-data")
        });

        (bytes32 root,) = createMerkleTree(leaves);

        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({timestamp: uint48(block.timestamp), merkleRoot: root});

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: 31_337, // Use the actual test chain ID
            token: address(rewardsToken),
            amount: 3000e18
        });

        // Create signatures
        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        // Execute distribution
        vm.prank(owner);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );

        // Verify state changes
        assertTrue(cumulativeMerkleRewards.isCumulativeDistributionRoot(network, root), "Root should be set");
        assertEq(
            cumulativeMerkleRewards.lastCumulativeDistribution(network).timestamp,
            distribution.timestamp,
            "Timestamp should be updated"
        );
        assertEq(cumulativeMerkleRewards.lastCumulativeDistribution(network).merkleRoot, root, "Root should be updated");
        assertEq(
            cumulativeMerkleRewards.lastTotalAmount(network, address(rewardsToken)),
            3000e18,
            "Total amount should be updated"
        );
    }

    function test_DistributeCumulativeMerkleRewards_InvalidOwnerSignature() public {
        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({
                timestamp: uint48(block.timestamp), merkleRoot: keccak256("test-root")
            });

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid), token: address(rewardsToken), amount: REWARD_AMOUNT1
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory invalidOwnerSignature = createTypedDataSignature(alice, hash); // Wrong signer
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        vm.prank(owner);
        vm.expectRevert(ICumulativeMerkleRewards.InvalidSignature.selector);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, invalidOwnerSignature, rewarderSignature
        );
    }

    function test_DistributeCumulativeMerkleRewards_InvalidRewarderSignature() public {
        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({
                timestamp: uint48(block.timestamp), merkleRoot: keccak256("test-root")
            });

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid), token: address(rewardsToken), amount: REWARD_AMOUNT1
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory invalidRewarderSignature = createTypedDataSignature(alice, hash); // Wrong signer

        vm.prank(owner);
        vm.expectRevert(ICumulativeMerkleRewards.InvalidSignature.selector);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, invalidRewarderSignature
        );
    }

    function test_DistributeCumulativeMerkleRewards_RootAlreadySet() public {
        bytes32 root = keccak256("test-root");

        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({timestamp: uint48(block.timestamp), merkleRoot: root});

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid), token: address(rewardsToken), amount: REWARD_AMOUNT1
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        // First distribution should succeed
        vm.prank(owner);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );

        // Second distribution with same root should fail
        vm.prank(owner);
        vm.expectRevert(ICumulativeMerkleRewards.RootAlreadySet.selector);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );
    }

    function test_DistributeCumulativeMerkleRewards_InvalidTimestamp() public {
        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({
                timestamp: uint48(block.timestamp), merkleRoot: keccak256("test-root")
            });

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid), token: address(rewardsToken), amount: REWARD_AMOUNT1
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        // First distribution
        vm.prank(owner);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );

        // Second distribution with same timestamp should fail
        distribution.timestamp = uint48(block.timestamp); // Same timestamp
        distribution.merkleRoot = keccak256("different-root"); // Different root to avoid RootAlreadySet
        hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        ownerSignature = createTypedDataSignature(owner, hash);
        rewarderSignature = createTypedDataSignature(rewarder, hash);

        vm.prank(owner);
        vm.expectRevert(ICumulativeMerkleRewards.InvalidTimestamp.selector);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );
    }

    function test_DistributeCumulativeMerkleRewards_UnsortedChainIds() public {
        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({
                timestamp: uint48(block.timestamp), merkleRoot: keccak256("test-root")
            });

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](2);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: 2, // Higher chain ID first
            token: address(rewardsToken),
            amount: REWARD_AMOUNT2
        });
        totalAmounts[1] = ICumulativeMerkleRewards.TokenAmount({
            chainId: 1, // Lower chain ID second - should fail
            token: address(rewardsToken),
            amount: REWARD_AMOUNT1
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        vm.prank(owner);
        vm.expectRevert(ICumulativeMerkleRewards.UnsortedChainIds.selector);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );
    }

    function test_DistributeCumulativeMerkleRewards_DuplicateTokens() public {
        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({
                timestamp: uint48(block.timestamp), merkleRoot: keccak256("test-root")
            });

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](2);
        totalAmounts[0] =
            ICumulativeMerkleRewards.TokenAmount({chainId: 1, token: address(rewardsToken), amount: REWARD_AMOUNT1});
        totalAmounts[1] = ICumulativeMerkleRewards.TokenAmount({
            chainId: 1,
            token: address(rewardsToken), // Same token - should fail
            amount: REWARD_AMOUNT2
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        vm.prank(owner);
        vm.expectRevert(ICumulativeMerkleRewards.DuplicateOrUnsortedTokens.selector);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );
    }

    function test_DistributeCumulativeMerkleRewards_InsufficientDeposited() public {
        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({
                timestamp: uint48(block.timestamp), merkleRoot: keccak256("test-root")
            });

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid),
            token: address(rewardsToken),
            amount: 500_000e18 // More than deposited
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        vm.prank(owner);
        vm.expectRevert();
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );
    }

    /* ============ Tests for depositCumulativeMerkleRewards ============ */

    function test_DepositCumulativeMerkleRewards() public {
        uint256 depositAmount = 50_000e18;

        // Provide additional balance to Alice for this test
        rewardsToken.transfer(alice, depositAmount);

        vm.prank(alice);
        rewardsToken.approve(address(cumulativeMerkleRewards), depositAmount);

        vm.prank(alice);
        cumulativeMerkleRewards.depositCumulativeMerkleRewards(network, address(rewardsToken), depositAmount);

        assertEq(
            cumulativeMerkleRewards.balance(network, address(rewardsToken)),
            DEPOSIT_AMOUNT * 2 + depositAmount,
            "Balance should be updated"
        );
    }

    function test_DepositCumulativeMerkleRewards_InsufficientTransfer() public {
        // Test with zero amount
        vm.prank(alice);
        rewardsToken.approve(address(cumulativeMerkleRewards), 0);

        vm.prank(alice);
        vm.expectRevert(ICumulativeMerkleRewards.InsufficientTransfer.selector);
        cumulativeMerkleRewards.depositCumulativeMerkleRewards(network, address(rewardsToken), 0);
    }

    function test_DepositCumulativeMerkleRewards_WithFeeOnTransferToken() public {
        uint256 depositAmount = 100_000e18;
        uint256 transferAmount = depositAmount + 1;

        // Transfer enough tokens so alice can cover the fee-on-transfer and still deposit the desired amount
        feeToken.transfer(alice, transferAmount);
        assertGe(feeToken.balanceOf(alice), depositAmount, "Alice balance should cover requested deposit");

        uint256 balanceBefore = feeToken.balanceOf(address(cumulativeMerkleRewards));

        vm.prank(alice);
        feeToken.approve(address(cumulativeMerkleRewards), depositAmount);

        vm.prank(alice);
        cumulativeMerkleRewards.depositCumulativeMerkleRewards(network, address(feeToken), depositAmount);

        uint256 balanceAfter = feeToken.balanceOf(address(cumulativeMerkleRewards));
        uint256 actualDeposited = balanceAfter - balanceBefore;
        uint256 expectedFee = 1;
        uint256 expectedDeposited = depositAmount - expectedFee;

        // Verify the withdrawable amount matches the actual deposited amount
        assertEq(
            cumulativeMerkleRewards.balance(network, address(feeToken)),
            expectedDeposited,
            "Withdrawable amount should match actual deposited"
        );

        // Verify that the actual deposited amount matches the expected net amount
        assertEq(actualDeposited, expectedDeposited, "Deposited amount should account for transfer fee");
        assertTrue(actualDeposited < depositAmount, "Actual deposited amount should be less due to fee");
        assertTrue(actualDeposited > 0, "Some amount should be deposited");
    }

    /* ============ Tests for withdrawCumulativeMerkleRewards ============ */

    function test_WithdrawCumulativeMerkleRewards() public {
        uint256 withdrawAmount = 10_000e18;

        vm.expectEmit(true, true, false, true);
        emit ICumulativeMerkleRewards.WithdrawCumulativeMerkleRewards(network, address(rewardsToken), withdrawAmount);

        vm.prank(rewarder);
        cumulativeMerkleRewards.withdrawCumulativeMerkleRewards(
            recipient, network, address(rewardsToken), withdrawAmount
        );

        assertEq(rewardsToken.balanceOf(recipient), withdrawAmount, "Recipient should receive tokens");
        assertEq(
            cumulativeMerkleRewards.balance(network, address(rewardsToken)),
            DEPOSIT_AMOUNT * 2 - withdrawAmount,
            "Balance should be reduced"
        );
    }

    function test_WithdrawCumulativeMerkleRewards_NotRewarder() public {
        vm.prank(alice);
        vm.expectRevert(ICumulativeMerkleRewards.NotRewarder.selector);
        cumulativeMerkleRewards.withdrawCumulativeMerkleRewards(
            recipient, network, address(rewardsToken), REWARD_AMOUNT1
        );
    }

    function test_WithdrawCumulativeMerkleRewards_InsufficientDeposited() public {
        vm.prank(rewarder);
        vm.expectRevert();
        cumulativeMerkleRewards.withdrawCumulativeMerkleRewards(recipient, network, address(rewardsToken), 500_000e18);
    }

    /* ============ Tests for claimCumulativeMerkleRewards ============ */

    function test_ClaimCumulativeMerkleRewards() public {
        ICumulativeMerkleRewards.CumulativeDistributionLeaf[] memory leaves =
            new ICumulativeMerkleRewards.CumulativeDistributionLeaf[](1);
        leaves[0] = ICumulativeMerkleRewards.CumulativeDistributionLeaf({
            chainId: uint64(block.chainid),
            token: address(rewardsToken),
            rewardeeType: 1,
            amount: REWARD_AMOUNT1,
            rewardeeDataHash: keccak256("alice-data")
        });

        (bytes32 root, bytes32[][] memory proofs) = createMerkleTree(leaves);

        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({timestamp: uint48(block.timestamp), merkleRoot: root});

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid), token: address(rewardsToken), amount: REWARD_AMOUNT1
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        vm.prank(owner);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );

        uint256 balanceBefore = rewardsToken.balanceOf(recipient);

        vm.expectEmit(true, true, false, true);
        emit ICumulativeMerkleRewards.ClaimCumulativeMerkleRewards(address(this), network, leaves[0]);

        cumulativeMerkleRewards.claimCumulativeMerkleRewards(recipient, network, leaves[0], proofs[0], root);

        assertEq(
            rewardsToken.balanceOf(recipient), balanceBefore + REWARD_AMOUNT1, "Recipient should receive claimed amount"
        );
        assertEq(
            cumulativeMerkleRewards.claimed(network, address(rewardsToken), address(this), 1),
            REWARD_AMOUNT1,
            "Claimed amount should be recorded"
        );
    }

    function test_ClaimCumulativeMerkleRewards_InvalidMerkleRoot() public {
        ICumulativeMerkleRewards.CumulativeDistributionLeaf memory leaf =
            ICumulativeMerkleRewards.CumulativeDistributionLeaf({
                chainId: uint64(block.chainid),
                token: address(rewardsToken),
                rewardeeType: 1,
                amount: REWARD_AMOUNT1,
                rewardeeDataHash: keccak256("alice-data")
            });

        bytes32[] memory proof = new bytes32[](0);
        bytes32 invalidRoot = keccak256("invalid-root");

        vm.expectRevert(ICumulativeMerkleRewards.InvalidMerkleRoot.selector);
        cumulativeMerkleRewards.claimCumulativeMerkleRewards(recipient, network, leaf, proof, invalidRoot);
    }

    function test_ClaimCumulativeMerkleRewards_InvalidProof() public {
        // First distribute rewards
        ICumulativeMerkleRewards.CumulativeDistributionLeaf[] memory leaves =
            new ICumulativeMerkleRewards.CumulativeDistributionLeaf[](1);
        leaves[0] = ICumulativeMerkleRewards.CumulativeDistributionLeaf({
            chainId: uint64(block.chainid),
            token: address(rewardsToken),
            rewardeeType: 1,
            amount: REWARD_AMOUNT1,
            rewardeeDataHash: keccak256("alice-data")
        });

        (bytes32 root,) = createMerkleTree(leaves);

        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({timestamp: uint48(block.timestamp), merkleRoot: root});

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid), token: address(rewardsToken), amount: REWARD_AMOUNT1
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        vm.prank(owner);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );

        // Try to claim with invalid proof
        bytes32[] memory invalidProof = new bytes32[](1);
        invalidProof[0] = keccak256("invalid-proof");

        vm.expectRevert(ICumulativeMerkleRewards.InvalidMerkleRoot.selector);
        cumulativeMerkleRewards.claimCumulativeMerkleRewards(recipient, network, leaves[0], invalidProof, root);
    }

    function test_ClaimCumulativeMerkleRewards_NoRewardsToClaim() public {
        // First distribute rewards
        ICumulativeMerkleRewards.CumulativeDistributionLeaf[] memory leaves =
            new ICumulativeMerkleRewards.CumulativeDistributionLeaf[](1);
        leaves[0] = ICumulativeMerkleRewards.CumulativeDistributionLeaf({
            chainId: uint64(block.chainid),
            token: address(rewardsToken),
            rewardeeType: 1,
            amount: REWARD_AMOUNT1,
            rewardeeDataHash: keccak256("alice-data")
        });

        (bytes32 root, bytes32[][] memory proofs) = createMerkleTree(leaves);

        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({timestamp: uint48(block.timestamp), merkleRoot: root});

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid), token: address(rewardsToken), amount: REWARD_AMOUNT1
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        vm.prank(owner);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );

        // Claim once
        cumulativeMerkleRewards.claimCumulativeMerkleRewards(recipient, network, leaves[0], proofs[0], root);

        // Try to claim again - should fail
        vm.expectRevert(ICumulativeMerkleRewards.NoCumulativeRewardsToClaim.selector);
        cumulativeMerkleRewards.claimCumulativeMerkleRewards(recipient, network, leaves[0], proofs[0], root);
    }

    /* ============ Tests for setRewarder ============ */

    function test_SetRewarder() public {
        address newRewarder = makeAddr("newRewarder");

        vm.expectEmit(true, false, false, true);
        emit ICumulativeMerkleRewards.SetRewarder(network, newRewarder);

        vm.prank(network);
        cumulativeMerkleRewards.setRewarder(newRewarder);

        assertEq(cumulativeMerkleRewards.rewarder(network), newRewarder, "Rewarder should be updated");
    }

    /* ============ Tests for claimRewards ============ */

    function test_ClaimRewards() public {
        // First distribute rewards
        ICumulativeMerkleRewards.CumulativeDistributionLeaf[] memory leaves =
            new ICumulativeMerkleRewards.CumulativeDistributionLeaf[](1);
        leaves[0] = ICumulativeMerkleRewards.CumulativeDistributionLeaf({
            chainId: uint64(block.chainid),
            token: address(rewardsToken),
            rewardeeType: 1,
            amount: REWARD_AMOUNT1,
            rewardeeDataHash: keccak256("alice-data")
        });

        (bytes32 root, bytes32[][] memory proofs) = createMerkleTree(leaves);

        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({timestamp: uint48(block.timestamp), merkleRoot: root});

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid), token: address(rewardsToken), amount: REWARD_AMOUNT1
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        vm.prank(owner);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );

        // Encode claim data
        bytes memory data = abi.encode(
            network, // 32 bytes
            root, // 32 bytes
            leaves[0], // 160 bytes
            uint256(proofs[0].length), // 32 bytes
            proofs[0] // dynamic
        );

        uint256 balanceBefore = rewardsToken.balanceOf(recipient);

        cumulativeMerkleRewards.claimRewards(recipient, address(rewardsToken), data);

        assertEq(
            rewardsToken.balanceOf(recipient), balanceBefore + REWARD_AMOUNT1, "Recipient should receive claimed amount"
        );
    }

    function test_ClaimRewards_InvalidToken() public {
        ICumulativeMerkleRewards.CumulativeDistributionLeaf memory leaf =
            ICumulativeMerkleRewards.CumulativeDistributionLeaf({
                chainId: uint64(block.chainid),
                token: address(rewardsToken),
                rewardeeType: 1,
                amount: REWARD_AMOUNT1,
                rewardeeDataHash: keccak256("alice-data")
            });

        bytes32[] memory proof = new bytes32[](0);
        bytes32 root = keccak256("test-root");

        bytes memory data = abi.encode(
            network, // 32 bytes
            root, // 32 bytes
            leaf, // 160 bytes
            uint256(0), // 32 bytes
            proof // dynamic
        );

        vm.expectRevert(ICumulativeMerkleRewards.InvalidToken.selector);
        cumulativeMerkleRewards.claimRewards(recipient, makeAddr("differentToken"), data);
    }

    /* ============ Tests for hashCumulativeDistributionPayload ============ */

    function test_HashCumulativeDistributionPayloadWithEIP712() public {
        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({
                timestamp: uint48(block.timestamp), merkleRoot: keccak256("test-root")
            });

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](2);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid), token: address(rewardsToken), amount: 1000e18
        });
        totalAmounts[1] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid + 1), token: address(rewardsToken), amount: 2000e18
        });

        // Get hash from our function
        bytes32 ourHash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);

        string memory CUMULATIVE_DISTRIBUTION_TYPEDEF = "CumulativeDistribution(uint48 timestamp,bytes32 merkleRoot)";

        string memory TOKEN_AMOUNT_TYPEDEF = "TokenAmount(uint64 chainId,address token,uint256 amount)";

        string memory PAYLOAD_TYPEDEF =
            "CumulativeDistributionPayload(CumulativeDistribution cumulativeDistribution,TokenAmount[] totalAmounts)CumulativeDistribution(uint48 timestamp,bytes32 merkleRoot)TokenAmount(uint64 chainId,address token,uint256 amount)";

        bytes32 cumulativeDistributionHash = vm.eip712HashStruct(
            CUMULATIVE_DISTRIBUTION_TYPEDEF, abi.encode(distribution.timestamp, distribution.merkleRoot)
        );
        bytes32[] memory tokenAmountHashes = new bytes32[](totalAmounts.length);
        for (uint256 i = 0; i < totalAmounts.length; i++) {
            tokenAmountHashes[i] = vm.eip712HashStruct(
                TOKEN_AMOUNT_TYPEDEF, abi.encode(totalAmounts[i].chainId, totalAmounts[i].token, totalAmounts[i].amount)
            );
        }
        bytes32 totalAmountsHash = keccak256(abi.encodePacked(tokenAmountHashes));
        bytes32 payloadTypeHash = vm.eip712HashType(PAYLOAD_TYPEDEF);
        bytes32 structHash = keccak256(abi.encode(payloadTypeHash, cumulativeDistributionHash, totalAmountsHash));
        bytes32 EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version)");
        bytes32 domainSeparator = keccak256(
            abi.encode(EIP712_DOMAIN_TYPEHASH, keccak256(bytes("CumulativeMerkleRewards")), keccak256(bytes("1")))
        );
        bytes32 expected = MessageHashUtils.toTypedDataHash(domainSeparator, structHash);
        assertEq(ourHash, expected, "Hash should follow EIP712 specification");
    }

    /* ============ View function tests ============ */

    function test_LastCumulativeDistribution() public {
        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({
                timestamp: uint48(block.timestamp), merkleRoot: keccak256("test-root")
            });

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid), token: address(rewardsToken), amount: REWARD_AMOUNT1
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        vm.prank(owner);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );

        ICumulativeMerkleRewards.CumulativeDistribution memory lastDistribution =
            cumulativeMerkleRewards.lastCumulativeDistribution(network);
        assertEq(lastDistribution.timestamp, distribution.timestamp, "Timestamp should match");
        assertEq(lastDistribution.merkleRoot, distribution.merkleRoot, "Root should match");
    }

    function test_LastTotalAmount() public {
        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({
                timestamp: uint48(block.timestamp), merkleRoot: keccak256("test-root")
            });

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid), token: address(rewardsToken), amount: REWARD_AMOUNT1
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        vm.prank(owner);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );

        assertEq(
            cumulativeMerkleRewards.lastTotalAmount(network, address(rewardsToken)),
            REWARD_AMOUNT1,
            "Total amount should match"
        );
    }

    function test_IsCumulativeDistributionRoot() public {
        bytes32 root = keccak256("test-root");

        assertFalse(
            cumulativeMerkleRewards.isCumulativeDistributionRoot(network, root), "Root should not exist initially"
        );

        ICumulativeMerkleRewards.CumulativeDistribution memory distribution =
            ICumulativeMerkleRewards.CumulativeDistribution({timestamp: uint48(block.timestamp), merkleRoot: root});

        ICumulativeMerkleRewards.TokenAmount[] memory totalAmounts = new ICumulativeMerkleRewards.TokenAmount[](1);
        totalAmounts[0] = ICumulativeMerkleRewards.TokenAmount({
            chainId: uint64(block.chainid), token: address(rewardsToken), amount: REWARD_AMOUNT1
        });

        bytes32 hash = cumulativeMerkleRewards.hashCumulativeDistributionPayload(distribution, totalAmounts);
        bytes memory ownerSignature = createTypedDataSignature(owner, hash);
        bytes memory rewarderSignature = createTypedDataSignature(rewarder, hash);

        vm.prank(owner);
        cumulativeMerkleRewards.distributeCumulativeMerkleRewards(
            network, distribution, totalAmounts, ownerSignature, rewarderSignature
        );

        assertTrue(
            cumulativeMerkleRewards.isCumulativeDistributionRoot(network, root), "Root should exist after distribution"
        );
    }

    /* ============ Helper Functions ============ */

    function createMerkleTree(
        ICumulativeMerkleRewards.CumulativeDistributionLeaf[] memory leaves
    ) internal returns (bytes32 root, bytes32[][] memory proofs) {
        bytes32[] memory leafHashes = new bytes32[](leaves.length);

        for (uint256 i = 0; i < leaves.length; i++) {
            leafHashes[i] = keccak256(abi.encode(address(this), leaves[i]));
        }

        (root, proofs) = merkleUtils.createMerkleTree(leafHashes);
    }

    function createEIP712Signature(
        address signer,
        bytes32 hash
    ) internal returns (bytes memory signature) {
        uint256 privateKey = uint256(uint160(signer));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, MessageHashUtils.toEthSignedMessageHash(hash));
        signature = abi.encodePacked(r, s, v);
    }

    function createTypedDataSignature(
        address signer,
        bytes32 hash
    ) internal returns (bytes memory signature) {
        uint256 privateKey = 1;
        if (signer == rewarder) {
            privateKey = 2;
        } else if (signer == alice) {
            privateKey = 3;
        }
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, hash);
        signature = abi.encodePacked(r, s, v);
    }
}
