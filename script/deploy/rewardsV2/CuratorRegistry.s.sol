// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {CuratorRegistry} from "../../../src/contracts/rewardsV2/CuratorRegistry.sol";

contract CuratorRegistryScript is Script {
    function run() external returns (address) {
        vm.startBroadcast();

        CuratorRegistry curatorRegistry = new CuratorRegistry();

        console2.log("CuratorRegistry deployed at: ", address(curatorRegistry));

        vm.stopBroadcast();

        return address(curatorRegistry);
    }
}
