// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IStakerRewards} from "../../src/interfaces/stakerRewards/IStakerRewards.sol";

contract SimpleStakerRewards is IStakerRewards {
    /**
     * @inheritdoc IStakerRewards
     */
    uint64 public constant version = 2;

    function claimable(address token, address account, bytes memory data) external view override returns (uint256) {}

    /**
     * @inheritdoc IStakerRewards
     */
    function distributeRewards(address network, address token, uint256 amount, bytes memory data) external override {
        emit DistributeRewards(network, token, amount, amount, uint48(block.timestamp));
    }

    /**
     * @inheritdoc IStakerRewards
     */
    function claimRewards(address recipient, address token, bytes memory data) external override {}
}
