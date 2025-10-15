// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {FeeRegistry} from "../../../src/contracts/rewardsV2/FeeRegistry.sol";

contract FeeRegistryScript is Script {
    function run(
        address curatorRegistry
    ) external returns (address) {
        vm.startBroadcast();

        FeeRegistry feeRegistry = new FeeRegistry(curatorRegistry);

        console2.log("FeeRegistry deployed at: ", address(feeRegistry));

        vm.stopBroadcast();

        return address(feeRegistry);
    }
}
