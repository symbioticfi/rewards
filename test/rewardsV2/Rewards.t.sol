// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {Rewards} from "../../src/contracts/rewardsV2/Rewards.sol";
import {IRewards} from "../../src/interfaces/rewardsV2/IRewards.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import {Token} from "@symbioticfi/core/test/mocks/Token.sol";
import {FeeOnTransferToken} from "../mocks/FeeOnTransferToken.sol";
import {console} from "forge-std/console.sol";

contract RewardsTest is Test {
    Rewards rewards;
    Token token;

    address network;
    address rewarder;
    address rewardee;
    address claimer;

    uint256 networkPrivateKey;
    uint256 rewarderPrivateKey;
    uint256 rewardeePrivateKey;
    uint256 claimerPrivateKey;

    // Test data
    IRewards.CumulativeDistribution testDistribution;
    IRewards.CumulativeDistributionLeaf testLeaf;
    bytes32[] testProof;
    bytes32 testMerkleRoot;

    uint48 constant TEST_TIMESTAMP = 1000;
    uint256 constant TEST_AMOUNT = 1000e18;
    uint256 constant TEST_REWARDEE_TYPE = 1;
    bytes32 constant TEST_REWARDEE_DATA_HASH = keccak256("test data");
    uint64 constant TEST_CHAIN_ID = 31_337; // Anvil default chain ID

    function setUp() public {
        (network, networkPrivateKey) = makeAddrAndKey("network");
        (rewarder, rewarderPrivateKey) = makeAddrAndKey("rewarder");
        (rewardee, rewardeePrivateKey) = makeAddrAndKey("rewardee");
        (claimer, claimerPrivateKey) = makeAddrAndKey("claimer");

        rewards = new Rewards();
        token = new Token("Mock Token");

        // Transfer tokens from deployer to rewarder for testing
        token.transfer(rewarder, TEST_AMOUNT * 10);

        // Setup test distribution
        testMerkleRoot = keccak256("test merkle root");
        testDistribution = IRewards.CumulativeDistribution({
            timestamp: TEST_TIMESTAMP,
            merkleRoot: testMerkleRoot,
            daData: "test da data"
        });

        // Setup test leaf
        testLeaf = IRewards.CumulativeDistributionLeaf({
            chainId: TEST_CHAIN_ID,
            token: address(token),
            rewardeeType: TEST_REWARDEE_TYPE,
            amount: TEST_AMOUNT,
            rewardeeDataHash: TEST_REWARDEE_DATA_HASH
        });

        // Setup test proof (simplified for testing)
        testProof = new bytes32[](1);
        testProof[0] = keccak256("test proof");

        // Set rewarder for network
        vm.prank(network);
        rewards.setRewarder(rewarder);
    }

    function test_SetRewarder() public {
        address newRewarder = makeAddr("newRewarder");

        vm.prank(network);
        rewards.setRewarder(newRewarder);

        assertEq(rewards.rewarder(network), newRewarder);
    }

    function test_AddDistributionData() public {
        bytes32 testData = keccak256("test distribution data");

        vm.prank(network);
        rewards.addDistributionData(address(token), testData);

        IRewards.DistributionData[] memory distributionData = rewards.getDistributionData(network);
        assertEq(distributionData.length, 1);
        assertEq(distributionData[0].token, address(token));
        assertEq(distributionData[0].data, testData);
    }

    function test_RemoveDistributionData() public {
        bytes32 testData = keccak256("test distribution data");

        vm.prank(network);
        rewards.addDistributionData(address(token), testData);

        vm.prank(network);
        rewards.removeDistributionData(address(token));

        IRewards.DistributionData[] memory distributionData = rewards.getDistributionData(network);
        assertEq(distributionData.length, 0);
    }

    function test_TopUpBalance() public {
        uint256 topUpAmount = 500e18;

        vm.startPrank(rewarder);
        token.approve(address(rewards), topUpAmount);
        rewards.topUpBalance(network, IRewards.TopUp({token: address(token), amount: topUpAmount}));
        vm.stopPrank();

        assertEq(rewards.balances(network, address(token)), topUpAmount);
    }

    function test_TopUpBalance_EmitsEvent() public {
        uint256 topUpAmount = 500e18;

        vm.startPrank(rewarder);
        token.approve(address(rewards), topUpAmount);

        vm.expectEmit(true, true, true, true);
        emit IRewards.TopUpBalance(network, address(token), topUpAmount);

        rewards.topUpBalance(network, IRewards.TopUp({token: address(token), amount: topUpAmount}));
        vm.stopPrank();
    }

    function test_UpdateCumulativeDistribution() public {
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT});

        vm.startPrank(rewarder);
        token.approve(address(rewards), TEST_AMOUNT);
        rewards.updateCumulativeDistribution(network, testDistribution, topUps);
        vm.stopPrank();

        (uint48 timestamp, bytes32 merkleRoot, bytes memory daData) = rewards.cumulativeDistributions(network);
        assertEq(timestamp, testDistribution.timestamp);
        assertEq(merkleRoot, testDistribution.merkleRoot);
        assertEq(daData, testDistribution.daData);
        assertTrue(rewards.isCumulativeDistributionRoot(network, testMerkleRoot));
        assertEq(rewards.balances(network, address(token)), TEST_AMOUNT);
    }

    function test_UpdateCumulativeDistribution_NotRewarder() public {
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](0);

        address nonRewarder = makeAddr("nonRewarder");
        vm.prank(nonRewarder);

        vm.expectRevert(IRewards.NotNetworkRewarder.selector);
        rewards.updateCumulativeDistribution(network, testDistribution, topUps);
    }

    function test_UpdateCumulativeDistribution_InvalidMerkleRoot() public {
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](0);
        testDistribution.merkleRoot = bytes32(0);
        vm.startPrank(rewarder);
        vm.expectRevert(IRewards.InvalidMerkleRoot.selector);
        rewards.updateCumulativeDistribution(network, testDistribution, topUps);
        vm.stopPrank();
    }

    function test_UpdateCumulativeDistribution_InvalidTimestamp() public {
        vm.startPrank(rewarder);
        IRewards.TopUp[] memory emptyTopUps = new IRewards.TopUp[](0);
        rewards.updateCumulativeDistribution(network, testDistribution, emptyTopUps);
        vm.stopPrank();

        // Try to update with older timestamp
        IRewards.CumulativeDistribution memory oldDistribution = IRewards.CumulativeDistribution({
            timestamp: uint48(block.timestamp) - 1,
            merkleRoot: keccak256("old root"),
            daData: "old data"
        });

        vm.startPrank(rewarder);
        vm.expectRevert(IRewards.InvalidTimestamp.selector);
        rewards.updateCumulativeDistribution(network, oldDistribution, emptyTopUps);
        vm.stopPrank();
    }

    function test_UpdateCumulativeDistribution_DuplicatedOrUnsortedTopUp() public {
        // Create a second token for testing
        Token token2 = new Token("Mock Token 2");
        token2.transfer(rewarder, TEST_AMOUNT * 10);

        // Create top-ups array with duplicate token addresses
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](2);
        topUps[0] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT});
        topUps[1] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT}); // Same token as first

        vm.startPrank(rewarder);
        token.approve(address(rewards), TEST_AMOUNT * 2);
        vm.expectRevert(IRewards.DuplicatedOrUnsortedTopUp.selector);
        rewards.updateCumulativeDistribution(network, testDistribution, topUps);
        vm.stopPrank();
    }

    function test_UpdateCumulativeDistribution_DuplicatedOrUnsortedTopUp_Unsorted() public {
        // Create a second token for testing
        Token token2 = new Token("Mock Token 2");
        token2.transfer(rewarder, TEST_AMOUNT * 10);

        // Create top-ups array with tokens in descending order (should trigger DuplicatedOrUnsortedTopUp)
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](2);
        topUps[0] = IRewards.TopUp({token: address(token2), amount: TEST_AMOUNT}); // Higher address
        topUps[1] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT}); // Lower address

        vm.startPrank(rewarder);
        token.approve(address(rewards), TEST_AMOUNT);
        token2.approve(address(rewards), TEST_AMOUNT);
        vm.expectRevert(IRewards.DuplicatedOrUnsortedTopUp.selector);
        rewards.updateCumulativeDistribution(network, testDistribution, topUps);
        vm.stopPrank();
    }

    function test_Claim_ValidProof() public {
        (bytes32 merkleRoot, bytes32[] memory proof) = _createMerkleTreeAndProof(testLeaf);

        IRewards.CumulativeDistribution memory distribution = IRewards.CumulativeDistribution({
            timestamp: uint48(block.timestamp),
            merkleRoot: merkleRoot,
            daData: "valid da data"
        });

        vm.startPrank(rewarder);
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT});
        token.approve(address(rewards), TEST_AMOUNT);
        rewards.updateCumulativeDistribution(network, distribution, topUps);
        vm.stopPrank();

        vm.prank(claimer);
        rewards.claim(rewardee, network, testLeaf, proof, merkleRoot);

        assertEq(rewards.claimed(network, address(token), claimer, TEST_REWARDEE_TYPE), TEST_AMOUNT);
        assertEq(rewards.balances(network, address(token)), 0);
        assertEq(token.balanceOf(rewardee), TEST_AMOUNT);
    }

    function test_Claim_RootNotSet() public {
        vm.prank(claimer);
        vm.expectRevert(IRewards.RootNotSet.selector);
        rewards.claim(rewardee, network, testLeaf, testProof, testMerkleRoot);
    }

    function test_Claim_InvalidProof() public {
        vm.startPrank(rewarder);
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT});
        token.approve(address(rewards), TEST_AMOUNT);
        rewards.updateCumulativeDistribution(network, testDistribution, topUps);
        vm.stopPrank();

        bytes32[] memory invalidProof = new bytes32[](1);
        invalidProof[0] = keccak256("invalid proof");

        vm.prank(claimer);
        vm.expectRevert(IRewards.InvalidProof.selector);
        rewards.claim(rewardee, network, testLeaf, invalidProof, testMerkleRoot);
    }

    function test_Claim_InsufficientBalance() public {
        (bytes32 merkleRoot, bytes32[] memory proof) = _createMerkleTreeAndProof(testLeaf);

        IRewards.CumulativeDistribution memory distribution = IRewards.CumulativeDistribution({
            timestamp: uint48(block.timestamp),
            merkleRoot: merkleRoot,
            daData: "valid da data"
        });

        vm.startPrank(rewarder);
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({
            token: address(token),
            amount: TEST_AMOUNT / 2 // Less than claim amount
        });
        token.approve(address(rewards), TEST_AMOUNT / 2);
        rewards.updateCumulativeDistribution(network, distribution, topUps);
        vm.stopPrank();

        vm.prank(claimer);
        vm.expectRevert();
        rewards.claim(rewardee, network, testLeaf, proof, merkleRoot);
    }

    function test_Claim_AlreadyClaimed() public {
        (bytes32 merkleRoot, bytes32[] memory proof) = _createMerkleTreeAndProof(testLeaf);

        IRewards.CumulativeDistribution memory distribution = IRewards.CumulativeDistribution({
            timestamp: uint48(block.timestamp),
            merkleRoot: merkleRoot,
            daData: "valid da data"
        });

        vm.startPrank(rewarder);
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT});
        token.approve(address(rewards), TEST_AMOUNT);
        rewards.updateCumulativeDistribution(network, distribution, topUps);
        vm.stopPrank();

        // First claim should succeed
        vm.prank(claimer);
        rewards.claim(rewardee, network, testLeaf, proof, merkleRoot);

        // Second claim should fail
        vm.prank(claimer);
        vm.expectRevert(IRewards.InsufficientClaimableAmount.selector);
        rewards.claim(rewardee, network, testLeaf, proof, merkleRoot);
    }

    function test_Claim_EmitsEvent() public {
        (bytes32 merkleRoot, bytes32[] memory proof) = _createMerkleTreeAndProof(testLeaf);

        IRewards.CumulativeDistribution memory distribution = IRewards.CumulativeDistribution({
            timestamp: uint48(block.timestamp),
            merkleRoot: merkleRoot,
            daData: "valid da data"
        });

        vm.startPrank(rewarder);
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT});
        token.approve(address(rewards), TEST_AMOUNT);
        rewards.updateCumulativeDistribution(network, distribution, topUps);
        vm.stopPrank();

        vm.expectEmit(true, true, true, true);
        emit IRewards.ClaimRewards(network, address(token), claimer, rewardee, TEST_AMOUNT);

        vm.prank(claimer);
        rewards.claim(rewardee, network, testLeaf, proof, merkleRoot);
    }

    function test_GetDistributionData() public {
        bytes32 testData1 = keccak256("test data 1");
        bytes32 testData2 = keccak256("test data 2");

        vm.startPrank(network);
        rewards.addDistributionData(address(token), testData1);
        rewards.addDistributionData(makeAddr("token2"), testData2);
        vm.stopPrank();

        IRewards.DistributionData[] memory distributionData = rewards.getDistributionData(network);
        assertEq(distributionData.length, 2);

        // Note: EnumerableMap doesn't guarantee order, so we check both possibilities
        bool found1 = false;
        bool found2 = false;
        for (uint256 i = 0; i < distributionData.length; i++) {
            if (distributionData[i].token == address(token) && distributionData[i].data == testData1) {
                found1 = true;
            }
            if (distributionData[i].token == makeAddr("token2") && distributionData[i].data == testData2) {
                found2 = true;
            }
        }
        assertTrue(found1);
        assertTrue(found2);
    }

    function test_GetDistributionData_Empty() public view {
        IRewards.DistributionData[] memory distributionData = rewards.getDistributionData(network);
        assertEq(distributionData.length, 0);
    }

    function test_Claim_PartialAmount() public {
        (bytes32 merkleRoot, bytes32[] memory proof) = _createMerkleTreeAndProof(testLeaf);

        IRewards.CumulativeDistribution memory distribution = IRewards.CumulativeDistribution({
            timestamp: uint48(block.timestamp),
            merkleRoot: merkleRoot,
            daData: "valid da data"
        });

        uint256 partialAmount = TEST_AMOUNT / 2;

        vm.startPrank(rewarder);
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(token), amount: partialAmount});
        token.approve(address(rewards), partialAmount);
        rewards.updateCumulativeDistribution(network, distribution, topUps);
        vm.stopPrank();

        // Should fail because there's insufficient balance to claim the full amount
        vm.prank(claimer);
        vm.expectRevert();
        rewards.claim(rewardee, network, testLeaf, proof, merkleRoot);
    }

    function test_Claim_InvalidChainId() public {
        // Create leaf with different chain ID than current
        uint64 wrongChainId = 1; // Ethereum mainnet
        IRewards.CumulativeDistributionLeaf memory wrongChainLeaf = IRewards.CumulativeDistributionLeaf({
            chainId: wrongChainId,
            token: address(token),
            rewardeeType: TEST_REWARDEE_TYPE,
            amount: TEST_AMOUNT,
            rewardeeDataHash: TEST_REWARDEE_DATA_HASH
        });

        (bytes32 merkleRoot, bytes32[] memory proof) = _createMerkleTreeAndProof(wrongChainLeaf);

        IRewards.CumulativeDistribution memory distribution = IRewards.CumulativeDistribution({
            timestamp: uint48(block.timestamp),
            merkleRoot: merkleRoot,
            daData: "valid da data"
        });

        vm.startPrank(rewarder);
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT});
        token.approve(address(rewards), TEST_AMOUNT);
        rewards.updateCumulativeDistribution(network, distribution, topUps);
        vm.stopPrank();

        vm.prank(claimer);
        vm.expectRevert(IRewards.InvalidChainId.selector);
        rewards.claim(rewardee, network, wrongChainLeaf, proof, merkleRoot);
    }

    function test_Claim_ZeroAmount() public {
        // Create leaf with zero amount
        IRewards.CumulativeDistributionLeaf memory zeroLeaf = IRewards.CumulativeDistributionLeaf({
            chainId: TEST_CHAIN_ID,
            token: address(token),
            rewardeeType: TEST_REWARDEE_TYPE,
            amount: 0,
            rewardeeDataHash: TEST_REWARDEE_DATA_HASH
        });

        // Create proof for zero leaf
        (bytes32 zeroRoot, bytes32[] memory zeroProof) = _createMerkleTreeAndProof(zeroLeaf);

        // Setup distribution
        IRewards.CumulativeDistribution memory distribution = IRewards.CumulativeDistribution({
            timestamp: uint48(block.timestamp),
            merkleRoot: zeroRoot,
            daData: "valid da data"
        });

        vm.startPrank(rewarder);
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT});
        token.approve(address(rewards), TEST_AMOUNT);
        rewards.updateCumulativeDistribution(network, distribution, topUps);
        vm.stopPrank();

        vm.prank(claimer);
        vm.expectRevert(IRewards.InsufficientClaimableAmount.selector);
        rewards.claim(rewardee, network, zeroLeaf, zeroProof, zeroRoot);
    }

    // Helper function to create a proper Merkle tree and proof
    function _createMerkleTreeAndProof(
        IRewards.CumulativeDistributionLeaf memory leaf
    ) internal view returns (bytes32 merkleRoot, bytes32[] memory proof) {
        // Create the leaf hash - the contract does a double hash!
        // The contract encodes as: keccak256(bytes.concat(keccak256(abi.encode(msg.sender, leaf))))
        // We need to use the claimer address as msg.sender in our test
        bytes32 leafHash = keccak256(bytes.concat(keccak256(abi.encode(claimer, leaf))));

        // Create a dummy second leaf hash for testing
        bytes32 dummyLeafHash = keccak256(bytes("dummy leaf for testing"));

        // Create the root using the same commutative hashing logic as OpenZeppelin
        if (leafHash < dummyLeafHash) {
            merkleRoot = keccak256(abi.encode(leafHash, dummyLeafHash));
        } else {
            merkleRoot = keccak256(abi.encode(dummyLeafHash, leafHash));
        }

        proof = new bytes32[](1);
        proof[0] = dummyLeafHash;

        return (merkleRoot, proof);
    }

    // Fee-on-transfer token tests
    function test_TopUpBalance_FeeOnTransferToken() public {
        FeeOnTransferToken feeToken = new FeeOnTransferToken("Fee Token", "FEE");
        uint256 topUpAmount = 1000e18;
        uint256 expectedFee = (topUpAmount * 100) / 10_000; // 1% fee
        uint256 expectedReceived = topUpAmount - expectedFee;

        // Transfer tokens from deployer to rewarder for testing
        // The transfer itself will charge a fee, so we need to transfer more
        uint256 transferAmount = topUpAmount * 10;
        feeToken.transfer(rewarder, transferAmount);

        vm.startPrank(rewarder);
        feeToken.approve(address(rewards), topUpAmount);
        rewards.topUpBalance(network, IRewards.TopUp({token: address(feeToken), amount: topUpAmount}));
        vm.stopPrank();

        // The balance should reflect the actual amount received (after fee)
        assertEq(rewards.balances(network, address(feeToken)), expectedReceived);

        // Verify the fee was charged
        assertEq(feeToken.balanceOf(address(rewards)), expectedReceived);
        // The fee token contract accumulates fees from both transfers (initial transfer to rewarder + transfer to rewards contract)
        uint256 totalFeesCollected = feeToken.balanceOf(address(feeToken));
        assertTrue(totalFeesCollected >= expectedFee); // At least the expected fee should be collected
    }

    function test_UpdateCumulativeDistribution_FeeOnTransferToken() public {
        FeeOnTransferToken feeToken = new FeeOnTransferToken("Fee Token", "FEE");
        uint256 topUpAmount = 1000e18;
        uint256 expectedFee = (topUpAmount * 100) / 10_000; // 1% fee
        uint256 expectedReceived = topUpAmount - expectedFee;

        // Transfer tokens from deployer to rewarder for testing
        feeToken.transfer(rewarder, topUpAmount * 10);

        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(feeToken), amount: topUpAmount});

        vm.startPrank(rewarder);
        feeToken.approve(address(rewards), topUpAmount);
        rewards.updateCumulativeDistribution(network, testDistribution, topUps);
        vm.stopPrank();

        // The balance should reflect the actual amount received (after fee)
        assertEq(rewards.balances(network, address(feeToken)), expectedReceived);

        // Verify the fee was charged
        assertEq(feeToken.balanceOf(address(rewards)), expectedReceived);
        // The fee token contract accumulates fees from both transfers (initial transfer to rewarder + transfer to rewards contract)
        uint256 totalFeesCollected = feeToken.balanceOf(address(feeToken));
        assertTrue(totalFeesCollected >= expectedFee); // At least the expected fee should be collected
    }

    // ========== claimRewards Function Tests ==========

    function test_ClaimRewards_ValidClaim() public {
        (bytes32 merkleRoot, bytes32[] memory proof) = _createMerkleTreeAndProof(testLeaf);
        console.log("proof length", proof.length);

        IRewards.CumulativeDistribution memory distribution = IRewards.CumulativeDistribution({
            timestamp: uint48(block.timestamp),
            merkleRoot: merkleRoot,
            daData: "valid da data"
        });

        vm.startPrank(rewarder);
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT});
        token.approve(address(rewards), TEST_AMOUNT);
        rewards.updateCumulativeDistribution(network, distribution, topUps);
        vm.stopPrank();

        // Prepare data for claimRewards function
        bytes memory claimData = abi.encode(network, merkleRoot, testLeaf, proof);

        vm.prank(claimer);
        rewards.claimRewards(rewardee, address(token), claimData);

        assertEq(rewards.claimed(network, address(token), claimer, TEST_REWARDEE_TYPE), TEST_AMOUNT);
        assertEq(rewards.balances(network, address(token)), 0);
        assertEq(token.balanceOf(rewardee), TEST_AMOUNT);
    }

    function test_ClaimRewards_InvalidToken() public {
        (bytes32 merkleRoot, bytes32[] memory proof) = _createMerkleTreeAndProof(testLeaf);

        IRewards.CumulativeDistribution memory distribution = IRewards.CumulativeDistribution({
            timestamp: uint48(block.timestamp),
            merkleRoot: merkleRoot,
            daData: "valid da data"
        });

        vm.startPrank(rewarder);
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT});
        token.approve(address(rewards), TEST_AMOUNT);
        rewards.updateCumulativeDistribution(network, distribution, topUps);
        vm.stopPrank();

        // Prepare data with wrong token
        address wrongToken = makeAddr("wrongToken");
        bytes memory claimData = abi.encode(network, merkleRoot, testLeaf, proof);

        vm.prank(claimer);
        vm.expectRevert(IRewards.InvalidClaimParams.selector);
        rewards.claimRewards(rewardee, wrongToken, claimData);
    }

    function test_ClaimRewards_RootNotSet() public {
        bytes32 nonExistentRoot = keccak256("non-existent root");
        bytes memory claimData = abi.encode(network, nonExistentRoot, testLeaf, testProof);

        vm.prank(claimer);
        vm.expectRevert(IRewards.RootNotSet.selector);
        rewards.claimRewards(rewardee, address(token), claimData);
    }

    function test_ClaimRewards_InvalidProof() public {
        vm.startPrank(rewarder);
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT});
        token.approve(address(rewards), TEST_AMOUNT);
        rewards.updateCumulativeDistribution(network, testDistribution, topUps);
        vm.stopPrank();

        bytes32[] memory invalidProof = new bytes32[](1);
        invalidProof[0] = keccak256("invalid proof");
        bytes memory claimData = abi.encode(network, testMerkleRoot, testLeaf, invalidProof);

        vm.prank(claimer);
        vm.expectRevert(IRewards.InvalidProof.selector);
        rewards.claimRewards(rewardee, address(token), claimData);
    }

    function test_ClaimRewards_EmitsEvent() public {
        (bytes32 merkleRoot, bytes32[] memory proof) = _createMerkleTreeAndProof(testLeaf);

        IRewards.CumulativeDistribution memory distribution = IRewards.CumulativeDistribution({
            timestamp: uint48(block.timestamp),
            merkleRoot: merkleRoot,
            daData: "valid da data"
        });

        vm.startPrank(rewarder);
        IRewards.TopUp[] memory topUps = new IRewards.TopUp[](1);
        topUps[0] = IRewards.TopUp({token: address(token), amount: TEST_AMOUNT});
        token.approve(address(rewards), TEST_AMOUNT);
        rewards.updateCumulativeDistribution(network, distribution, topUps);
        vm.stopPrank();

        bytes memory claimData = abi.encode(network, merkleRoot, testLeaf, proof);

        vm.expectEmit(true, true, true, true);
        emit IRewards.ClaimRewards(network, address(token), claimer, rewardee, TEST_AMOUNT);

        vm.prank(claimer);
        rewards.claimRewards(rewardee, address(token), claimData);
    }

    function test_ClaimRewards_InsufficientData() public {
        // Test with insufficient data - only encode network and merkleRoot (missing leaf and proof)
        bytes memory insufficientData = abi.encode(network, testMerkleRoot);

        vm.prank(claimer);
        vm.expectRevert(); // Should revert due to insufficient data for assembly operations
        rewards.claimRewards(rewardee, address(token), insufficientData);
    }
}
