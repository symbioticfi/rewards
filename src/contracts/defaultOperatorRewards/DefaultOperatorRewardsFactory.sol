// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {DefaultOperatorRewards} from "./DefaultOperatorRewards.sol";
import {Registry} from "@symbiotic/contracts/base/Registry.sol";

import {IDefaultOperatorRewardsFactory} from "src/interfaces/defaultOperatorRewards/IDefaultOperatorRewardsFactory.sol";

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

contract DefaultOperatorRewardsFactory is Registry, IDefaultOperatorRewardsFactory {
    using Clones for address;

    address private immutable OPERATOR_REWARDS_IMPLEMENTATION;

    constructor(address operatorRewardsImplementation) {
        OPERATOR_REWARDS_IMPLEMENTATION = operatorRewardsImplementation;
    }

    /**
     * @inheritdoc IDefaultOperatorRewardsFactory
     */
    function create(address vault) external returns (address) {
        address operatorRewards = OPERATOR_REWARDS_IMPLEMENTATION.clone();
        DefaultOperatorRewards(operatorRewards).initialize(vault);

        _addEntity(operatorRewards);

        return operatorRewards;
    }
}
