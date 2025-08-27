// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {RewardsReceiverRegistry} from "../../../src/contracts/rewardsV2/RewardsReceiverRegistry.sol";

contract RewardsReceiverRegistryScript is Script {
    function run() external {
        vm.startBroadcast();

        RewardsReceiverRegistry rewardsReceiverRegistry = new RewardsReceiverRegistry();

        console2.log("RewardsReceiverRegistry deployed at: ", address(rewardsReceiverRegistry));

        vm.stopBroadcast();
    }
}
