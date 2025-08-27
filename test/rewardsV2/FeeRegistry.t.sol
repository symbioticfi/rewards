// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";

import {FeeRegistry} from "../../src/contracts/rewardsV2/FeeRegistry.sol";
import {IFeeRegistry} from "../../src/interfaces/rewardsV2/IFeeRegistry.sol";

contract FeeRegistryTest is Test {
    FeeRegistry feeRegistry;

    address operator;
    address curator;
    address vault;
    address network;

    uint256 operatorPrivateKey;
    uint256 curatorPrivateKey;

    // Constants from the contract
    uint256 constant MAX_FEE = 10_000;
    uint256 constant DEFAULT_OPERATOR_FEE = 500;
    uint256 constant DEFAULT_CURATOR_FEE = 525;

    function setUp() public {
        (operator, operatorPrivateKey) = makeAddrAndKey("operator");
        (curator, curatorPrivateKey) = makeAddrAndKey("curator");
        (vault,) = makeAddrAndKey("vault");
        (network,) = makeAddrAndKey("network");

        feeRegistry = new FeeRegistry();
    }

    function test_OperatorGlobalFee_SetAndGet() public {
        vm.startPrank(operator);

        (bool isEnabled, uint256 fee) = feeRegistry.getOperatorGlobalFee(operator);
        assertFalse(isEnabled);
        assertEq(fee, 0);

        uint256 testFee = 1000;
        feeRegistry.setOperatorGlobalFee(true, testFee);

        (isEnabled, fee) = feeRegistry.getOperatorGlobalFee(operator);
        assertTrue(isEnabled);
        assertEq(fee, testFee);

        vm.stopPrank();
    }

    function test_OperatorGlobalFee_Disable() public {
        vm.startPrank(operator);

        feeRegistry.setOperatorGlobalFee(true, 1000);
        feeRegistry.setOperatorGlobalFee(false, 0);

        (bool isEnabled, uint256 fee) = feeRegistry.getOperatorGlobalFee(operator);
        assertFalse(isEnabled);
        assertEq(fee, 0);

        vm.stopPrank();
    }

    function test_OperatorVaultFee_SetAndGet() public {
        vm.startPrank(operator);

        uint256 testFee = 1500;
        feeRegistry.setOperatorVaultFee(vault, true, testFee);

        (bool isEnabled, uint256 fee) = feeRegistry.getOperatorVaultFee(operator, vault);
        assertTrue(isEnabled);
        assertEq(fee, testFee);

        vm.stopPrank();
    }

    function test_OperatorNetworkFee_SetAndGet() public {
        vm.startPrank(operator);

        uint256 testFee = 1200;
        feeRegistry.setOperatorNetworkFee(network, true, testFee);

        (bool isEnabled, uint256 fee) = feeRegistry.getOperatorNetworkFee(operator, network);
        assertTrue(isEnabled);
        assertEq(fee, testFee);

        vm.stopPrank();
    }

    function test_OperatorVaultNetworkFee_SetAndGet() public {
        vm.startPrank(operator);

        uint256 testFee = 1800;
        feeRegistry.setOperatorVaultNetworkFee(vault, network, true, testFee);

        (bool isEnabled, uint256 fee) = feeRegistry.getOperatorVaultNetworkFee(operator, vault, network);
        assertTrue(isEnabled);
        assertEq(fee, testFee);

        vm.stopPrank();
    }

    function test_CuratorGlobalFee_SetAndGet() public {
        vm.startPrank(curator);

        (bool isEnabled, uint256 fee) = feeRegistry.getCuratorGlobalFee(curator);
        assertFalse(isEnabled);
        assertEq(fee, 0);

        uint256 testFee = 800;
        feeRegistry.setCuratorGlobalFee(true, testFee);

        (isEnabled, fee) = feeRegistry.getCuratorGlobalFee(curator);
        assertTrue(isEnabled);
        assertEq(fee, testFee);

        vm.stopPrank();
    }

    function test_CuratorVaultFee_SetAndGet() public {
        vm.startPrank(curator);

        uint256 testFee = 900;
        feeRegistry.setCuratorVaultFee(vault, true, testFee);

        (bool isEnabled, uint256 fee) = feeRegistry.getCuratorVaultFee(curator, vault);
        assertTrue(isEnabled);
        assertEq(fee, testFee);

        vm.stopPrank();
    }

    function test_OperatorFeeHierarchy_VaultNetworkOverride() public {
        vm.startPrank(operator);

        // Set fees at different levels
        feeRegistry.setOperatorGlobalFee(true, 1000);
        feeRegistry.setOperatorVaultFee(vault, true, 1500);
        feeRegistry.setOperatorNetworkFee(network, true, 1200);
        feeRegistry.setOperatorVaultNetworkFee(vault, network, true, 2000);

        // Vault-network fee should override all others
        uint256 fee = feeRegistry.getOperatorFee(operator, vault, network);
        assertEq(fee, 2000);

        vm.stopPrank();
    }

    function test_OperatorFeeHierarchy_NetworkOverride() public {
        vm.startPrank(operator);

        // Set fees at different levels (no vault-network fee)
        feeRegistry.setOperatorGlobalFee(true, 1000);
        feeRegistry.setOperatorVaultFee(vault, true, 1500);
        feeRegistry.setOperatorNetworkFee(network, true, 1200);

        // Network fee should override global and vault fees
        uint256 fee = feeRegistry.getOperatorFee(operator, vault, network);
        assertEq(fee, 1200);

        vm.stopPrank();
    }

    function test_OperatorFeeHierarchy_VaultOverride() public {
        vm.startPrank(operator);

        // Set fees at different levels (no network or vault-network fees)
        feeRegistry.setOperatorGlobalFee(true, 1000);
        feeRegistry.setOperatorVaultFee(vault, true, 1500);

        // Vault fee should override global fee
        uint256 fee = feeRegistry.getOperatorFee(operator, vault, network);
        assertEq(fee, 1500);

        vm.stopPrank();
    }

    function test_OperatorFeeHierarchy_GlobalFallback() public {
        vm.startPrank(operator);

        // Only set global fee
        feeRegistry.setOperatorGlobalFee(true, 1000);

        // Should fall back to global fee
        uint256 fee = feeRegistry.getOperatorFee(operator, vault, network);
        assertEq(fee, 1000);

        vm.stopPrank();
    }

    function test_OperatorFeeHierarchy_DefaultFallback() public view {
        // No fees set, should return default
        uint256 fee = feeRegistry.getOperatorFee(operator, vault, network);
        assertEq(fee, DEFAULT_OPERATOR_FEE);
    }

    function test_CuratorFeeHierarchy_VaultOverride() public {
        vm.startPrank(curator);

        // Set fees at different levels
        feeRegistry.setCuratorGlobalFee(true, 800);
        feeRegistry.setCuratorVaultFee(vault, true, 900);

        // Vault fee should override global fee
        uint256 fee = feeRegistry.getCuratorFee(curator, vault);
        assertEq(fee, 900);

        vm.stopPrank();
    }

    function test_CuratorFeeHierarchy_GlobalFallback() public {
        vm.startPrank(curator);

        // Only set global fee
        feeRegistry.setCuratorGlobalFee(true, 800);

        // Should fall back to global fee
        uint256 fee = feeRegistry.getCuratorFee(curator, vault);
        assertEq(fee, 800);

        vm.stopPrank();
    }

    function test_CuratorFeeHierarchy_DefaultFallback() public view {
        // No fees set, should return default
        uint256 fee = feeRegistry.getCuratorFee(curator, vault);
        assertEq(fee, DEFAULT_CURATOR_FEE);
    }

    function test_HistoricalFeeQuery() public {
        vm.startPrank(operator);

        // Set fee at timestamp 100
        vm.warp(100);
        feeRegistry.setOperatorGlobalFee(true, 1000);

        // Set fee at timestamp 200
        vm.warp(200);
        feeRegistry.setOperatorGlobalFee(true, 2000);

        // Query at timestamp 150 (should return fee from timestamp 100)
        (bool isEnabled, uint256 fee) = feeRegistry.getOperatorGlobalFeeAt(operator, uint48(150), "");
        assertTrue(isEnabled);
        assertEq(fee, 1000);

        vm.stopPrank();
    }

    function test_RevertFeeTooHigh() public {
        vm.startPrank(operator);

        vm.expectRevert(IFeeRegistry.FeeTooHigh.selector);
        feeRegistry.setOperatorGlobalFee(true, MAX_FEE + 1);

        vm.stopPrank();
    }

    function test_RevertFeeTooHigh_Curator() public {
        vm.startPrank(curator);

        vm.expectRevert(IFeeRegistry.FeeTooHigh.selector);
        feeRegistry.setCuratorGlobalFee(true, MAX_FEE + 1);

        vm.stopPrank();
    }

    function test_AllowMaxFee() public {
        vm.startPrank(operator);

        // Should not revert with MAX_FEE
        feeRegistry.setOperatorGlobalFee(true, MAX_FEE);

        (bool isEnabled, uint256 fee) = feeRegistry.getOperatorGlobalFee(operator);
        assertTrue(isEnabled);
        assertEq(fee, MAX_FEE);

        vm.stopPrank();
    }

    function test_EventEmission_OperatorGlobalFee() public {
        vm.startPrank(operator);

        vm.expectEmit(true, false, false, true);
        emit IFeeRegistry.SetOperatorGlobalFee(operator, true, 1000);
        feeRegistry.setOperatorGlobalFee(true, 1000);

        vm.stopPrank();
    }

    function test_EventEmission_OperatorVaultFee() public {
        vm.startPrank(operator);

        vm.expectEmit(true, true, false, true);
        emit IFeeRegistry.SetOperatorVaultFee(operator, vault, true, 1500);
        feeRegistry.setOperatorVaultFee(vault, true, 1500);

        vm.stopPrank();
    }

    function test_EventEmission_OperatorNetworkFee() public {
        vm.startPrank(operator);

        vm.expectEmit(true, true, false, true);
        emit IFeeRegistry.SetOperatorNetworkFee(operator, network, true, 1200);
        feeRegistry.setOperatorNetworkFee(network, true, 1200);

        vm.stopPrank();
    }

    function test_EventEmission_OperatorVaultNetworkFee() public {
        vm.startPrank(operator);

        vm.expectEmit(true, true, true, true);
        emit IFeeRegistry.SetOperatorVaultNetworkFee(operator, vault, network, true, 2000);
        feeRegistry.setOperatorVaultNetworkFee(vault, network, true, 2000);

        vm.stopPrank();
    }

    function test_EventEmission_CuratorGlobalFee() public {
        vm.startPrank(curator);

        vm.expectEmit(true, false, false, true);
        emit IFeeRegistry.SetCuratorGlobalFee(curator, true, 800);
        feeRegistry.setCuratorGlobalFee(true, 800);

        vm.stopPrank();
    }

    function test_EventEmission_CuratorVaultFee() public {
        vm.startPrank(curator);

        vm.expectEmit(true, true, false, true);
        emit IFeeRegistry.SetCuratorVaultFee(curator, vault, true, 900);
        feeRegistry.setCuratorVaultFee(vault, true, 900);

        vm.stopPrank();
    }

    function test_DisableAndReenableFee() public {
        vm.startPrank(operator);

        // Set fee, disable it, then re-enable
        feeRegistry.setOperatorGlobalFee(true, 1000);
        feeRegistry.setOperatorGlobalFee(false, 0);
        feeRegistry.setOperatorGlobalFee(true, 1500);

        (bool isEnabled, uint256 fee) = feeRegistry.getOperatorGlobalFee(operator);
        assertTrue(isEnabled);
        assertEq(fee, 1500);

        vm.stopPrank();
    }
}
