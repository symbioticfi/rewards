// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IDefaultOperatorRewardsFactory {
    /**
     * @notice Create a default operator rewards contract for a given vault.
     * @param vault address of the vault
     * @return address of the created operator rewards contract
     */
    function create(address vault) external returns (address);
}
