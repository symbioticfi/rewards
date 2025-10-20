// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ICuratorRegistry} from "../../interfaces/rewardsV2/ICuratorRegistry.sol";
import {IFeeRegistry} from "../../interfaces/rewardsV2/IFeeRegistry.sol";

import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {StaticDelegateCallable} from "@symbioticfi/core/src/contracts/common/StaticDelegateCallable.sol";

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {MulticallUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/MulticallUpgradeable.sol";

contract FeeRegistry is OwnableUpgradeable, MulticallUpgradeable, StaticDelegateCallable, IFeeRegistry {
    using Checkpoints for Checkpoints.Trace208;

    /* CONSTANTS */

    /**
     * @inheritdoc IFeeRegistry
     */
    uint256 public constant MAX_FEE = 1_000_000;

    /**
     * @inheritdoc IFeeRegistry
     */
    uint256 public constant MAX_PARTICIPANT_FEE = 500_000;

    /* IMMUTABLES */

    /**
     * @inheritdoc IFeeRegistry
     */
    address public immutable CURATOR_REGISTRY;

    /* STATE VARIABLES */

    mapping(address vault => Checkpoints.Trace208 value) internal _operatorsFee;
    // value is concat(isEnabled, fee)
    mapping(address vault => mapping(address network => Checkpoints.Trace208 value)) internal _operatorsNetworkFee;
    mapping(address vault => Checkpoints.Trace208 value) internal _curatorFee;
    // value is concat(isEnabled, fee)
    mapping(address vault => mapping(address network => Checkpoints.Trace208 value)) internal _curatorNetworkFee;
    mapping(bytes32 id => uint208 fee) internal _protocolFee;

    /* MODIFIERS */

    modifier onlyCurator(
        address vault
    ) {
        if (ICuratorRegistry(CURATOR_REGISTRY).getCurator(vault) != msg.sender) {
            revert NotCurator();
        }
        _;
    }

    modifier checkMaxFee(
        uint256 operatorFee,
        uint256 curatorFee
    ) {
        if (operatorFee + curatorFee > MAX_FEE) {
            revert FeeTooHigh();
        }
        _;
    }

    /* CONSTRUCTOR */

    constructor(
        address curatorRegistry_
    ) {
        CURATOR_REGISTRY = curatorRegistry_;
    }

    /* PUBLIC FUNCTIONS */

    function initialize(
        address owner
    ) public initializer {
        __Ownable_init(owner);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorsFeeAt(
        address vault,
        address network,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (uint256) {
        (bool isEnabled, uint256 networkFee) = getOperatorsNetworkFeeAt(vault, network, timestamp, hint);
        if (isEnabled) {
            return networkFee;
        }

        return getOperatorsDefaultFeeAt(vault, timestamp, hint);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorsFee(
        address vault,
        address network
    ) public view returns (uint256) {
        (bool isEnabled, uint256 networkFee) = getOperatorsNetworkFee(vault, network);
        if (isEnabled) {
            return networkFee;
        }

        return getOperatorsDefaultFee(vault);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorsNetworkFeeAt(
        address vault,
        address network,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorsNetworkFee[vault][network].upperLookupRecent(timestamp, hint));
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorsNetworkFee(
        address vault,
        address network
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorsNetworkFee[vault][network].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorsDefaultFeeAt(
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (uint256) {
        return _operatorsFee[vault].upperLookupRecent(timestamp, hint);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorsDefaultFee(
        address vault
    ) public view returns (uint256) {
        return _operatorsFee[vault].latest();
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorFeeAt(
        address vault,
        address network,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (uint256) {
        (bool isEnabled, uint256 networkFee) = getCuratorNetworkFeeAt(vault, network, timestamp, hint);
        if (isEnabled) {
            return networkFee;
        }

        return getCuratorDefaultFeeAt(vault, timestamp, hint);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorFee(
        address vault,
        address network
    ) public view returns (uint256) {
        (bool isEnabled, uint256 networkFee) = getCuratorNetworkFee(vault, network);
        if (isEnabled) {
            return networkFee;
        }

        return getCuratorDefaultFee(vault);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorNetworkFeeAt(
        address vault,
        address network,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_curatorNetworkFee[vault][network].upperLookupRecent(timestamp, hint));
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorNetworkFee(
        address vault,
        address network
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_curatorNetworkFee[vault][network].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorDefaultFeeAt(
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (uint256) {
        return _curatorFee[vault].upperLookupRecent(timestamp, hint);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorDefaultFee(
        address vault
    ) public view returns (uint256) {
        return _curatorFee[vault].latest();
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getProtocolFee(
        bytes32 id
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_protocolFee[id]);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorsFee(
        address vault,
        uint256 fee
    ) public onlyCurator(vault) {
        if (fee > MAX_PARTICIPANT_FEE) {
            revert FeeTooHigh();
        }

        _operatorsFee[vault].push(uint48(block.timestamp), uint208(fee));
        emit SetOperatorsFee(vault, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorsNetworkFee(
        address vault,
        address network,
        bool enable,
        uint256 fee
    ) public onlyCurator(vault) {
        if (fee > MAX_PARTICIPANT_FEE) {
            revert FeeTooHigh();
        }

        _operatorsNetworkFee[vault][network].push(uint48(block.timestamp), _serializeFeeData(enable, fee));
        emit SetOperatorsNetworkFee(vault, network, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setCuratorFee(
        address vault,
        uint256 fee
    ) public onlyCurator(vault) {
        if (fee > MAX_PARTICIPANT_FEE) {
            revert FeeTooHigh();
        }

        _curatorFee[vault].push(uint48(block.timestamp), uint208(fee));
        emit SetCuratorFee(vault, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setCuratorNetworkFee(
        address vault,
        address network,
        bool enable,
        uint256 fee
    ) public onlyCurator(vault) {
        if (fee > MAX_PARTICIPANT_FEE) {
            revert FeeTooHigh();
        }

        _curatorNetworkFee[vault][network].push(uint48(block.timestamp), _serializeFeeData(enable, fee));
        emit SetCuratorNetworkFee(vault, network, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setProtocolFee(
        bytes32 id,
        bool enable,
        uint256 fee
    ) public onlyOwner {
        if (fee > MAX_FEE) {
            revert FeeTooHigh();
        }

        _protocolFee[id] = _serializeFeeData(enable, fee);
        emit SetProtocolFee(id, enable, fee);
    }

    /* INTERNAL FUNCTIONS */

    /**
     * @notice Serialize fee data (enable + fee)
     * @param isEnabled Whether the fee is enabled
     * @param fee The fee amount
     * @return The serialized data
     */
    function _serializeFeeData(
        bool isEnabled,
        uint256 fee
    ) internal pure returns (uint208) {
        return uint208((fee << 1) | (isEnabled ? 1 : 0));
    }

    /**
     * @notice Deserialize fee data
     * @param data The serialized data
     * @return isEnabled Whether the fee is enabled
     * @return fee The fee amount
     */
    function _deserializeFeeData(
        uint208 data
    ) internal pure returns (bool, uint256) {
        return (data & 1 > 0, data >> 1);
    }
}
