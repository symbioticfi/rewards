// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";

import {NetworkRegistry} from "@symbioticfi/core/src/contracts/NetworkRegistry.sol";
import {NetworkMiddlewareService} from "@symbioticfi/core/src/contracts/service/NetworkMiddlewareService.sol";

import {DefaultOperatorRewardsFactory} from
    "../../src/contracts/defaultOperatorRewards/DefaultOperatorRewardsFactory.sol";
import {DefaultOperatorRewards} from "../../src/contracts/defaultOperatorRewards/DefaultOperatorRewards.sol";
import {IDefaultOperatorRewards} from "../../src/interfaces/defaultOperatorRewards/IDefaultOperatorRewards.sol";

contract DefaultOperatorRewardsFactoryTest is Test {
    address owner;
    address alice;
    uint256 alicePrivateKey;
    address bob;
    uint256 bobPrivateKey;

    NetworkRegistry networkRegistry;
    NetworkMiddlewareService networkMiddlewareService;

    DefaultOperatorRewardsFactory defaultOperatorRewardsFactory;
    DefaultOperatorRewards defaultOperatorRewards;

    function setUp() public {
        owner = address(this);
        (alice, alicePrivateKey) = makeAddrAndKey("alice");
        (bob, bobPrivateKey) = makeAddrAndKey("bob");

        networkRegistry = new NetworkRegistry();
        networkMiddlewareService = new NetworkMiddlewareService(address(networkRegistry));
    }

    function test_Create() public {
        address defaultOperatorRewards_ = address(new DefaultOperatorRewards(address(networkMiddlewareService)));

        defaultOperatorRewardsFactory = new DefaultOperatorRewardsFactory(defaultOperatorRewards_);

        address defaultOperatorRewardsAddress = defaultOperatorRewardsFactory.create();
        defaultOperatorRewards = DefaultOperatorRewards(defaultOperatorRewardsAddress);
        assertEq(defaultOperatorRewardsFactory.isEntity(defaultOperatorRewardsAddress), true);

        assertEq(defaultOperatorRewards.NETWORK_MIDDLEWARE_SERVICE(), address(networkMiddlewareService));
        assertEq(defaultOperatorRewards.root(alice, alice), bytes32(0));
        assertEq(defaultOperatorRewards.claimed(alice, alice, alice), 0);
    }
}
