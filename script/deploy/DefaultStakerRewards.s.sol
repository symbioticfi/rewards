// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {IDefaultStakerRewards} from "../../src/interfaces/defaultStakerRewards/IDefaultStakerRewards.sol";
import {IDefaultStakerRewardsFactory} from "../../src/interfaces/defaultStakerRewards/IDefaultStakerRewardsFactory.sol";

contract DefaultStakerRewardsScript is Script {
    function run(
        address defaultStakerRewardsFactory,
        address vault,
        uint256 adminFee,
        address defaultAdminRoleHolder,
        address adminFeeClaimRoleHolder,
        address adminFeeSetRoleHolder
    ) external {
        vm.startBroadcast();

        address defaultStakerRewards = IDefaultStakerRewardsFactory(defaultStakerRewardsFactory).create(
            IDefaultStakerRewards.InitParams({
                vault: vault,
                adminFee: adminFee,
                defaultAdminRoleHolder: defaultAdminRoleHolder,
                adminFeeClaimRoleHolder: adminFeeClaimRoleHolder,
                adminFeeSetRoleHolder: adminFeeSetRoleHolder
            })
        );

        console2.log("Default Staker Rewards: ", defaultStakerRewards);

        vm.stopBroadcast();
    }
}
