// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import { SymbioticRewardsConstants } from "../../test/integration/SymbioticRewardsConstants.sol";

import {IDefaultStakerRewards} from "../../src/interfaces/defaultStakerRewards/IDefaultStakerRewards.sol";

contract DefaultStakerRewardsScript is Script {
    function run(
        address vault,
        uint256 adminFee,
        address defaultAdminRoleHolder,
        address adminFeeClaimRoleHolder,
        address adminFeeSetRoleHolder
    ) external {
        vm.startBroadcast();

        address defaultStakerRewards = SymbioticRewardsConstants.defaultStakerRewardsFactory().create(
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
