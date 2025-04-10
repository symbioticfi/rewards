// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {IVaultTokenized} from "@symbioticfi/core/src/interfaces/vault/IVaultTokenized.sol";
import {IStakerRewards} from "src/interfaces/stakerRewards/IStakerRewards.sol";

contract CompoundStakerRewards is ERC4626 {
    using SafeERC20 for IERC20;

    IVaultTokenized public immutable vault;
    IERC20 public immutable token;
    IStakerRewards public immutable rewards;

    event Compound(uint256 amount, uint256 shares);

    constructor(
        IVaultTokenized _vault,
        IStakerRewards _rewards,
        string memory name,
        string memory symbol
    ) ERC4626(IERC20(address(_vault))) ERC20(name, symbol) {
        vault = _vault;
        token = IERC20(_vault.collateral());
        rewards = _rewards;
    }

    /**
     * @notice Claim staking rewards and deposit into the symbiotic vault.
     * @param network The address of the network to claim rewards from.
     * @param maxRewards The maximum number of reward distributions to claim.
     */
    function compound(address network, uint256 maxRewards) external {
        rewards.claimRewards(
            address(this),
            address(token),
            abi.encode(network, maxRewards, new bytes(0))
        );
        uint256 rewardsBalance = token.balanceOf(address(this));
        token.forceApprove(address(vault), rewardsBalance);
        (uint256 amount, uint256 shares) = vault.deposit(
            address(this),
            rewardsBalance
        );
        emit Compound(amount, shares);
    }
}
