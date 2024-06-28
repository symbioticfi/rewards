// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IDefaultOperatorRewardsFactory {
    /**
     * @notice Create a default operator rewards contract.
     * @return address of the created operator rewards contract
     */
    function create() external returns (address);
}
