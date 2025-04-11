// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {SymbioticCoreConstants} from "@symbioticfi/core/test/integration/SymbioticCoreConstants.sol";

import {DefaultOperatorRewards} from "../../../src/contracts/defaultOperatorRewards/DefaultOperatorRewards.sol";
import {DefaultOperatorRewardsFactory} from
    "../../../src/contracts/defaultOperatorRewards/DefaultOperatorRewardsFactory.sol";

contract DefaultOperatorRewardsFactoryScript is Script {
    function run() external {
        vm.startBroadcast();

        SymbioticCoreConstants.Core memory symbioticCore = SymbioticCoreConstants.core();

        DefaultOperatorRewards operatorRewardsImplementation =
            new DefaultOperatorRewards(address(symbioticCore.networkMiddlewareService));
        address defaultOperatorRewardsFactory =
            address(new DefaultOperatorRewardsFactory(address(operatorRewardsImplementation)));

        console2.log("Default Operator Rewards Factory: ", defaultOperatorRewardsFactory);

        vm.stopBroadcast();
    }
}
