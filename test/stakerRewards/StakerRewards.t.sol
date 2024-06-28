// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";

import {NetworkRegistry} from "@symbiotic/contracts/NetworkRegistry.sol";

import {SimpleStakerRewards} from "test/mocks/SimpleStakerRewards.sol";

contract StakerRewardsTest is Test {
    address owner;
    address alice;
    uint256 alicePrivateKey;
    address bob;
    uint256 bobPrivateKey;

    NetworkRegistry networkRegistry;
    SimpleStakerRewards stakerRewards;

    function setUp() public {
        owner = address(this);
        (alice, alicePrivateKey) = makeAddrAndKey("alice");
        (bob, bobPrivateKey) = makeAddrAndKey("bob");

        networkRegistry = new NetworkRegistry();
        stakerRewards = new SimpleStakerRewards();
    }

    function test_Create() public {
        assertEq(stakerRewards.version(), 1);

        vm.startPrank(bob);
        networkRegistry.registerNetwork();
        vm.stopPrank();

        vm.startPrank(alice);
        assertEq(stakerRewards.claimable(address(0), bob, ""), 0);
        vm.stopPrank();

        vm.startPrank(alice);
        stakerRewards.distributeReward(bob, address(0), 0, "");
        vm.stopPrank();

        vm.startPrank(alice);
        stakerRewards.claimRewards(bob, address(0), "");
        vm.stopPrank();
    }
}
