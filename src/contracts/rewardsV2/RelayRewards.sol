// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IRelayRewards} from "../../interfaces/rewardsV2/IRelayRewards.sol";
import {IRewards} from "../../interfaces/rewardsV2/IRewards.sol";

import {NetworkManager} from "@symbioticfi/relay-contracts/src/contracts/modules/base/NetworkManager.sol";
import {PermissionManager} from "@symbioticfi/relay-contracts/src/contracts/modules/base/PermissionManager.sol";
import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {ISettlement} from "@symbioticfi/relay-contracts/src/interfaces/modules/settlement/ISettlement.sol";

import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";

/**
 * @title RelayRewards
 * @notice Manages relay rewards distribution with validator set verification
 * @dev This contract handles rewards distribution across epochs with quorum signature verification
 */
abstract contract RelayRewards is NetworkManager, PermissionManager, IRelayRewards {
    using Checkpoints for Checkpoints.Trace208;

    address public immutable rewards;

    // keccak256(abi.encode(uint256(keccak256("symbiotic.storage.RelayRewards")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant RelayRewardsStorageLocation =
        0xee59a324fbfe78934318b39825f45ea9001e0aa38a9c8c4f774eac8161f71e00;

    function _getRelayRewardsStorage() internal pure returns (RelayRewardsStorage storage $) {
        bytes32 location = RelayRewardsStorageLocation;
        assembly {
            $.slot := location
        }
    }

    constructor(
        address _rewards
    ) {
        rewards = _rewards;
    }

    function __RelayRewards_init(
        RelayRewardsInitParams memory initParams
    ) internal onlyInitializing {
        __NetworkManager_init(initParams.networkInitParams);
        RelayRewardsStorage storage $ = _getRelayRewardsStorage();
        $.unrewardedEpoch = initParams.unrewardedEpoch;
        $.settlement = initParams.settlement;
        $.requiredKeyTag = initParams.requiredKeyTag;
    }

    /* PUBLIC FUNCTIONS */

    /**
     * @inheritdoc IRelayRewards
     */
    function getDistributionTypeAt(uint48 epoch, bytes memory hint) public view returns (uint32) {
        return uint32(_getRelayRewardsStorage().distributionType.upperLookupRecent(epoch, hint));
    }

    /**
     * @inheritdoc IRelayRewards
     */
    function getDistributionType() public view returns (uint32) {
        return uint32(_getRelayRewardsStorage().distributionType.latest());
    }

    /**
     * @inheritdoc IRelayRewards
     */
    function getRequiredKeyTag() public view returns (uint8) {
        return _getRelayRewardsStorage().requiredKeyTag;
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
        bytes calldata proof,
        bytes calldata hints
    ) public {
        RelayRewardsStorage storage $ = _getRelayRewardsStorage();
        if (rewardsEpoch < $.unrewardedEpoch) {
            revert RewardsEpochIsInvalid();
        }

        if (validatorSetEpoch < ISettlement($.settlement).getLastCommittedHeaderEpoch() - 1) {
            revert ValidatorSetEpochIsStale();
        }

        ISettlement($.settlement).verifyQuorumSigAt(
            abi.encode(keccak256(abi.encode(rewardsEpoch, cumulativeDistributionRoot, daData, topUps))),
            $.requiredKeyTag,
            ISettlement($.settlement).getQuorumThresholdFromValSetHeaderAt(validatorSetEpoch),
            proof,
            validatorSetEpoch,
            hints
        );

        // TODO: what happens in case of missed epochs all over the system
        IRewards(rewards).updateCumulativeDistribution(
            NETWORK(),
            IRewards.CumulativeDistribution({
                timestamp: ISettlement($.settlement).getCaptureTimestampFromValSetHeaderAt(rewardsEpoch),
                merkleRoot: cumulativeDistributionRoot,
                daData: daData
            }),
            topUps
        );

        $.unrewardedEpoch = rewardsEpoch + 1;
    }

    /**
     * @inheritdoc IRelayRewards
     */
    function setDistributionType(
        uint32 newDistributionType
    ) public checkPermission {
        _getRelayRewardsStorage().distributionType.push(
            ISettlement(_getRelayRewardsStorage().settlement).getLastCommittedHeaderEpoch() + 1,
            uint208(newDistributionType)
        );
        emit SetDistributionType(newDistributionType);
    }

    /**
     * @inheritdoc IRelayRewards
     */
    function setRequiredKeyTag(
        uint8 requiredKeyTag
    ) public checkPermission {
        _getRelayRewardsStorage().requiredKeyTag = requiredKeyTag;
    }
}
