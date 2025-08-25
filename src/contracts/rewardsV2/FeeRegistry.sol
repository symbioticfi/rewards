// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IFeeRegistry} from "../../interfaces/rewardsV2/IFeeRegistry.sol";

import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {StaticDelegateCallable} from "@symbioticfi/core/src/contracts/common/StaticDelegateCallable.sol";

/**
 * @title FeeRegistry
 * @notice Manages fee settings for operators and curators with historical tracking
 * @dev This contract handles fee management at global, vault, network, and vault-network levels
 */
contract FeeRegistry is IFeeRegistry, StaticDelegateCallable {
    using Checkpoints for Checkpoints.Trace208;

    /* CONSTANTS */

    uint256 constant MAX_FEE = 10_000;
    uint256 constant DEFAULT_OPERATOR_FEE = 500;
    uint256 constant DEFAULT_CURATOR_FEE = 525;

    /* STATE VARIABLES */

    mapping(address operator => Checkpoints.Trace208 value) internal _operatorGlobalFee;
    mapping(address operator => mapping(address vault => Checkpoints.Trace208 value)) internal _operatorVaultFee;
    mapping(address operator => mapping(address network => Checkpoints.Trace208 value)) internal _operatorNetworkFee;
    mapping(address operator => mapping(address vault => mapping(address network => Checkpoints.Trace208 value)))
        internal _operatorVaultNetworkFee;
    mapping(address curator => Checkpoints.Trace208 value) internal _curatorGlobalFee;
    mapping(address curator => mapping(address vault => Checkpoints.Trace208 value)) internal _curatorVaultFee;

    /* PUBLIC FUNCTIONS */

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorFeeAt(
        address operator,
        address vault,
        address network,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (uint256 fee) {
        (bool isEnabled, uint256 feeValue) = getOperatorVaultNetworkFeeAt(operator, vault, network, timestamp, hint);
        if (isEnabled) return feeValue;

        (isEnabled, feeValue) = getOperatorNetworkFeeAt(operator, network, timestamp, hint);
        if (isEnabled) return feeValue;

        (isEnabled, feeValue) = getOperatorVaultFeeAt(operator, vault, timestamp, hint);
        if (isEnabled) return feeValue;

        (isEnabled, feeValue) = getOperatorGlobalFeeAt(operator, timestamp, hint);
        if (isEnabled) return feeValue;

        return DEFAULT_OPERATOR_FEE;
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorFee(address operator, address vault, address network) public view returns (uint256 fee) {
        (bool isEnabled, uint256 feeValue) = getOperatorVaultNetworkFee(operator, vault, network);
        if (isEnabled) return feeValue;

        (isEnabled, feeValue) = getOperatorNetworkFee(operator, network);
        if (isEnabled) return feeValue;

        (isEnabled, feeValue) = getOperatorVaultFee(operator, vault);
        if (isEnabled) return feeValue;

        (isEnabled, feeValue) = getOperatorGlobalFee(operator);
        if (isEnabled) return feeValue;

        return DEFAULT_OPERATOR_FEE;
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorGlobalFeeAt(
        address operator,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorGlobalFee[operator].upperLookupRecent(timestamp, hint));
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorGlobalFee(
        address operator
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorGlobalFee[operator].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorVaultFeeAt(
        address operator,
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorVaultFee[operator][vault].upperLookupRecent(timestamp, hint));
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorVaultFee(address operator, address vault) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorVaultFee[operator][vault].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorNetworkFeeAt(
        address operator,
        address network,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorNetworkFee[operator][network].upperLookupRecent(timestamp, hint));
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorNetworkFee(
        address operator,
        address network
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorNetworkFee[operator][network].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorVaultNetworkFeeAt(
        address operator,
        address vault,
        address network,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (bool isEnabled, uint256 fee) {
        return
            _deserializeFeeData(_operatorVaultNetworkFee[operator][vault][network].upperLookupRecent(timestamp, hint));
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorVaultNetworkFee(
        address operator,
        address vault,
        address network
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_operatorVaultNetworkFee[operator][vault][network].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorFeeAt(
        address curator,
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (uint256 fee) {
        (bool isEnabled, uint256 feeValue) = getCuratorVaultFeeAt(curator, vault, timestamp, hint);
        if (isEnabled) return feeValue;

        (isEnabled, feeValue) = getCuratorGlobalFeeAt(curator, timestamp, hint);
        if (isEnabled) return feeValue;

        return DEFAULT_CURATOR_FEE;
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorFee(address curator, address vault) public view returns (uint256 fee) {
        (bool isEnabled, uint256 feeValue) = getCuratorVaultFee(curator, vault);
        if (isEnabled) return feeValue;

        (isEnabled, feeValue) = getCuratorGlobalFee(curator);
        if (isEnabled) return feeValue;

        return DEFAULT_CURATOR_FEE;
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorGlobalFeeAt(
        address curator,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_curatorGlobalFee[curator].upperLookupRecent(timestamp, hint));
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorGlobalFee(
        address curator
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_curatorGlobalFee[curator].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorVaultFeeAt(
        address curator,
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_curatorVaultFee[curator][vault].upperLookupRecent(timestamp, hint));
    }
    /**
     * @inheritdoc IFeeRegistry
     */

    function getCuratorVaultFee(address curator, address vault) public view returns (bool isEnabled, uint256 fee) {
        return _deserializeFeeData(_curatorVaultFee[curator][vault].latest());
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorGlobalFee(bool enable, uint256 fee) public {
        _operatorGlobalFee[msg.sender].push(uint48(block.timestamp), _serializeFeeData(enable, fee));
        emit SetOperatorGlobalFee(msg.sender, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorVaultFee(address vault, bool enable, uint256 fee) public {
        _operatorVaultFee[msg.sender][vault].push(uint48(block.timestamp), _serializeFeeData(enable, fee));
        emit SetOperatorVaultFee(msg.sender, vault, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorNetworkFee(address network, bool enable, uint256 fee) public {
        _operatorNetworkFee[msg.sender][network].push(uint48(block.timestamp), _serializeFeeData(enable, fee));
        emit SetOperatorNetworkFee(msg.sender, network, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorVaultNetworkFee(address vault, address network, bool enable, uint256 fee) public {
        _operatorVaultNetworkFee[msg.sender][vault][network].push(
            uint48(block.timestamp), _serializeFeeData(enable, fee)
        );
        emit SetOperatorVaultNetworkFee(msg.sender, vault, network, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setCuratorGlobalFee(bool enable, uint256 fee) public {
        _curatorGlobalFee[msg.sender].push(uint48(block.timestamp), _serializeFeeData(enable, fee));
        emit SetCuratorGlobalFee(msg.sender, enable, fee);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setCuratorVaultFee(address vault, bool enable, uint256 fee) public {
        _curatorVaultFee[msg.sender][vault].push(uint48(block.timestamp), _serializeFeeData(enable, fee));
        emit SetCuratorVaultFee(msg.sender, vault, enable, fee);
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
        return (packedData & 1 > 0, uint256(packedData >> 1));
    }
}
