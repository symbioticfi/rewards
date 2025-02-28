// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {DefaultStakerRewards} from "../../../src/contracts/defaultStakerRewards/DefaultStakerRewards.sol";
import {DefaultStakerRewardsFactory} from "../../../src/contracts/defaultStakerRewards/DefaultStakerRewardsFactory.sol";

contract DefaultStakerRewardsFactoryScript is Script {
    function run(address vaultFactory, address networkMiddlewareService) external {
        vm.startBroadcast();

        DefaultStakerRewards stakerRewardsImplementation =
            new DefaultStakerRewards(vaultFactory, networkMiddlewareService);
        address defaultStakerRewardsFactory =
            address(new DefaultStakerRewardsFactory(address(stakerRewardsImplementation)));

        console2.log("Default Staker Rewards Factory: ", defaultStakerRewardsFactory);

        vm.stopBroadcast();
    }
}
