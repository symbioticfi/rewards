// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {IDefaultOperatorRewardsFactory} from
    "../../src/interfaces/defaultOperatorRewards/IDefaultOperatorRewardsFactory.sol";

contract DefaultOperatorRewardsScript is Script {
    function run(
        address defaultOperatorRewardsFactory
    ) external {
        vm.startBroadcast();

        address defaultOperatorRewards = IDefaultOperatorRewardsFactory(defaultOperatorRewardsFactory).create();

        console2.log("Default Operator Rewards: ", defaultOperatorRewards);

        vm.stopBroadcast();
    }
}
