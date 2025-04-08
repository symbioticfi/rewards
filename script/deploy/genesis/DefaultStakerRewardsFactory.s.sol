// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {SymbioticCoreConstants} from "@symbioticfi/core/test/integration/SymbioticCoreConstants.sol";

import {DefaultStakerRewards} from "../../../src/contracts/defaultStakerRewards/DefaultStakerRewards.sol";
import {DefaultStakerRewardsFactory} from "../../../src/contracts/defaultStakerRewards/DefaultStakerRewardsFactory.sol";

contract DefaultStakerRewardsFactoryScript is Script {
    function run() external {
        vm.startBroadcast();

        SymbioticCoreConstants.Core memory symbioticCore = SymbioticCoreConstants.core();

        DefaultStakerRewards stakerRewardsImplementation = new DefaultStakerRewards(
            address(symbioticCore.vaultFactory), address(symbioticCore.networkMiddlewareService)
        );
        address defaultStakerRewardsFactory =
            address(new DefaultStakerRewardsFactory(address(stakerRewardsImplementation)));

        console2.log("Default Staker Rewards Factory: ", defaultStakerRewardsFactory);

        vm.stopBroadcast();
    }
}
