// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {Rewards} from "../../../src/contracts/rewardsV2/Rewards.sol";

contract RewardsScript is Script {
    address public constant VAULT_FACTORY = address(0x1);
    address public constant NETWORK_REGISTRY = address(0x2);
    address public constant NETWORK_MIDDLEWARE_SERVICE = address(0x3);

    function run(
        address feeRegistry,
        address curatorRegistry
    ) external {
        vm.startBroadcast();

        Rewards rewards =
            new Rewards(VAULT_FACTORY, NETWORK_REGISTRY, NETWORK_MIDDLEWARE_SERVICE, curatorRegistry, feeRegistry);

        console2.log("Rewards deployed at: ", address(rewards));

        vm.stopBroadcast();
    }
}
