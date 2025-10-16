// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {CuratorRegistryScript} from "./CuratorRegistry.s.sol";
import {RewardsScript} from "./Rewards.s.sol";
import {FeeRegistryScript} from "./FeeRegistry.s.sol";

contract RewardsV2Script is Script {
    function run(
        address owner,
        address admin
    ) external {
        // Deploy CuratorRegistry (upgradeable)
        CuratorRegistryScript curatorRegistryScript = new CuratorRegistryScript();
        address curatorRegistry = curatorRegistryScript.run(admin);

        // Deploy FeeRegistry (upgradeable) - requires owner for initialization
        FeeRegistryScript feeRegistryScript = new FeeRegistryScript();
        address feeRegistry = feeRegistryScript.run(curatorRegistry, owner, admin);

        // Deploy Rewards (upgradeable) - requires owner for initialization
        RewardsScript rewardsScript = new RewardsScript();
        address rewards = rewardsScript.run(feeRegistry, curatorRegistry, owner, admin);
    }
}
