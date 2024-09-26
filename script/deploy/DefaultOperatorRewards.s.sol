// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";

import {IDefaultOperatorRewardsFactory} from
    "../../src/interfaces/defaultOperatorRewards/IDefaultOperatorRewardsFactory.sol";

contract DefaultOperatorRewardsScript is Script {
    function run(
        address defaultOperatorRewardsFactory
    ) external {
        vm.startBroadcast();

        IDefaultOperatorRewardsFactory(defaultOperatorRewardsFactory).create();

        vm.stopBroadcast();
    }
}
