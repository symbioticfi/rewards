// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {CuratorRegistry} from "../../../src/contracts/rewardsV2/CuratorRegistry.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract CuratorRegistryScript is Script {
    function run(
        address admin
    ) external returns (address) {
        vm.startBroadcast();

        // Deploy the implementation contract
        CuratorRegistry implementation = new CuratorRegistry();

        // Deploy the transparent upgradeable proxy with no initialization data
        // (CuratorRegistry doesn't need initialization)
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(implementation), admin, "");

        console2.log("CuratorRegistry implementation deployed at: ", address(implementation));
        console2.log("CuratorRegistry proxy deployed at: ", address(proxy));
        console2.log("Proxy admin: ", admin);

        vm.stopBroadcast();

        return address(proxy);
    }
}
