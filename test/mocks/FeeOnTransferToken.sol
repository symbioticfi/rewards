// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title FeeOnTransferToken
 * @notice Mock ERC20 token that charges a fee on transfers
 * @dev This token charges a 1% fee on all transfers, which is sent to the contract itself
 */
contract FeeOnTransferToken is ERC20 {
    uint256 public constant FEE_RATE = 100; // 1% fee (100 basis points)
    uint256 public constant FEE_DENOMINATOR = 10_000;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1_000_000 * 10 ** 18); // Mint 1M tokens to deployer
    }

    function _update(address from, address to, uint256 value) internal override {
        if (from != address(0) && to != address(0)) {
            // Calculate fee
            uint256 fee = (value * FEE_RATE) / FEE_DENOMINATOR;
            uint256 transferAmount = value - fee;

            // Transfer the amount minus fee
            super._update(from, to, transferAmount);

            // Transfer fee to this contract
            if (fee > 0) {
                super._update(from, address(this), fee);
            }
        } else {
            // For minting and burning, no fee
            super._update(from, to, value);
        }
    }
}
