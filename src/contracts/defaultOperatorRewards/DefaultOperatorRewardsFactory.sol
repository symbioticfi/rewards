// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {DefaultOperatorRewards} from "./DefaultOperatorRewards.sol";

import {IDefaultOperatorRewardsFactory} from
    "../../interfaces/defaultOperatorRewards/IDefaultOperatorRewardsFactory.sol";

import {Registry} from "@symbioticfi/core/src/contracts/common/Registry.sol";

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

contract DefaultOperatorRewardsFactory is Registry, IDefaultOperatorRewardsFactory {
    using Clones for address;

    address private immutable OPERATOR_REWARDS_IMPLEMENTATION;

    constructor(
        address operatorRewardsImplementation
    ) {
        OPERATOR_REWARDS_IMPLEMENTATION = operatorRewardsImplementation;
    }

    /**
     * @inheritdoc IDefaultOperatorRewardsFactory
     */
    function create() external returns (address) {
        address operatorRewards =
            OPERATOR_REWARDS_IMPLEMENTATION.cloneDeterministic(keccak256(abi.encode(totalEntities(), msg.sender)));

        _addEntity(operatorRewards);

        return operatorRewards;
    }
}
