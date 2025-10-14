// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title IProtocolFees
 */
interface IProtocolFees {
    /* ERRORS */

    error FeeTooHigh();
    error InsufficientClaimableFees();

    /* STRUCTS */

    struct ProtocolFeesInitParams {
        RewardsTypeFee[] fees;
    }

    struct RewardsTypeFee {
        uint64 rewardsType;
        uint256 fee;
    }

    /* EVENTS */

    event SetProtocolFee(uint64 indexed rewardsType, uint256 fee);
    event SetProtocolNetworkFee(uint64 indexed rewardsType, address indexed network, bool enable, uint256 fee);
    event DeductProtocolFee(uint64 indexed rewardsType, address indexed network, address indexed token, uint256 fees);
    event ClaimProtocolFee(address indexed token, uint256 fees);

    /* FUNCTIONS */

    function claimableProtocolFees(
        address token
    ) external view returns (uint256);

    function protocolFee(uint64 rewardsType, address network) external view returns (uint256);

    function setProtocolFee(uint64 rewardsType, uint256 fee) external;

    function setProtocolNetworkFee(uint64 rewardsType, address network, bool enable, uint256 fee) external;

    function claimProtocolFees(address recipient, address token) external returns (uint256 fees);
}
