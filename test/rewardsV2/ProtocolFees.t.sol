// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";

import {ProtocolFees} from "../../src/contracts/rewardsV2/ProtocolFees.sol";
import {IProtocolFees} from "../../src/interfaces/rewardsV2/IProtocolFees.sol";
import {FeeRegistry} from "../../src/contracts/rewardsV2/FeeRegistry.sol";
import {CuratorRegistry} from "../../src/contracts/rewardsV2/CuratorRegistry.sol";
import {Token} from "@symbioticfi/core/test/mocks/Token.sol";

contract TestableProtocolFees is ProtocolFees {
    constructor(
        address feeRegistry
    ) ProtocolFees(feeRegistry) {}

    function initialize(
        address owner
    ) external initializer {
        __ProtocolFees_init(owner);
    }

    function deductProtocolFees(
        uint64 rewardsType,
        address network,
        address token,
        uint256 amount
    ) external returns (uint256 fees) {
        return _deductProtocolFees(rewardsType, network, token, amount);
    }
}

contract ProtocolFeesTest is Test {
    TestableProtocolFees protocolFees;
    FeeRegistry feeRegistry;
    CuratorRegistry curatorRegistry;
    Token token;

    address owner;
    address nonOwner;
    address recipient;

    uint64 rewardsType = 1;
    address network = address(0x123);

    event ClaimProtocolFee(address indexed token, uint256 fees);
    event DeductProtocolFee(uint64 indexed rewardsType, address indexed network, address indexed token, uint256 fees);

    function setUp() public {
        owner = address(0x1);
        nonOwner = address(0x2);
        recipient = address(0x3);

        curatorRegistry = new CuratorRegistry();
        feeRegistry = new FeeRegistry(address(curatorRegistry));
        feeRegistry.initialize(owner);

        protocolFees = new TestableProtocolFees(address(feeRegistry));
        token = new Token("ProtocolToken");

        protocolFees.initialize(owner);

        token.transfer(address(protocolFees), 1_000_000 * 10 ** 18);
    }

    function test_Initialization() public view {
        assertEq(protocolFees.owner(), owner);
        assertEq(protocolFees.FEE_REGISTRY(), address(feeRegistry));
        assertEq(protocolFees.MAX_FEE(), 1_000_000);
    }

    function test_ProtocolFee_WithNetworkSpecificFee() public {
        uint256 networkFee = 50_000; // 5%
        bytes32 networkFeeId = keccak256(abi.encode("rewards", rewardsType, network));

        vm.prank(owner);
        feeRegistry.setProtocolFee(networkFeeId, true, networkFee);

        uint256 fee = protocolFees.protocolFee(rewardsType, network);
        assertEq(fee, networkFee);
    }

    function test_ProtocolFee_WithDefaultFee() public {
        uint256 defaultFee = 30_000; // 3%
        bytes32 defaultFeeId = keccak256(abi.encode("rewards", rewardsType));

        vm.prank(owner);
        feeRegistry.setProtocolFee(defaultFeeId, true, defaultFee);

        uint256 fee = protocolFees.protocolFee(rewardsType, network);
        assertEq(fee, defaultFee);
    }

    function test_ProtocolFee_NetworkFeeTakesPrecedence() public {
        uint256 networkFee = 50_000; // 5%
        uint256 defaultFee = 30_000; // 3%

        bytes32 networkFeeId = keccak256(abi.encode("rewards", rewardsType, network));
        bytes32 defaultFeeId = keccak256(abi.encode("rewards", rewardsType));

        vm.prank(owner);
        feeRegistry.setProtocolFee(networkFeeId, true, networkFee);
        vm.prank(owner);
        feeRegistry.setProtocolFee(defaultFeeId, true, defaultFee);

        uint256 fee = protocolFees.protocolFee(rewardsType, network);
        assertEq(fee, networkFee);
    }

    function test_ProtocolFee_ReturnsZeroWhenDisabled() public {
        uint256 networkFee = 50_000;
        bytes32 networkFeeId = keccak256(abi.encode("rewards", rewardsType, network));

        vm.prank(owner);
        feeRegistry.setProtocolFee(networkFeeId, false, networkFee);

        uint256 fee = protocolFees.protocolFee(rewardsType, network);
        assertEq(fee, 0);
    }

    function test_ProtocolFee_ReturnsZeroWhenNoFeeSet() public view {
        uint256 fee = protocolFees.protocolFee(rewardsType, network);
        assertEq(fee, 0);
    }

    function test_DeductProtocolFees_WithFee() public {
        uint256 feeRate = 50_000; // 5%
        uint256 amount = 1000 * 10 ** 18;
        uint256 expectedFees = amount * feeRate / protocolFees.MAX_FEE();

        bytes32 feeId = keccak256(abi.encode("rewards", rewardsType, network));
        vm.prank(owner);
        feeRegistry.setProtocolFee(feeId, true, feeRate);

        vm.expectEmit(true, true, true, true);
        emit DeductProtocolFee(rewardsType, network, address(token), expectedFees);

        uint256 fees = protocolFees.deductProtocolFees(rewardsType, network, address(token), amount);

        assertEq(fees, expectedFees);
        assertEq(protocolFees.claimableProtocolFees(address(token)), expectedFees);
    }

    function test_DeductProtocolFees_NoFee() public {
        uint256 amount = 1000 * 10 ** 18;

        uint256 fees = protocolFees.deductProtocolFees(rewardsType, network, address(token), amount);

        assertEq(fees, 0);
        assertEq(protocolFees.claimableProtocolFees(address(token)), 0);
    }

    function test_DeductProtocolFees_AccumulatesFees() public {
        uint256 feeRate = 50_000; // 5%
        uint256 amount = 1000 * 10 ** 18;
        uint256 expectedFees = amount * feeRate / protocolFees.MAX_FEE();

        bytes32 feeId = keccak256(abi.encode("rewards", rewardsType, network));
        vm.prank(owner);
        feeRegistry.setProtocolFee(feeId, true, feeRate);

        // First deduction
        uint256 fees1 = protocolFees.deductProtocolFees(rewardsType, network, address(token), amount);
        assertEq(fees1, expectedFees);
        assertEq(protocolFees.claimableProtocolFees(address(token)), expectedFees);

        // Second deduction
        uint256 fees2 = protocolFees.deductProtocolFees(rewardsType, network, address(token), amount);
        assertEq(fees2, expectedFees);
        assertEq(protocolFees.claimableProtocolFees(address(token)), expectedFees * 2);
    }

    function test_DeductProtocolFees_DifferentTokens() public {
        Token token2 = new Token("ProtocolToken2");
        token2.transfer(address(protocolFees), 1_000_000 * 10 ** 18);

        uint256 feeRate = 50_000; // 5%
        uint256 amount = 1000 * 10 ** 18;
        uint256 expectedFees = amount * feeRate / protocolFees.MAX_FEE();

        bytes32 feeId = keccak256(abi.encode("rewards", rewardsType, network));
        vm.prank(owner);
        feeRegistry.setProtocolFee(feeId, true, feeRate);

        // Deduct fees for token1
        protocolFees.deductProtocolFees(rewardsType, network, address(token), amount);
        assertEq(protocolFees.claimableProtocolFees(address(token)), expectedFees);
        assertEq(protocolFees.claimableProtocolFees(address(token2)), 0);

        // Deduct fees for token2
        protocolFees.deductProtocolFees(rewardsType, network, address(token2), amount);
        assertEq(protocolFees.claimableProtocolFees(address(token)), expectedFees);
        assertEq(protocolFees.claimableProtocolFees(address(token2)), expectedFees);
    }

    function test_ClaimProtocolFees() public {
        uint256 feeRate = 50_000; // 5%
        uint256 amount = 1000 * 10 ** 18;
        uint256 expectedFees = amount * feeRate / protocolFees.MAX_FEE();

        bytes32 feeId = keccak256(abi.encode("rewards", rewardsType, network));
        vm.prank(owner);
        feeRegistry.setProtocolFee(feeId, true, feeRate);

        protocolFees.deductProtocolFees(rewardsType, network, address(token), amount);

        uint256 recipientBalanceBefore = token.balanceOf(recipient);

        vm.expectEmit(true, true, true, true);
        emit ClaimProtocolFee(address(token), expectedFees);

        vm.prank(owner);
        uint256 claimedFees = protocolFees.claimProtocolFees(recipient, address(token));

        assertEq(claimedFees, expectedFees);
        assertEq(token.balanceOf(recipient), recipientBalanceBefore + expectedFees);
        assertEq(protocolFees.claimableProtocolFees(address(token)), 0);
    }

    function test_ClaimProtocolFees_RevertWhen_NotOwner() public {
        uint256 feeRate = 50_000;
        uint256 amount = 1000 * 10 ** 18;

        bytes32 feeId = keccak256(abi.encode("rewards", rewardsType, network));
        vm.prank(owner);
        feeRegistry.setProtocolFee(feeId, true, feeRate);

        protocolFees.deductProtocolFees(rewardsType, network, address(token), amount);

        vm.prank(nonOwner);
        vm.expectRevert();
        protocolFees.claimProtocolFees(recipient, address(token));
    }

    function test_ClaimProtocolFees_RevertWhen_InsufficientClaimableFees() public {
        vm.prank(owner);
        vm.expectRevert(IProtocolFees.InsufficientClaimableFees.selector);
        protocolFees.claimProtocolFees(recipient, address(token));
    }

    function test_ClaimProtocolFees_MultipleTokens() public {
        Token token2 = new Token("ProtocolToken2");
        token2.transfer(address(protocolFees), 1_000_000 * 10 ** 18);

        uint256 feeRate = 50_000;
        uint256 amount = 1000 * 10 ** 18;
        uint256 expectedFees = amount * feeRate / protocolFees.MAX_FEE();

        bytes32 feeId = keccak256(abi.encode("rewards", rewardsType, network));
        vm.prank(owner);
        feeRegistry.setProtocolFee(feeId, true, feeRate);

        // Deduct fees for both tokens
        protocolFees.deductProtocolFees(rewardsType, network, address(token), amount);
        protocolFees.deductProtocolFees(rewardsType, network, address(token2), amount);

        // Claim fees for token1
        vm.prank(owner);
        uint256 claimed1 = protocolFees.claimProtocolFees(recipient, address(token));
        assertEq(claimed1, expectedFees);
        assertEq(protocolFees.claimableProtocolFees(address(token)), 0);
        assertEq(protocolFees.claimableProtocolFees(address(token2)), expectedFees);

        // Claim fees for token2
        vm.prank(owner);
        uint256 claimed2 = protocolFees.claimProtocolFees(recipient, address(token2));
        assertEq(claimed2, expectedFees);
        assertEq(protocolFees.claimableProtocolFees(address(token2)), 0);
    }

    function test_ClaimProtocolFees_PartialClaim() public {
        uint256 feeRate = 50_000;
        uint256 amount = 1000 * 10 ** 18;
        uint256 expectedFees = amount * feeRate / protocolFees.MAX_FEE();

        bytes32 feeId = keccak256(abi.encode("rewards", rewardsType, network));
        vm.prank(owner);
        feeRegistry.setProtocolFee(feeId, true, feeRate);

        // Deduct fees multiple times
        protocolFees.deductProtocolFees(rewardsType, network, address(token), amount);
        protocolFees.deductProtocolFees(rewardsType, network, address(token), amount);

        uint256 totalFees = expectedFees * 2;
        assertEq(protocolFees.claimableProtocolFees(address(token)), totalFees);

        // Claim all fees
        vm.prank(owner);
        uint256 claimed = protocolFees.claimProtocolFees(recipient, address(token));
        assertEq(claimed, totalFees);
        assertEq(protocolFees.claimableProtocolFees(address(token)), 0);
    }

    function test_MultipleRewardsTypes() public {
        uint64 rewardsType2 = 2;
        uint256 feeRate1 = 30_000; // 3%
        uint256 feeRate2 = 70_000; // 7%
        uint256 amount = 1000 * 10 ** 18;

        bytes32 feeId1 = keccak256(abi.encode("rewards", rewardsType, network));
        bytes32 feeId2 = keccak256(abi.encode("rewards", rewardsType2, network));

        vm.prank(owner);
        feeRegistry.setProtocolFee(feeId1, true, feeRate1);
        vm.prank(owner);
        feeRegistry.setProtocolFee(feeId2, true, feeRate2);

        uint256 fees1 = protocolFees.deductProtocolFees(rewardsType, network, address(token), amount);
        uint256 fees2 = protocolFees.deductProtocolFees(rewardsType2, network, address(token), amount);

        uint256 expectedFees1 = amount * feeRate1 / protocolFees.MAX_FEE();
        uint256 expectedFees2 = amount * feeRate2 / protocolFees.MAX_FEE();

        assertEq(fees1, expectedFees1);
        assertEq(fees2, expectedFees2);
        assertEq(protocolFees.claimableProtocolFees(address(token)), expectedFees1 + expectedFees2);
    }
}
