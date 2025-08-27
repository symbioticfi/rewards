// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {FeeRegistry} from "../../../src/contracts/rewardsV2/FeeRegistry.sol";

contract FeeRegistryScript is Script {
    function run() external {
        vm.startBroadcast();

        FeeRegistry feeRegistry = new FeeRegistry();

        console2.log("FeeRegistry deployed at: ", address(feeRegistry));

        vm.stopBroadcast();
    }
}
