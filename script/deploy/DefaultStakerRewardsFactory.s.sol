// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";

import {DefaultStakerRewards} from "../../src/contracts/defaultStakerRewards/DefaultStakerRewards.sol";
import {DefaultStakerRewardsFactory} from "../../src/contracts/defaultStakerRewards/DefaultStakerRewardsFactory.sol";

contract DefaultStakerRewardsFactoryScript is Script {
    function run(address vaultFactory, address networkMiddlewareService) external {
        vm.startBroadcast();

        DefaultStakerRewards stakerRewardsImplementation =
            new DefaultStakerRewards(vaultFactory, networkMiddlewareService);
        new DefaultStakerRewardsFactory(address(stakerRewardsImplementation));

        vm.stopBroadcast();
    }
}
