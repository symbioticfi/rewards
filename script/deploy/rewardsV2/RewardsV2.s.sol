// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {CuratorRegistryScript} from "./CuratorRegistry.s.sol";
import {RewardsScript} from "./Rewards.s.sol";
import {FeeRegistryScript} from "./FeeRegistry.s.sol";

contract RewardsV2Script is Script {
    function run() external {
        CuratorRegistryScript curatorRegistryScript = new CuratorRegistryScript();
        address curatorRegistry = curatorRegistryScript.run();

        FeeRegistryScript feeRegistryScript = new FeeRegistryScript();
        address feeRegistry = feeRegistryScript.run(curatorRegistry);

        RewardsScript rewardsScript = new RewardsScript();
        rewardsScript.run(feeRegistry, curatorRegistry);
    }
}
