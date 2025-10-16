// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console2, Script} from "forge-std/Script.sol";

import {FeeRegistry} from "../../../src/contracts/rewardsV2/FeeRegistry.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {IFeeRegistry} from "../../../src/interfaces/rewardsV2/IFeeRegistry.sol";

contract FeeRegistryScript is Script {
    function run(
        address curatorRegistry,
        address owner,
        address admin
    ) external returns (address) {
        vm.startBroadcast();

        // Deploy the implementation contract
        FeeRegistry implementation = new FeeRegistry(curatorRegistry);

        // Prepare initialization data
        IFeeRegistry.ProtocolFeesInitParams memory initParams = IFeeRegistry.ProtocolFeesInitParams({
            owner: owner,
            fees: new IFeeRegistry.RewardsTypeFee[](0) // Empty array for now
        });

        bytes memory initData = abi.encodeWithSelector(FeeRegistry.initialize.selector, initParams);

        // Deploy the transparent upgradeable proxy with initialization data
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(implementation), admin, initData);

        console2.log("FeeRegistry implementation deployed at: ", address(implementation));
        console2.log("FeeRegistry proxy deployed at: ", address(proxy));
        console2.log("Proxy admin: ", admin);

        vm.stopBroadcast();

        return address(proxy);
    }
}
