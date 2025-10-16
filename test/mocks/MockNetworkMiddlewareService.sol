// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";

contract MockNetworkMiddlewareService is INetworkMiddlewareService {
    mapping(address => address) public middleware;
    address public networkRegistry;

    constructor() {
        networkRegistry = address(0x123); // Mock address
    }

    function NETWORK_REGISTRY() external view returns (address) {
        return networkRegistry;
    }

    function setMiddleware(
        address middlewareAddress
    ) external {
        // This is a simplified mock - in real usage, only networks can call this
        middleware[msg.sender] = middlewareAddress;
    }

    function setMiddlewareForNetwork(
        address network,
        address middlewareAddress
    ) external {
        middleware[network] = middlewareAddress;
    }
}
