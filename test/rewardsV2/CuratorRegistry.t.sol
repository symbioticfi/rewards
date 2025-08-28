// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";

import {CuratorRegistry} from "../../src/contracts/rewardsV2/CuratorRegistry.sol";
import {ICuratorRegistry} from "../../src/interfaces/rewardsV2/ICuratorRegistry.sol";
import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";
import {MockNetworkMiddlewareService} from "../mocks/MockNetworkMiddlewareService.sol";

contract CuratorRegistryTest is Test {
    CuratorRegistry curatorRegistry;
    MockNetworkMiddlewareService mockMiddlewareService;

    address operator;
    address curator1;
    address curator2;
    address vault;
    address network;
    address middleware;

    uint256 operatorPrivateKey;
    uint256 curator1PrivateKey;
    uint256 curator2PrivateKey;

    function setUp() public {
        (operator, operatorPrivateKey) = makeAddrAndKey("operator");
        (curator1, curator1PrivateKey) = makeAddrAndKey("curator1");
        (curator2, curator2PrivateKey) = makeAddrAndKey("curator2");
        (vault,) = makeAddrAndKey("vault");
        (network,) = makeAddrAndKey("network");
        (middleware,) = makeAddrAndKey("middleware");

        mockMiddlewareService = new MockNetworkMiddlewareService();
        curatorRegistry = new CuratorRegistry(address(mockMiddlewareService));

        // Set up middleware relationships
        mockMiddlewareService.setMiddlewareForNetwork(network, middleware);
    }

    function test_Constructor() public view {
        assertEq(curatorRegistry.NETWORK_MIDDLEWARE_SERVICE(), address(mockMiddlewareService));
    }

    function test_SetCuratorViaMiddleware() public {
        vm.startPrank(middleware);

        curatorRegistry.setCurator(network, vault, curator1);

        address retrievedCurator = curatorRegistry.getCurator(network, vault);
        assertEq(retrievedCurator, curator1);

        vm.stopPrank();
    }

    function test_SetCuratorDirectly() public {
        vm.startPrank(network);

        curatorRegistry.setCurator(vault, curator1);

        address retrievedCurator = curatorRegistry.getCurator(network, vault);
        assertEq(retrievedCurator, curator1);

        vm.stopPrank();
    }

    function test_GetCuratorAt() public {
        vm.startPrank(middleware);

        // Set initial timestamp
        uint256 timestamp1 = 1000;
        vm.warp(timestamp1);
        curatorRegistry.setCurator(network, vault, curator1);

        // Advance time and set second curator
        uint256 timestamp2 = timestamp1 + 100;
        vm.warp(timestamp2);
        curatorRegistry.setCurator(network, vault, curator2);

        // Check curator at first timestamp
        address curatorAtTime1 = curatorRegistry.getCuratorAt(network, vault, uint48(timestamp1), "");
        assertEq(curatorAtTime1, curator1);

        // Check curator at second timestamp
        address curatorAtTime2 = curatorRegistry.getCuratorAt(network, vault, uint48(timestamp2), "");
        assertEq(curatorAtTime2, curator2);

        // Check curator at time between checkpoints (should return first curator)
        uint256 timestampBetween = timestamp1 + 50;
        address curatorAtTimeBetween = curatorRegistry.getCuratorAt(network, vault, uint48(timestampBetween), "");
        assertEq(curatorAtTimeBetween, curator1);

        vm.stopPrank();
    }

    function test_SetCuratorEmitsEvent() public {
        vm.startPrank(middleware);

        vm.expectEmit(true, true, true, true);
        emit ICuratorRegistry.SetCurator(network, vault, curator1);

        curatorRegistry.setCurator(network, vault, curator1);

        vm.stopPrank();
    }

    function test_SetCuratorDirectlyEmitsEvent() public {
        vm.startPrank(network);

        vm.expectEmit(true, true, true, true);
        emit ICuratorRegistry.SetCurator(network, vault, curator1);

        curatorRegistry.setCurator(vault, curator1);

        vm.stopPrank();
    }

    function test_RevertWhenNotNetworkMiddleware() public {
        vm.startPrank(operator);

        vm.expectRevert(ICuratorRegistry.NotNetworkMiddleware.selector);
        curatorRegistry.setCurator(network, vault, curator1);

        vm.stopPrank();
    }
}
