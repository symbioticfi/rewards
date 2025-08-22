// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {IFeeRegistry} from "../../interfaces/rewardsV2/IFeeRegistry.sol";

/**
 * @title FeeRegistry
 * @notice Manages fee settings for operators and curators with historical tracking
 * @dev This contract handles fee management at global, vault, network, and vault-network levels
 */
contract FeeRegistry is IFeeRegistry {
    using Checkpoints for Checkpoints.Trace208;

    /* CONSTANTS */

    uint256 constant MAX_FEE = 10_000;
    uint256 constant DEFAULT_OPERATOR_FEE = 500;
    uint256 constant DEFAULT_CURATOR_FEE = 525;

    /* STATE VARIABLES */

    // value is concat(isEnabled, fee) - packed into uint208
    mapping(address operator => Checkpoints.Trace208 value) internal _operatorGlobalFee;
    mapping(address operator => mapping(address vault => Checkpoints.Trace208 value)) internal _operatorVaultFee;
    mapping(address operator => mapping(address network => Checkpoints.Trace208 value)) internal _operatorNetworkFee;
    mapping(address operator => mapping(address vault => mapping(address network => Checkpoints.Trace208 value)))
        internal _operatorVaultNetworkFee;
    mapping(address curator => Checkpoints.Trace208 value) internal _curatorGlobalFee;
    mapping(address curator => mapping(address vault => Checkpoints.Trace208 value)) internal _curatorVaultFee;

    /* EXTERNAL FUNCTIONS */

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorFeeAt(
        address operator,
        address vault,
        address network,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (uint256 fee) {
        uint208 value = _operatorVaultNetworkFee[operator][vault][network].upperLookupRecent(timestamp, hint);
        (bool isEnabled, uint256 feeValue) = _deserializeFeeData(value);
        if (isEnabled) return feeValue;

        value = _operatorNetworkFee[operator][network].upperLookupRecent(timestamp, hint);
        (isEnabled, feeValue) = _deserializeFeeData(value);
        if (isEnabled) return feeValue;

        value = _operatorVaultFee[operator][vault].upperLookupRecent(timestamp, hint);
        (isEnabled, feeValue) = _deserializeFeeData(value);
        if (isEnabled) return feeValue;

        value = _operatorGlobalFee[operator].upperLookupRecent(timestamp, hint);
        (isEnabled, feeValue) = _deserializeFeeData(value);
        if (isEnabled) return feeValue;

        return DEFAULT_OPERATOR_FEE;
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorFee(address operator, address vault, address network) external view returns (uint256 fee) {
        uint208 value = _operatorVaultNetworkFee[operator][vault][network].latest();
        (bool isEnabled, uint256 feeValue) = _deserializeFeeData(value);
        if (isEnabled) return feeValue;

        value = _operatorNetworkFee[operator][network].latest();
        (isEnabled, feeValue) = _deserializeFeeData(value);
        if (isEnabled) return feeValue;

        value = _operatorVaultFee[operator][vault].latest();
        (isEnabled, feeValue) = _deserializeFeeData(value);
        if (isEnabled) return feeValue;

        value = _operatorGlobalFee[operator].latest();
        (isEnabled, feeValue) = _deserializeFeeData(value);
        if (isEnabled) return feeValue;

        return DEFAULT_OPERATOR_FEE;
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorGlobalFee(
        address operator
    ) external view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorGlobalFee[operator].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorVaultFee(address operator, address vault) external view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorVaultFee[operator][vault].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorNetworkFee(
        address operator,
        address network
    ) external view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorNetworkFee[operator][network].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorVaultNetworkFee(
        address operator,
        address vault,
        address network
    ) external view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorVaultNetworkFee[operator][vault][network].latest());
    }

    // return curatorVaultFee if exists else
    // return curatorGlobalFee if exists else
    // return DEFAULT_CURATOR_FEE
    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorFeeAt(
        address curator,
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (uint256 fee) {
        uint208 value = _curatorVaultFee[curator][vault].upperLookupRecent(timestamp, hint);
        (bool isEnabled, uint256 feeValue) = _deserializeFeeData(value);
        if (isEnabled) return feeValue;

        value = _curatorGlobalFee[curator].upperLookupRecent(timestamp, hint);
        (isEnabled, feeValue) = _deserializeFeeData(value);
        if (isEnabled) return feeValue;

        return DEFAULT_CURATOR_FEE;
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorFee(address curator, address vault) external view returns (uint256 fee) {
        uint208 value = _curatorVaultFee[curator][vault].latest();
        (bool isEnabled, uint256 feeValue) = _deserializeFeeData(value);
        if (isEnabled) return feeValue;

        value = _curatorGlobalFee[curator].latest();
        (isEnabled, feeValue) = _deserializeFeeData(value);
        if (isEnabled) return feeValue;

        return DEFAULT_CURATOR_FEE;
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorGlobalFee(
        address curator
    ) external view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_curatorGlobalFee[curator].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorVaultFee(address curator, address vault) external view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_curatorVaultFee[curator][vault].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorGlobalFee(bool enable, uint256 fee) external {
        uint208 packedData = _serializeFeeData(enable, fee);
        _operatorGlobalFee[msg.sender].push(uint48(block.timestamp), packedData);
        emit OperatorGlobalFeeUpdated(msg.sender, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorVaultFee(address vault, bool enable, uint256 fee) external {
        uint208 packedData = _serializeFeeData(enable, fee);
        _operatorVaultFee[msg.sender][vault].push(uint48(block.timestamp), packedData);
        emit OperatorVaultFeeUpdated(msg.sender, vault, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorNetworkFee(address network, bool enable, uint256 fee) external {
        uint208 packedData = _serializeFeeData(enable, fee);
        _operatorNetworkFee[msg.sender][network].push(uint48(block.timestamp), packedData);
        emit OperatorNetworkFeeUpdated(msg.sender, network, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorVaultNetworkFee(address vault, address network, bool enable, uint256 fee) external {
        uint208 packedData = _serializeFeeData(enable, fee);
        _operatorVaultNetworkFee[msg.sender][vault][network].push(uint48(block.timestamp), packedData);
        emit OperatorVaultNetworkFeeUpdated(msg.sender, vault, network, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setCuratorGlobalFee(bool enable, uint256 fee) external {
        uint208 packedData = _serializeFeeData(enable, fee);
        _curatorGlobalFee[msg.sender].push(uint48(block.timestamp), packedData);
        emit CuratorGlobalFeeUpdated(msg.sender, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setCuratorVaultFee(address vault, bool enable, uint256 fee) external {
        uint208 packedData = _serializeFeeData(enable, fee);
        _curatorVaultFee[msg.sender][vault].push(uint48(block.timestamp), packedData);
        emit CuratorVaultFeeUpdated(msg.sender, vault, enable, fee);
    }

    /* INTERNAL FUNCTIONS */

    /**
     * @dev Helper function for packing boolean and fee into uint208
     * @param isEnabled Whether the fee is enabled
     * @param fee The fee amount
     * @return Packed fee data
     */
    function _serializeFeeData(bool isEnabled, uint256 fee) internal pure returns (uint208) {
        if (fee > MAX_FEE) {
            revert FeeTooHigh();
        }
        // Use first bit for boolean, rest for fee
        // isEnabled goes in bit 0, fee goes in bits 1-207
        return uint208(fee << 1) | uint208(uint256(isEnabled ? 1 : 0));
    }

    /**
     * @dev Helper function for unpacking boolean and fee from uint208
     * @param packedData The packed fee data
     * @return isEnabled Whether the fee is enabled
     * @return fee The fee amount
     */
    function _deserializeFeeData(
        uint208 packedData
    ) internal pure returns (bool isEnabled, uint256 fee) {
        return ((packedData & 1) > 0, uint256(packedData >> 1));
    }
}
