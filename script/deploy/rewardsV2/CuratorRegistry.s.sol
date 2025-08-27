// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {CuratorRegistry} from "../../../src/contracts/rewardsV2/CuratorRegistry.sol";

contract CuratorRegistryScript is Script {
    function run() external {
        // Get the network middleware service address from environment
        address networkMiddlewareService = vm.envOr("NETWORK_MIDDLEWARE_SERVICE", address(0));

        if (networkMiddlewareService == address(0)) {
            revert("NETWORK_MIDDLEWARE_SERVICE environment variable must be set");
        }

        vm.startBroadcast();

        CuratorRegistry curatorRegistry = new CuratorRegistry(networkMiddlewareService);

        console2.log("CuratorRegistry deployed at: ", address(curatorRegistry));

        vm.stopBroadcast();
    }
}
