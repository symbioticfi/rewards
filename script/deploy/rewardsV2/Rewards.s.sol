// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {Rewards} from "../../../src/contracts/rewardsV2/Rewards.sol";

contract RewardsScript is Script {
    function run() external {
        vm.startBroadcast();

        Rewards rewards = new Rewards();

        console2.log("Rewards deployed at: ", address(rewards));

        vm.stopBroadcast();
    }
}
