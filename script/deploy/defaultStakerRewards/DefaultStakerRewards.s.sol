// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";

import {IDefaultStakerRewardsFactory} from "src/interfaces/defaultStakerRewards/IDefaultStakerRewardsFactory.sol";

contract DefaultStakerRewardsScript is Script {
    function run(address defaultStakerRewardsFactory, address vault) external {
        vm.startBroadcast();

        IDefaultStakerRewardsFactory(defaultStakerRewardsFactory).create(vault);

        vm.stopBroadcast();
    }
}
