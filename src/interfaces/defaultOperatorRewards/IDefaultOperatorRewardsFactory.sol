// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRegistry} from "@symbioticfi/core/src/interfaces/common/IRegistry.sol";

interface IDefaultOperatorRewardsFactory is IRegistry {
    /**
     * @notice Create a default operator rewards contract.
     * @return address of the created operator rewards contract
     */
    function create() external returns (address);
}
