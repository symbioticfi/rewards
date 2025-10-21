// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Vm} from "forge-std/Vm.sol";

import {Rewards} from "../../src/contracts/rewardsV2/Rewards.sol";
import {IRewards} from "../../src/interfaces/rewardsV2/IRewards.sol";
import {IVaultSnapshotRewards} from "../../src/interfaces/rewardsV2/IVaultSnapshotRewards.sol";
import {ICumulativeMerkleRewards} from "../../src/interfaces/rewardsV2/ICumulativeMerkleRewards.sol";

import {RewardsV2TestBase} from "./RewardsV2TestBase.sol";

contract RewardsTest is RewardsV2TestBase {
    Rewards rewards;

    function setUp() public {
        _deployRewardsInfra(address(this));
        rewards = new Rewards(
            address(vaultFactory),
            address(networkRegistry),
            address(networkMiddlewareService),
            address(curatorRegistry),
            address(feeRegistry)
        );

        rewards.initialize(address(this));
    }

    function test_Constructor() public {
        // Test constructor parameters are set correctly
        assertEq(address(rewards.VAULT_FACTORY()), address(vaultFactory));
        assertEq(address(rewards.NETWORK_REGISTRY()), address(networkRegistry));
        assertEq(address(rewards.NETWORK_MIDDLEWARE_SERVICE()), address(networkMiddlewareService));
        assertEq(address(rewards.CURATOR_REGISTRY()), address(curatorRegistry));
    }

    function test_Initialize() public {
        // Create a new rewards contract for this test
        Rewards newRewards = new Rewards(
            address(vaultFactory),
            address(networkRegistry),
            address(networkMiddlewareService),
            address(curatorRegistry),
            address(feeRegistry)
        );

        address newOwner = makeAddr("newOwner");

        newRewards.initialize(newOwner);

        assertEq(newRewards.owner(), newOwner);
    }

    function test_ClaimRewards_VaultSnapshot() public {
        // Prepare vault snapshot reward data
        bytes memory vaultSnapshotData =
            abi.encode(address(1), address(2), uint256(1000), uint256(0), uint256(0), new bytes[](1));

        // Encode reward type + data
        bytes memory data = abi.encodePacked(uint64(IRewards.RewardsType.VAULT_SNAPSHOT), vaultSnapshotData);

        // We only test that the function routes correctly
        vm.expectRevert(IVaultSnapshotRewards.InvalidLastUnclaimedReward.selector); // This will revert due to missing setup, but shows routing works
        rewards.claimRewards(address(this), address(rewardsToken), data);
    }

    function test_ClaimRewards_CumulativeMerkle() public {
        ICumulativeMerkleRewards.CumulativeDistributionLeaf memory leaf;
        bytes32[] memory proof = new bytes32[](1);
        bytes memory cumulativeDistributionData = abi.encode(address(1), keccak256("root"), leaf, proof);

        // Encode reward type + data
        bytes memory data = abi.encodePacked(uint64(IRewards.RewardsType.CUMULATIVE_MERKLE), cumulativeDistributionData);

        // We only test that the function routes correctly
        vm.expectRevert(ICumulativeMerkleRewards.InvalidToken.selector); // This will revert due to missing setup, but shows routing works
        rewards.claimRewards(address(this), address(rewardsToken), data);
    }
}
