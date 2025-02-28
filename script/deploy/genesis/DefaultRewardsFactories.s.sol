// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {DefaultStakerRewards} from "../../../src/contracts/defaultStakerRewards/DefaultStakerRewards.sol";
import {DefaultStakerRewardsFactory} from "../../../src/contracts/defaultStakerRewards/DefaultStakerRewardsFactory.sol";

import {DefaultOperatorRewards} from "../../../src/contracts/defaultOperatorRewards/DefaultOperatorRewards.sol";
import {DefaultOperatorRewardsFactory} from
    "../../../src/contracts/defaultOperatorRewards/DefaultOperatorRewardsFactory.sol";

contract DefaultRewardsFactoriesScript is Script {
    function run(address vaultFactory, address networkMiddlewareService) external {
        vm.startBroadcast();

        DefaultStakerRewards stakerRewardsImplementation =
            new DefaultStakerRewards(vaultFactory, networkMiddlewareService);
        address defaultStakerRewardsFactory =
            address(new DefaultStakerRewardsFactory(address(stakerRewardsImplementation)));

        DefaultOperatorRewards operatorRewardsImplementation = new DefaultOperatorRewards(networkMiddlewareService);
        address defaultOperatorRewardsFactory =
            address(new DefaultOperatorRewardsFactory(address(operatorRewardsImplementation)));

        console2.log("Default Staker Rewards Factory: ", defaultStakerRewardsFactory);
        console2.log("Default Operator Rewards Factory: ", defaultOperatorRewardsFactory);

        vm.stopBroadcast();
    }
}
