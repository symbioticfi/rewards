// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IProtocolFees} from "../../interfaces/rewardsV2/IProtocolFees.sol";
import {IFeeRegistry} from "../../interfaces/rewardsV2/IFeeRegistry.sol";

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
    string internal constant REWARDS_FEE_ID = "rewards";

    /* IMMUTABLES */

    /**
     * @inheritdoc IProtocolFees
     */
    address public immutable FEE_REGISTRY;

    /* STORAGE */

    struct ProtocolFeesStorage {
        mapping(address token => uint256 fee) _claimableFee;
    }

    // keccak256(abi.encode(uint256(keccak256("symbiotic.rewards.ProtocolFees")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant PROTOCOL_FEES_STORAGE_POSITION =
        0xaca04fd08ff691cdb4ae78510a180bcc9e13b5c0befede355a0801aecf227800;

    function _protocolFeesStorage() private pure returns (ProtocolFeesStorage storage $) {
        assembly {
            $.slot := PROTOCOL_FEES_STORAGE_POSITION
        }
    }

    /* CONSTRUCTOR */

    constructor(
        address feeRegistry
    ) {
        FEE_REGISTRY = feeRegistry;
    }

    /* PUBLIC FUNCTIONS */

    /**
     * @notice Initialize the protocol fees contract
     */
    function __ProtocolFees_init(
        address owner
    ) internal onlyInitializing {
        __Ownable_init(owner);
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
        (bool isEnabled, uint256 fee) =
            IFeeRegistry(FEE_REGISTRY).getProtocolFee(keccak256(abi.encode(REWARDS_FEE_ID, rewardsType, network)));
        if (isEnabled) {
            return fee;
        }

        (, fee) = IFeeRegistry(FEE_REGISTRY).getProtocolFee(keccak256(abi.encode(REWARDS_FEE_ID, rewardsType)));
        return fee;
    }

    /**
     * @inheritdoc IProtocolFees
     */
    function claimProtocolFees(
        address recipient,
        address token
    ) public onlyOwner returns (uint256 fees) {
        fees = claimableProtocolFees(token);
        if (fees == 0) {
            revert InsufficientClaimableFees();
        }

        _protocolFeesStorage()._claimableFee[token] = 0;
        IERC20(token).safeTransfer(recipient, fees);
        emit ClaimProtocolFee(token, fees);
    }

    /* INTERNAL FUNCTIONS */

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
        fees = amount.mulDiv(protocolFee(rewardsType, network), MAX_FEE);
        _protocolFeesStorage()._claimableFee[token] += fees;
        emit DeductProtocolFee(rewardsType, network, token, fees);
    }
}
