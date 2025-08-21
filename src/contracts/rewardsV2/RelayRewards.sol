// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {NetworkManager} from "lib/relay-contracts/src/contracts/modules/base/NetworkManager.sol";
import {PermissionManager} from "lib/relay-contracts/src/contracts/modules/base/PermissionManager.sol";
import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";
import {ISettlement} from "lib/relay-contracts/src/interfaces/modules/settlement/ISettlement.sol";
import {IRewards} from "../../interfaces/rewardsV2/IRewards.sol";
import {IRelayRewards} from "../../interfaces/rewardsV2/IRelayRewards.sol";

/**
 * @title RelayRewards
 * @notice Manages relay rewards distribution with validator set verification
 * @dev This contract handles rewards distribution across epochs with quorum signature verification
 */
abstract contract RelayRewards is NetworkManager, PermissionManager, Multicall, IRelayRewards {
    using Checkpoints for Checkpoints.Trace208;

    // State variables
    address public immutable settlement;
    address public immutable rewards;

    uint48 public unrewardedEpoch;
    Checkpoints.Trace208 public distributionType;

    // Constructor
    constructor(address _settlement, address _rewards) {
        settlement = _settlement;
        rewards = _rewards;
    }

    // External functions
    function initialize(uint48 initUnrewardedEpoch, NetworkManagerInitParams memory networkInitParams) external {
        unrewardedEpoch = initUnrewardedEpoch;
        __NetworkManager_init(networkInitParams);
    }

    /**
     * @inheritdoc IRelayRewards
     */
    function distributeRewards(
        uint48 rewardsEpoch,
        bytes32 cumulativeDistributionRoot,
        bytes calldata daData,
        IRewards.TopUp[] calldata topUps,
        uint48 validatorSetEpoch,
        bytes calldata proof
    ) external {
        if (rewardsEpoch < unrewardedEpoch) {
            revert RewardsEpochIsInvalid();
        }

        // check signingEpoch for staleness
        if (validatorSetEpoch < ISettlement(settlement).getLastCommittedHeaderEpoch() - 1) {
            revert ValidatorSetEpochIsStale();
        }

        ISettlement(settlement).verifyQuorumSigAt(
            abi.encode(keccak256(abi.encode(rewardsEpoch, cumulativeDistributionRoot, daData, topUps))),
            ISettlement(settlement).getRequiredKeyTagFromValSetHeaderAt(validatorSetEpoch),
            ISettlement(settlement).getQuorumThresholdFromValSetHeaderAt(validatorSetEpoch),
            proof,
            validatorSetEpoch,
            new bytes(0)
        );

        // TODO: what happens in case of missed epochs all over the system
        IRewards(rewards).updateCumulativeDistribution(
            NETWORK(),
            IRewards.CumulativeDistribution({
                timestamp: ISettlement(settlement).getCaptureTimestampFromValSetHeaderAt(rewardsEpoch),
                merkleRoot: cumulativeDistributionRoot,
                daData: daData
            }),
            topUps
        );

        unrewardedEpoch = rewardsEpoch;
    }

    // update type for the next epoch (epoch can be got from settlement.getLastCommittedHeaderEpoch())
    // checkPermission
    /**
     * @inheritdoc IRelayRewards
     */
    function setDistributionType(
        uint32 newDistributionType
    ) external checkPermission {
        uint48 nextEpoch = ISettlement(settlement).getLastCommittedHeaderEpoch() + 1;
        distributionType.push(nextEpoch, uint208(newDistributionType));
        emit DistributionTypeUpdated(newDistributionType);
    }

    function getDistributionTypeAt(uint48 epoch) external view returns (uint32) {
        (,, uint208 value,) = distributionType.upperLookupRecentCheckpoint(epoch, new bytes(0));
        return uint32(value);
    }

    function getDistributionType() external view returns (uint32) {
        (,, uint208 value) = distributionType.latestCheckpoint();
        return uint32(value);
    }
}
