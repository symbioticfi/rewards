// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {SymbioticRewardsConstants} from "../../test/integration/SymbioticRewardsConstants.sol";

contract DefaultOperatorRewardsScript is Script {
    function run() external {
        vm.startBroadcast();

        address defaultOperatorRewards = SymbioticRewardsConstants.defaultOperatorRewardsFactory().create();

        console2.log("Default Operator Rewards: ", defaultOperatorRewards);

        vm.stopBroadcast();
    }
}
