// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStakerRewardsClaim {
    /**
     * @notice Claim rewards using a given token.
     * @param recipient address of the tokens' recipient
     * @param token address of the token
     * @param data some data to use
     */
    function claimRewards(address recipient, address token, bytes calldata data) external;
}
