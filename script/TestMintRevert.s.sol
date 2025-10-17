// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {Script} from "forge-std/Script.sol";

import {HypMinter, IERC20Mintable} from "../src/contracts/HypMinter.sol";

/**
 * @title TestMintRevert
 * @notice Script that calls mint() on HypMinter 3 times and expects the fourth to revert
 * @dev This script demonstrates that multiple mints in succession will eventually fail
 */
contract TestMintRevert is Script, Test {
    HypMinter public hypMinter;
    IERC20Mintable public HYPER;

    function setUp() public {
        // Get HypMinter address from environment variable
        address minterAddress = vm.envAddress("MINTER");
        hypMinter = HypMinter(minterAddress);

        // Get contract references
        HYPER = hypMinter.HYPER();

        console2.log("HypMinter address:", address(hypMinter));
        console2.log("HYPER token address:", address(HYPER));
        console2.log("Current block timestamp:", block.timestamp);
    }

    function run() public {
        console2.log("\n=== Starting Mint Test ===\n");

        uint256 initialLastRewardTimestamp = hypMinter.lastRewardTimestamp();
        console2.log("Initial lastRewardTimestamp:", initialLastRewardTimestamp);

        vm.startBroadcast();
        // First mint
        console2.log("\n--- Mint #1 ---");
        hypMinter.mint();
        console2.log("SUCCESS: First mint completed");
        console2.log("New lastRewardTimestamp:", hypMinter.lastRewardTimestamp());
        console2.log("HYPER balance of HypMinter:", HYPER.balanceOf(address(hypMinter)));

        // Second mint
        console2.log("\n--- Mint #2 ---");
        hypMinter.mint();
        console2.log("SUCCESS: Second mint completed");
        console2.log("New lastRewardTimestamp:", hypMinter.lastRewardTimestamp());
        console2.log("HYPER balance of HypMinter:", HYPER.balanceOf(address(hypMinter)));

        // Third mint
        console2.log("\n--- Mint #3 ---");
        hypMinter.mint();
        console2.log("SUCCESS: Third mint completed");
        console2.log("New lastRewardTimestamp:", hypMinter.lastRewardTimestamp());
        console2.log("HYPER balance of HypMinter:", HYPER.balanceOf(address(hypMinter)));

        vm.stopBroadcast();

        // Fourth mint should revert
        console2.log("\n--- Mint #4 (Expected to Revert) ---");
        console2.log("Attempting fourth mint...");
        vm.expectRevert("HypMinter: Epoch not ready");
        hypMinter.mint();
        console2.log("SUCCESS: Fourth mint correctly reverted with 'HypMinter: Epoch not ready'");

        assertEq(hypMinter.lastRewardTimestamp(), initialLastRewardTimestamp + 90 days);

        console2.log("\n=== Test Completed Successfully ===\n");
    }
}
