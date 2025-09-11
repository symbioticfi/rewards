// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStakerRewardsClaim {
    /**
     * @notice Emitted when a reward is claimed.
     * @param network network whose rewards are claimed
     * @param token address of the token
     * @param claimer address of the claimer
     * @param amount amount of tokens
     * @param recipient address of the tokens' recipient
     */
    event ClaimRewards(
        address indexed network, address indexed token, address indexed claimer, uint256 amount, address recipient
    );

    /**
     * @notice Claim rewards using a given token.
     * @param recipient address of the tokens' recipient
     * @param token address of the token
     * @param data some data to use
     */
    function claimRewards(address recipient, address token, bytes calldata data) external;
}
