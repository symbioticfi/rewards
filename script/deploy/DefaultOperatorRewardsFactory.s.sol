// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";

import {DefaultOperatorRewards} from "../../src/contracts/defaultOperatorRewards/DefaultOperatorRewards.sol";
import {DefaultOperatorRewardsFactory} from
    "../../src/contracts/defaultOperatorRewards/DefaultOperatorRewardsFactory.sol";

contract DefaultOperatorRewardsFactoryScript is Script {
    function run(
        address networkMiddlewareService
    ) external {
        vm.startBroadcast();

        DefaultOperatorRewards operatorRewardsImplementation = new DefaultOperatorRewards(networkMiddlewareService);
        new DefaultOperatorRewardsFactory(address(operatorRewardsImplementation));

        vm.stopBroadcast();
    }
}
