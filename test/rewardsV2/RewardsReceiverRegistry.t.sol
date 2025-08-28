// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";

import {RewardsReceiverRegistry} from "../../src/contracts/rewardsV2/RewardsReceiverRegistry.sol";
import {IRewardsReceiverRegistry} from "../../src/interfaces/rewardsV2/IRewardsReceiverRegistry.sol";

contract RewardsReceiverRegistryTest is Test {
    RewardsReceiverRegistry registry;

    address rewardee;
    address receiver1;
    address receiver2;

    uint64 chainId1 = 1;
    uint64 chainId2 = 137;

    function setUp() public {
        (receiver1,) = makeAddrAndKey("receiver1");
        (receiver2,) = makeAddrAndKey("receiver2");

        registry = new RewardsReceiverRegistry();
    }

    function test_SetGlobalRewardsReceiver() public {
        vm.startPrank(rewardee);

        vm.expectEmit(true, true, false, true);
        emit IRewardsReceiverRegistry.SetGlobalRewardsReceiver(rewardee, receiver1);

        registry.setGlobalRewardsReceiver(receiver1);

        address retrievedReceiver = registry.getGlobalRewardsReceiver(rewardee);
        assertEq(retrievedReceiver, receiver1);

        vm.stopPrank();
    }

    function test_SetGlobalRewardsReceiver_RevertOnZeroAddress() public {
        vm.startPrank(rewardee);

        vm.expectRevert(IRewardsReceiverRegistry.InvalidReceiver.selector);
        registry.setGlobalRewardsReceiver(address(0));

        vm.stopPrank();
    }

    function test_SetChainRewardsReceiver() public {
        vm.startPrank(rewardee);

        vm.expectEmit(true, true, true, true);
        emit IRewardsReceiverRegistry.SetChainRewardsReceiver(rewardee, chainId1, receiver1);

        registry.setChainRewardsReceiver(chainId1, receiver1);

        address retrievedReceiver = registry.getChainRewardsReceiver(rewardee, chainId1);
        assertEq(retrievedReceiver, receiver1);

        vm.stopPrank();
    }

    function test_SetChainRewardsReceiver_RevertOnZeroAddress() public {
        vm.startPrank(rewardee);

        vm.expectRevert(IRewardsReceiverRegistry.InvalidReceiver.selector);
        registry.setChainRewardsReceiver(chainId1, address(0));

        vm.stopPrank();
    }

    function test_GetChainRewardsReceiver_IndependentPerChain() public {
        vm.startPrank(rewardee);

        registry.setChainRewardsReceiver(chainId1, receiver1);
        registry.setChainRewardsReceiver(chainId2, receiver2);

        address retrievedReceiver1 = registry.getChainRewardsReceiver(rewardee, chainId1);
        address retrievedReceiver2 = registry.getChainRewardsReceiver(rewardee, chainId2);

        assertEq(retrievedReceiver1, receiver1);
        assertEq(retrievedReceiver2, receiver2);

        vm.stopPrank();
    }

    function test_GetRewardsReceiver_PrioritizesChainSpecific() public {
        vm.startPrank(rewardee);

        // Set global first
        registry.setGlobalRewardsReceiver(receiver1);

        // Set chain-specific
        registry.setChainRewardsReceiver(chainId1, receiver2);

        address retrievedReceiver = registry.getRewardsReceiver(rewardee, chainId1);
        assertEq(retrievedReceiver, receiver2); // Chain-specific should take precedence

        vm.stopPrank();
    }

    function test_GetRewardsReceiver_FallsBackToGlobal() public {
        vm.startPrank(rewardee);

        // Set only global
        registry.setGlobalRewardsReceiver(receiver1);

        address retrievedReceiver = registry.getRewardsReceiver(rewardee, chainId1);
        assertEq(retrievedReceiver, receiver1); // Should fall back to global

        vm.stopPrank();
    }

    function test_GetRewardsReceiver_ReturnsZeroWhenNeitherSet() public view {
        address retrievedReceiver = registry.getRewardsReceiver(rewardee, chainId1);
        assertEq(retrievedReceiver, address(0));
    }

    function test_GetRewardsReceiverAt_ChainSpecific() public {
        vm.startPrank(rewardee);

        registry.setChainRewardsReceiver(chainId1, receiver1);

        vm.warp(block.timestamp + 100);
        registry.setChainRewardsReceiver(chainId1, receiver2);

        // Lookup at current timestamp should return the latest receiver
        address retrieved = registry.getRewardsReceiverAt(rewardee, chainId1, uint48(block.timestamp), "");
        assertEq(retrieved, receiver2);

        vm.stopPrank();
    }

    function test_GetRewardsReceiverAt_GlobalFallback() public {
        vm.startPrank(rewardee);

        registry.setGlobalRewardsReceiver(receiver1);

        vm.warp(block.timestamp + 100);
        registry.setGlobalRewardsReceiver(receiver2);

        // Lookup at current timestamp should return the latest global receiver
        address retrieved = registry.getRewardsReceiverAt(rewardee, chainId1, uint48(block.timestamp), "");
        assertEq(retrieved, receiver2);

        vm.stopPrank();
    }

    function test_GetRewardsReceiverAt_ChainSpecificOverridesGlobal() public {
        vm.startPrank(rewardee);

        registry.setGlobalRewardsReceiver(receiver1);
        registry.setChainRewardsReceiver(chainId1, receiver2);

        // Chain-specific should override global
        address retrieved = registry.getRewardsReceiverAt(rewardee, chainId1, uint48(block.timestamp), "");
        assertEq(retrieved, receiver2);

        vm.stopPrank();
    }
}
