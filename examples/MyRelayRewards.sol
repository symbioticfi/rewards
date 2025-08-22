// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {RelayRewards} from "../src/contracts/rewardsV2/RelayRewards.sol";
import {OzOwnable} from "@symbioticfi/relay-contracts/src/contracts/modules/common/permissions/OzOwnable.sol";

contract MyRelayRewards is RelayRewards, OzOwnable {
    constructor(address _rewards) RelayRewards(_rewards) {
    }

    function initialize(RelayRewardsInitParams memory initParams, OzOwnableInitParams memory ozOwnableInitParams) public virtual initializer {
        __RelayRewards_init(initParams);
        __OzOwnable_init(ozOwnableInitParams);
    }
}