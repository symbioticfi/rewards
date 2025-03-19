// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {IVaultTokenized} from "@symbioticfi/core/src/interfaces/vault/IVaultTokenized.sol";
import {IStakerRewards} from "src/interfaces/stakerRewards/IStakerRewards.sol";

contract CompoundingStakingRewards is ERC4626 {
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
     */
    function compound() external {
        uint256 maxRewards = 1;
        rewards.claimRewards(
            address(this),
            address(token),
            abi.encode(maxRewards)
        );
        uint256 rewardsBalance = token.balanceOf(address(this));
        (uint256 amount, uint256 shares) = vault.deposit(
            address(this),
            rewardsBalance
        );
        emit Compound(amount, shares);
    }
}
