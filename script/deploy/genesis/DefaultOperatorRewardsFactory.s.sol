// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {DefaultOperatorRewards} from "../../../src/contracts/defaultOperatorRewards/DefaultOperatorRewards.sol";
import {DefaultOperatorRewardsFactory} from
    "../../../src/contracts/defaultOperatorRewards/DefaultOperatorRewardsFactory.sol";

contract DefaultOperatorRewardsFactoryScript is Script {
    function run(
        address networkMiddlewareService
    ) external {
        vm.startBroadcast();

        DefaultOperatorRewards operatorRewardsImplementation = new DefaultOperatorRewards(networkMiddlewareService);
        address defaultOperatorRewardsFactory =
            address(new DefaultOperatorRewardsFactory(address(operatorRewardsImplementation)));

        console2.log("Default Operator Rewards Factory: ", defaultOperatorRewardsFactory);

        vm.stopBroadcast();
    }
}
