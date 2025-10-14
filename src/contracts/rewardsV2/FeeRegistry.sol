// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IFeeRegistry} from "../../interfaces/rewardsV2/IFeeRegistry.sol";
import {ICuratorRegistry} from "../../interfaces/rewardsV2/ICuratorRegistry.sol";
import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";

contract FeeRegistry is IFeeRegistry {
    using Checkpoints for Checkpoints.Trace208;

    /* CONSTANTS */

    uint256 public constant MAX_FEE = 1_000_000;

    /* STATE VARIABLES */

    mapping(address vault => Checkpoints.Trace208 value) internal _operatorFee;
    // value is concat(isEnabled, fee)
    mapping(address vault => mapping(address network => Checkpoints.Trace208 value)) internal _operatorNetworkFee;
    mapping(address vault => Checkpoints.Trace208 value) internal _curatorFee;
    mapping(address vault => mapping(address network => Checkpoints.Trace208 value)) internal _curatorNetworkFee;

    ICuratorRegistry public immutable curatorRegistry;

    /* MODIFIERS */

    modifier onlyCurator(
        address vault
    ) {
        if (curatorRegistry.getCurator(vault) != msg.sender) {
            revert NotCurator();
        }
        _;
    }

    /* CONSTRUCTOR */

    constructor(
        address curatorRegistry_
    ) {
        if (curatorRegistry_ == address(0)) {
            revert CuratorRegistryIsZero();
        }
        curatorRegistry = ICuratorRegistry(curatorRegistry_);
    }

    /* FUNCTIONS */

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorFeeAt(address vault, address network, uint48 timestamp) public view returns (uint256 fee) {
        // Check if network-specific fee exists and is enabled
        (bool isEnabled, uint256 networkFee) = getOperatorNetworkFeeAt(vault, network, timestamp);
        if (isEnabled) {
            return networkFee;
        }

        // Fall back to global vault fee
        return getOperatorFee(vault, network);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorFee(address vault, address network) public view returns (uint256 fee) {
        // Check if network-specific fee exists and is enabled
        (bool isEnabled, uint256 networkFee) = getOperatorNetworkFee(vault, network);
        if (isEnabled) {
            return networkFee;
        }

        // Fall back to global vault fee
        return _operatorFee[vault].latest();
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorNetworkFeeAt(
        address vault,
        address network,
        uint48 timestamp
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorNetworkFee[vault][network].upperLookupRecent(timestamp));
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorNetworkFee(address vault, address network) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorNetworkFee[vault][network].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorNetworkFeeAt(
        address vault,
        address network,
        uint48 timestamp
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_curatorNetworkFee[vault][network].upperLookupRecent(timestamp));
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorNetworkFee(address vault, address network) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_curatorNetworkFee[vault][network].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorFeeAt(address vault, uint48 timestamp) public view returns (uint256 fee) {
        return _curatorFee[vault].upperLookupRecent(timestamp);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorFee(
        address vault
    ) public view returns (uint256 fee) {
        return _curatorFee[vault].latest();
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorFee(address vault, uint256 fee) public onlyCurator(vault) {
        if (fee > MAX_FEE) {
            revert FeeTooHigh();
        }

        _operatorFee[vault].push(uint48(block.timestamp), uint208(fee));
        emit SetOperatorFee(vault, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorNetworkFee(
        address vault,
        address network,
        bool enable,
        uint256 fee
    ) public onlyCurator(vault) {
        if (fee > MAX_FEE) {
            revert FeeTooHigh();
        }

        uint208 feeData = _serializeFeeData(enable, fee);
        _operatorNetworkFee[vault][network].push(uint48(block.timestamp), feeData);
        emit SetOperatorNetworkFee(vault, network, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setCuratorFee(address vault, uint256 fee) public onlyCurator(vault) {
        if (fee > MAX_FEE) {
            revert FeeTooHigh();
        }

        _curatorFee[vault].push(uint48(block.timestamp), uint208(fee));
        emit SetCuratorFee(vault, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setCuratorNetworkFee(address vault, address network, bool enable, uint256 fee) public onlyCurator(vault) {
        if (fee > MAX_FEE) {
            revert FeeTooHigh();
        }

        uint208 feeData = _serializeFeeData(enable, fee);
        _curatorNetworkFee[vault][network].push(uint48(block.timestamp), feeData);
        emit SetCuratorNetworkFee(vault, network, enable, fee);
    }

    /* INTERNAL FUNCTIONS */

    /**
     * @notice Serialize fee data (enable + fee)
     * @param isEnabled Whether the fee is enabled
     * @param fee The fee amount
     * @return The serialized data
     */
    function _serializeFeeData(bool isEnabled, uint256 fee) internal pure returns (uint208) {
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
    ) internal pure returns (bool isEnabled, uint256 fee) {
        isEnabled = (data & 1) > 0;
        fee = uint256(data >> 1);
    }
}
