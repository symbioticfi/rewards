// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";

import {CuratorRegistry} from "../../src/contracts/rewardsV2/CuratorRegistry.sol";
import {FeeRegistry} from "../../src/contracts/rewardsV2/FeeRegistry.sol";

import {VaultFactory} from "@symbioticfi/core/src/contracts/VaultFactory.sol";
import {NetworkRegistry} from "@symbioticfi/core/src/contracts/NetworkRegistry.sol";
import {NetworkMiddlewareService} from "@symbioticfi/core/src/contracts/service/NetworkMiddlewareService.sol";
import {Token} from "@symbioticfi/core/test/mocks/Token.sol";

/**
 * @title RewardsV2TestBase
 * @notice Provides shared deployment helpers for Rewards V2 tests
 */
abstract contract RewardsV2TestBase is Test {
    CuratorRegistry internal curatorRegistry;
    FeeRegistry internal feeRegistry;
    VaultFactory internal vaultFactory;
    NetworkRegistry internal networkRegistry;
    NetworkMiddlewareService internal networkMiddlewareService;
    Token internal rewardsToken;

    function _deployRewardsInfra(
        address feeOwner
    ) internal {
        curatorRegistry = new CuratorRegistry();
        feeRegistry = new FeeRegistry(address(curatorRegistry));
        feeRegistry.initialize(feeOwner);

        networkRegistry = new NetworkRegistry();
        networkMiddlewareService = new NetworkMiddlewareService(address(networkRegistry));
        vaultFactory = new VaultFactory(address(this));

        rewardsToken = new Token("RewardsToken");
    }

    function _registerNetwork(
        address network
    ) internal {
        vm.prank(network);
        networkRegistry.registerNetwork();
    }
}
