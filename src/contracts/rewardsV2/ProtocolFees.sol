// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IProtocolFees} from "../../interfaces/rewardsV2/IProtocolFees.sol";

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract ProtocolFees is OwnableUpgradeable, IProtocolFees {
    using SafeERC20 for IERC20;
    using Math for uint256;

    /* CONSTANTS */

    /**
     * @inheritdoc IProtocolFees
     */
    uint256 public constant MAX_FEE = 1_000_000;

    // keccak256(abi.encode(uint256(keccak256("symbiotic.rewards.ProtocolFees")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant PROTOCOL_FEES_STORAGE_POSITION =
        0xaca04fd08ff691cdb4ae78510a180bcc9e13b5c0befede355a0801aecf227800;

    /* STRUCTS */

    /**
     * @notice Storage structure for protocol fees
     */
    struct ProtocolFeesStorage {
        mapping(uint64 rewardsType => uint256 value) _fee;
        // value is enable | fee (packed as bytes32)
        mapping(uint64 rewardsType => mapping(address network => bytes32 value)) _networkFee;
        mapping(address token => uint256 fee) _claimableFee;
    }

    /* FUNCTIONS */

    /**
     * @notice Initialize the protocol fees contract
     * @param initParams Initialization parameters containing fee configurations
     */
    function __ProtocolFees_init(
        ProtocolFeesInitParams calldata initParams
    ) internal onlyInitializing {
        __Ownable_init(msg.sender);

        for (uint256 i = 0; i < initParams.fees.length; ++i) {
            if (initParams.fees[i].fee > MAX_FEE) {
                revert FeeTooHigh();
            }
            _protocolFeesStorage()._fee[initParams.fees[i].rewardsType] = initParams.fees[i].fee;
        }
    }

    /**
     * @inheritdoc IProtocolFees
     */
    function claimableProtocolFees(
        address token
    ) public view returns (uint256) {
        return _protocolFeesStorage()._claimableFee[token];
    }

    /**
     * @inheritdoc IProtocolFees
     */
    function protocolFee(
        uint64 rewardsType,
        address network
    ) public view returns (uint256) {
        bytes32 networkFeeData = _protocolFeesStorage()._networkFee[rewardsType][network];

        // Check if network fee is enabled
        if (networkFeeData != bytes32(0)) {
            (bool isEnabled, uint256 fee) = _deserializeNetworkFeeData(networkFeeData);
            if (isEnabled) {
                return fee;
            }
        }

        // Fall back to global fee for reward type
        return _protocolFeesStorage()._fee[rewardsType];
    }

    /**
     * @inheritdoc IProtocolFees
     */
    function setProtocolFee(
        uint64 rewardsType,
        uint256 fee
    ) public onlyOwner {
        if (fee > MAX_FEE) {
            revert FeeTooHigh();
        }
        _protocolFeesStorage()._fee[rewardsType] = fee;
        emit SetProtocolFee(rewardsType, fee);
    }

    /**
     * @inheritdoc IProtocolFees
     */
    function setProtocolNetworkFee(
        uint64 rewardsType,
        address network,
        bool enable,
        uint256 fee
    ) public onlyOwner {
        if (fee > MAX_FEE) {
            revert FeeTooHigh();
        }
        bytes32 feeData = _serializeNetworkFeeData(enable, fee);
        _protocolFeesStorage()._networkFee[rewardsType][network] = feeData;
        emit SetProtocolNetworkFee(rewardsType, network, enable, fee);
    }

    /**
     * @inheritdoc IProtocolFees
     */
    function claimProtocolFees(
        address recipient,
        address token
    ) public onlyOwner returns (uint256 fees) {
        fees = _protocolFeesStorage()._claimableFee[token];
        if (fees == 0) {
            revert InsufficientClaimableFees();
        }

        _protocolFeesStorage()._claimableFee[token] = 0;
        IERC20(token).safeTransfer(recipient, fees);
        emit ClaimProtocolFee(token, fees);
    }

    /**
     * @notice Deduct protocol fees from an amount
     * @param rewardsType The reward type identifier
     * @param network The network address
     * @param token The token address
     * @param amount The amount to deduct fees from
     * @return fees The fees deducted
     */
    function _deductProtocolFees(
        uint64 rewardsType,
        address network,
        address token,
        uint256 amount
    ) internal returns (uint256 fees) {
        uint256 feeRate = protocolFee(rewardsType, network);
        if (feeRate > 0) {
            fees = amount.mulDiv(feeRate, MAX_FEE);
            _protocolFeesStorage()._claimableFee[token] += fees;
            emit DeductProtocolFee(rewardsType, network, token, fees);
        }
    }

    /* INTERNAL FUNCTIONS */

    /**
     * @notice Get the protocol fees storage
     * @return $ The storage struct
     */
    function _protocolFeesStorage() private pure returns (ProtocolFeesStorage storage $) {
        assembly {
            $.slot := PROTOCOL_FEES_STORAGE_POSITION
        }
    }

    /**
     * @notice Serialize network fee data
     * @param isEnabled Whether the fee is enabled
     * @param fee The fee amount
     * @return The serialized data
     */
    function _serializeNetworkFeeData(
        bool isEnabled,
        uint256 fee
    ) private pure returns (bytes32) {
        return bytes32((fee << 1) | (isEnabled ? 1 : 0));
    }

    /**
     * @notice Deserialize network fee data
     * @param data The serialized data
     * @return isEnabled Whether the fee is enabled
     * @return fee The fee amount
     */
    function _deserializeNetworkFeeData(
        bytes32 data
    ) private pure returns (bool, uint256) {
        return ((uint256(data) & 1) > 0, uint256(data) >> 1);
    }
}
