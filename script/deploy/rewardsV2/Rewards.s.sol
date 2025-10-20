// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {Rewards} from "../../../src/contracts/rewardsV2/Rewards.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {IRewards} from "../../../src/interfaces/rewardsV2/IRewards.sol";
import {IVaultSnapshotRewards} from "../../../src/interfaces/rewardsV2/IVaultSnapshotRewards.sol";

contract RewardsScript is Script {
    address public constant VAULT_FACTORY = address(0x1);
    address public constant NETWORK_REGISTRY = address(0x2);
    address public constant NETWORK_MIDDLEWARE_SERVICE = address(0x3);

    function run(
        address feeRegistry,
        address curatorRegistry,
        address owner,
        address admin
    ) external returns (address) {
        vm.startBroadcast();

        // Deploy the implementation contract
        Rewards implementation =
            new Rewards(VAULT_FACTORY, NETWORK_REGISTRY, NETWORK_MIDDLEWARE_SERVICE, curatorRegistry, feeRegistry);

        bytes memory initData = abi.encodeWithSelector(Rewards.initialize.selector, owner);

        // Deploy the transparent upgradeable proxy with initialization data
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(implementation), admin, initData);

        console2.log("Rewards implementation deployed at: ", address(implementation));
        console2.log("Rewards proxy deployed at: ", address(proxy));
        console2.log("Proxy admin: ", admin);

        vm.stopBroadcast();

        return address(proxy);
    }
}
