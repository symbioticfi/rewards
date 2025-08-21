// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Checkpoints} from "@symbioticfi/core/src/contracts/libraries/Checkpoints.sol";
import {Time} from "@openzeppelin/contracts/utils/types/Time.sol";
import {IFeeRegistry} from "../../interfaces/rewardsV2/IFeeRegistry.sol";

/**
 * @title FeeRegistry
 * @notice Manages fee settings for operators and curators with historical tracking
 * @dev This contract handles fee management at global, vault, network, and vault-network levels
 */
contract FeeRegistry is IFeeRegistry {
    using Checkpoints for Checkpoints.Trace208;

    // Constants
    uint256 constant MAX_FEE = 10_000;
    uint256 constant DEFAULT_OPERATOR_FEE = 500;
    uint256 constant DEFAULT_CURATOR_FEE = 525;

    // State variables
    // value is concat(isEnabled, fee) - packed into uint208
    mapping(address operator => Checkpoints.Trace208 value) operatorGlobalFee;
    mapping(address operator => mapping(address vault => Checkpoints.Trace208 value)) operatorVaultFee;
    mapping(address operator => mapping(address network => Checkpoints.Trace208 value)) operatorNetworkFee;
    mapping(address operator => mapping(address vault => mapping(address network => Checkpoints.Trace208 value)))
        operatorVaultNetworkFee;

    mapping(address curator => Checkpoints.Trace208 value) curatorGlobalFee;
    mapping(address curator => mapping(address vault => Checkpoints.Trace208 value)) curatorVaultFee;

    // External functions
    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorGlobalFee(bool enable, uint256 fee) external {
        uint208 packedData = packFeeData(enable, fee);
        uint48 timestamp = Time.timestamp();
        operatorGlobalFee[msg.sender].push(timestamp, packedData);
        emit OperatorGlobalFeeUpdated(msg.sender, enable, fee, timestamp);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorVaultFee(address vault, bool enable, uint256 fee) external {
        uint208 packedData = packFeeData(enable, fee);
        uint48 timestamp = Time.timestamp();
        operatorVaultFee[msg.sender][vault].push(timestamp, packedData);
        emit OperatorVaultFeeUpdated(msg.sender, vault, enable, fee, timestamp);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorNetworkFee(address network, bool enable, uint256 fee) external {
        uint208 packedData = packFeeData(enable, fee);
        uint48 timestamp = Time.timestamp();
        operatorNetworkFee[msg.sender][network].push(timestamp, packedData);
        emit OperatorNetworkFeeUpdated(msg.sender, network, enable, fee, timestamp);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setOperatorVaultNetworkFee(address vault, address network, bool enable, uint256 fee) external {
        uint208 packedData = packFeeData(enable, fee);
        uint48 timestamp = Time.timestamp();
        operatorVaultNetworkFee[msg.sender][vault][network].push(timestamp, packedData);
        emit OperatorVaultNetworkFeeUpdated(msg.sender, vault, network, enable, fee, timestamp);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setCuratorGlobalFee(bool enable, uint256 fee) external {
        uint208 packedData = packFeeData(enable, fee);
        uint48 timestamp = Time.timestamp();
        curatorGlobalFee[msg.sender].push(timestamp, packedData);
        emit CuratorGlobalFeeUpdated(msg.sender, enable, fee, timestamp);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function setCuratorVaultFee(address vault, bool enable, uint256 fee) external {
        uint208 packedData = packFeeData(enable, fee);
        uint48 timestamp = Time.timestamp();
        curatorVaultFee[msg.sender][vault].push(timestamp, packedData);
        emit CuratorVaultFeeUpdated(msg.sender, vault, enable, fee, timestamp);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorFeeAt(
        address operator,
        address vault,
        address network,
        uint48 timestamp
    ) external view returns (uint256 fee) {
        (bool exists,, uint208 value, uint32 pos) =
            operatorVaultNetworkFee[operator][vault][network].upperLookupRecentCheckpoint(timestamp);
        if (exists) {
            (bool isEnabled, uint256 feeValue) = unpackFeeData(value);
            if (isEnabled) return feeValue;
        }
        (exists,, value, pos) = operatorNetworkFee[operator][network].upperLookupRecentCheckpoint(timestamp);
        if (exists) {
            (bool isEnabled, uint256 feeValue) = unpackFeeData(value);
            if (isEnabled) return feeValue;
        }
        (exists,, value, pos) = operatorVaultFee[operator][vault].upperLookupRecentCheckpoint(timestamp);
        if (exists) {
            (bool isEnabled, uint256 feeValue) = unpackFeeData(value);
            if (isEnabled) return feeValue;
        }
        (exists,, value, pos) = operatorGlobalFee[operator].upperLookupRecentCheckpoint(timestamp);
        if (exists) {
            (bool isEnabled, uint256 feeValue) = unpackFeeData(value);
            if (isEnabled) return feeValue;
        }
        return DEFAULT_OPERATOR_FEE;
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorFee(address operator, address vault, address network) external view returns (uint256 fee) {
        (bool exists,, uint208 value) = operatorVaultNetworkFee[operator][vault][network].latestCheckpoint();
        if (exists) {
            (bool isEnabled, uint256 feeValue) = unpackFeeData(value);
            if (isEnabled) return feeValue;
        }
        (exists,, value) = operatorNetworkFee[operator][network].latestCheckpoint();
        if (exists) {
            (bool isEnabled, uint256 feeValue) = unpackFeeData(value);
            if (isEnabled) return feeValue;
        }
        (exists,, value) = operatorVaultFee[operator][vault].latestCheckpoint();
        if (exists) {
            (bool isEnabled, uint256 feeValue) = unpackFeeData(value);
            if (isEnabled) return feeValue;
        }
        (exists,, value) = operatorGlobalFee[operator].latestCheckpoint();
        if (exists) {
            (bool isEnabled, uint256 feeValue) = unpackFeeData(value);
            if (isEnabled) return feeValue;
        }
        return DEFAULT_OPERATOR_FEE;
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorGlobalFee(
        address operator
    ) external view returns (bool isEnabled, uint256 fee) {
        (bool exists,, uint208 value) = operatorGlobalFee[operator].latestCheckpoint();
        if (!exists) return (false, 0);
        return unpackFeeData(value);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorVaultFee(address operator, address vault) external view returns (bool isEnabled, uint256 fee) {
        (bool exists,, uint208 value) = operatorVaultFee[operator][vault].latestCheckpoint();
        if (!exists) return (false, 0);
        return unpackFeeData(value);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorNetworkFee(
        address operator,
        address network
    ) external view returns (bool isEnabled, uint256 fee) {
        (bool exists,, uint208 value) = operatorNetworkFee[operator][network].latestCheckpoint();
        if (!exists) return (false, 0);
        return unpackFeeData(value);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getOperatorVaultNetworkFee(
        address operator,
        address vault,
        address network
    ) external view returns (bool isEnabled, uint256 fee) {
        (bool exists,, uint208 value) = operatorVaultNetworkFee[operator][vault][network].latestCheckpoint();
        if (!exists) return (false, 0);
        return unpackFeeData(value);
    }

    // return curatorVaultFee if exists else
    // return curatorGlobalFee if exists else
    // return DEFAULT_CURATOR_FEE
    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorFeeAt(address curator, address vault, uint48 timestamp) external view returns (uint256 fee) {
        (bool exists,, uint208 value, uint32 pos) =
            curatorVaultFee[curator][vault].upperLookupRecentCheckpoint(timestamp);
        if (exists) {
            (bool isEnabled, uint256 feeValue) = unpackFeeData(value);
            if (isEnabled) return feeValue;
        }
        (exists,, value, pos) = curatorGlobalFee[curator].upperLookupRecentCheckpoint(timestamp);
        if (exists) {
            (bool isEnabled, uint256 feeValue) = unpackFeeData(value);
            if (isEnabled) return feeValue;
        }
        return DEFAULT_CURATOR_FEE;
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorFee(address curator, address vault) external view returns (uint256 fee) {
        (bool exists,, uint208 value) = curatorVaultFee[curator][vault].latestCheckpoint();
        if (exists) {
            (bool isEnabled, uint256 feeValue) = unpackFeeData(value);
            if (isEnabled) return feeValue;
        }
        (exists,, value) = curatorGlobalFee[curator].latestCheckpoint();
        if (exists) {
            (bool isEnabled, uint256 feeValue) = unpackFeeData(value);
            if (isEnabled) return feeValue;
        }
        return DEFAULT_CURATOR_FEE;
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorGlobalFee(
        address curator
    ) external view returns (bool isEnabled, uint256 fee) {
        (bool exists,, uint208 value) = curatorGlobalFee[curator].latestCheckpoint();
        if (!exists) return (false, 0);
        return unpackFeeData(value);
    }

    /**
     * @inheritdoc IFeeRegistry
     */
    function getCuratorVaultFee(address curator, address vault) external view returns (bool isEnabled, uint256 fee) {
        (bool exists,, uint208 value) = curatorVaultFee[curator][vault].latestCheckpoint();
        if (!exists) return (false, 0);
        return unpackFeeData(value);
    }

    // Internal functions
    /**
     * @dev Helper function for packing boolean and fee into uint208
     * @param isEnabled Whether the fee is enabled
     * @param fee The fee amount
     * @return Packed fee data
     */
    function packFeeData(bool isEnabled, uint256 fee) internal pure returns (uint208) {
        require(fee <= MAX_FEE, "Fee too high");
        // Use first bit for boolean, rest for fee
        // isEnabled goes in bit 0, fee goes in bits 1-207
        return uint208(uint256(isEnabled ? 1 : 0) | (fee << 1));
    }

    /**
     * @dev Helper function for unpacking boolean and fee from uint208
     * @param packedData The packed fee data
     * @return isEnabled Whether the fee is enabled
     * @return fee The fee amount
     */
    function unpackFeeData(
        uint208 packedData
    ) internal pure returns (bool isEnabled, uint256 fee) {
        isEnabled = (packedData & 1) == 1;
        fee = uint256(packedData >> 1);
    }
}
