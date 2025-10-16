// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title IProtocolFees
 * @notice Interface for managing protocol fees for different reward types and networks
 * @dev Provides the external surface for configuring, calculating and claiming protocol fees
 */
interface IProtocolFees {
    /* ERRORS */

    error FeeTooHigh();
    error InsufficientClaimableFees();

    /* EVENTS */

    event SetProtocolFee(uint64 indexed rewardsType, uint256 fee);
    event SetProtocolNetworkFee(uint64 indexed rewardsType, address indexed network, bool enable, uint256 fee);
    event DeductProtocolFee(uint64 indexed rewardsType, address indexed network, address indexed token, uint256 fees);
    event ClaimProtocolFee(address indexed token, uint256 fees);

    /* FUNCTIONS */

    /**
     * @notice Get the maximum fee value
     * @return The maximum fee value
     */
    function MAX_FEE() external view returns (uint256);

    /**
     * @notice Get the claimable protocol fees for a token
     * @param token The token address
     * @return The claimable fee amount
     */
    function claimableProtocolFees(
        address token
    ) external view returns (uint256);

    /**
     * @notice Get the protocol fee for a reward type and network
     * @param rewardsType The reward type identifier
     * @param network The network address
     * @return The protocol fee amount
     */
    function protocolFee(
        uint64 rewardsType,
        address network
    ) external view returns (uint256);

    /**
     * @notice Claim protocol fees for a token (only owner)
     * @param recipient The recipient address
     * @param token The token address
     * @return fees The amount of fees claimed
     */
    function claimProtocolFees(
        address recipient,
        address token
    ) external returns (uint256 fees);
}
