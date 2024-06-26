// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IStakerRewards} from "src/interfaces/stakerRewards/IStakerRewards.sol";

contract SimpleStakerRewards is IStakerRewards {
    /**
     * @inheritdoc IStakerRewards
     */
    uint64 public constant version = 1;

    /**
     * @inheritdoc IStakerRewards
     */
    function distributeReward(address network, address token, uint256 amount, uint48 timestamp) external {
        emit DistributeReward(network, token, amount, timestamp);
    }
}
