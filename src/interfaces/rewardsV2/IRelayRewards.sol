// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IRewards} from "./IRewards.sol";

interface IRelayRewards {
    // Custom errors
    error RewardsEpochIsInvalid();
    error ValidatorSetEpochIsStale();

    // Events
    event DistributionTypeUpdated(uint32 indexed newType);

    // Functions
    function initialize(
        uint48 initUnrewardedEpoch
    ) external;

    function distributeRewards(
        uint48 rewardsEpoch,
        bytes32 cumulativeDistributionRoot,
        bytes calldata daData,
        IRewards.TopUp[] calldata topUps,
        uint48 validatorSetEpoch,
        bytes calldata proof
    ) external;

    function setDistributionType(
        uint32 newDistributionType
    ) external;

    function getDistributionTypeAt(uint48 epoch) external view returns (uint32);

    function getDistributionType() external view returns (uint32);
}
