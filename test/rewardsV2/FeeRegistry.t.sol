// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";

import {CuratorRegistry} from "../../src/contracts/rewardsV2/CuratorRegistry.sol";
import {FeeRegistry} from "../../src/contracts/rewardsV2/FeeRegistry.sol";
import {IFeeRegistry} from "../../src/interfaces/rewardsV2/IFeeRegistry.sol";
import {MockVault} from "../mocks/MockVault.sol";

contract FeeRegistryTest is Test {
    FeeRegistry feeRegistry;
    CuratorRegistry curatorRegistry;
    MockVault vaultContract;

    address owner;
    address curator;
    address network;
    address nonCurator;
    address vault;

    uint256 constant MAX_FEE = 1_000_000;
    uint256 constant MAX_PARTICIPANT_FEE = 500_000;

    function setUp() public {
        owner = makeAddr("owner");
        curator = makeAddr("curator");
        network = makeAddr("network");
        nonCurator = makeAddr("nonCurator");

        curatorRegistry = new CuratorRegistry();
        feeRegistry = new FeeRegistry(address(curatorRegistry));

        vm.prank(owner);
        feeRegistry.initialize(owner);

        vaultContract = new MockVault(owner, makeAddr("delegator"), makeAddr("burner"));
        vault = address(vaultContract);

        vm.prank(owner);
        curatorRegistry.setCurator(vault, curator);
    }

    function test_Constructor() public {
        assertEq(address(feeRegistry.CURATOR_REGISTRY()), address(curatorRegistry));
        assertEq(feeRegistry.MAX_FEE(), MAX_FEE);
        assertEq(feeRegistry.MAX_PARTICIPANT_FEE(), MAX_PARTICIPANT_FEE);
    }

    function test_Initialize() public {
        FeeRegistry newFeeRegistry = new FeeRegistry(address(curatorRegistry));

        vm.prank(owner);
        newFeeRegistry.initialize(owner);

        assertEq(newFeeRegistry.owner(), owner);
    }

    function test_SetOperatorsFee() public {
        uint256 fee = 5000;

        vm.expectEmit(true, true, true, true);
        emit IFeeRegistry.SetOperatorsFee(vault, fee);

        vm.prank(curator);
        feeRegistry.setOperatorsFee(vault, fee);

        assertEq(feeRegistry.getOperatorsDefaultFee(vault), fee);
    }

    function test_SetOperatorsFee_RevertWhen_NotCurator() public {
        uint256 fee = 5000;

        vm.prank(nonCurator);
        vm.expectRevert(IFeeRegistry.NotCurator.selector);
        feeRegistry.setOperatorsFee(vault, fee);
    }

    function test_SetOperatorsFee_RevertWhen_FeeTooHigh() public {
        uint256 fee = MAX_PARTICIPANT_FEE + 1;

        vm.prank(curator);
        vm.expectRevert(IFeeRegistry.FeeTooHigh.selector);
        feeRegistry.setOperatorsFee(vault, fee);
    }

    function test_SetOperatorsNetworkFee() public {
        uint256 fee = 3000;
        bool enable = true;

        vm.expectEmit(true, true, true, true);
        emit IFeeRegistry.SetOperatorsNetworkFee(vault, network, enable, fee);

        vm.prank(curator);
        feeRegistry.setOperatorsNetworkFee(vault, network, enable, fee);

        (bool isEnabled, uint256 returnedFee) = feeRegistry.getOperatorsNetworkFee(vault, network);
        assertTrue(isEnabled);
        assertEq(returnedFee, fee);
    }

    function test_SetOperatorsNetworkFee_Disabled() public {
        uint256 fee = 3000;
        bool enable = false;

        vm.prank(curator);
        feeRegistry.setOperatorsNetworkFee(vault, network, enable, fee);

        (bool isEnabled, uint256 returnedFee) = feeRegistry.getOperatorsNetworkFee(vault, network);
        assertFalse(isEnabled);
        assertEq(returnedFee, fee);
    }

    function test_SetOperatorsNetworkFee_RevertWhen_NotCurator() public {
        uint256 fee = 3000;
        bool enable = true;

        vm.prank(nonCurator);
        vm.expectRevert(IFeeRegistry.NotCurator.selector);
        feeRegistry.setOperatorsNetworkFee(vault, network, enable, fee);
    }

    function test_SetOperatorsNetworkFee_RevertWhen_FeeTooHigh() public {
        uint256 fee = MAX_PARTICIPANT_FEE + 1;
        bool enable = true;

        vm.prank(curator);
        vm.expectRevert(IFeeRegistry.FeeTooHigh.selector);
        feeRegistry.setOperatorsNetworkFee(vault, network, enable, fee);
    }

    function test_SetCuratorFee() public {
        uint256 fee = 4000;

        vm.expectEmit(true, true, true, true);
        emit IFeeRegistry.SetCuratorFee(vault, fee);

        vm.prank(curator);
        feeRegistry.setCuratorFee(vault, fee);

        assertEq(feeRegistry.getCuratorDefaultFee(vault), fee);
    }

    function test_SetCuratorFee_RevertWhen_NotCurator() public {
        uint256 fee = 4000;

        vm.prank(nonCurator);
        vm.expectRevert(IFeeRegistry.NotCurator.selector);
        feeRegistry.setCuratorFee(vault, fee);
    }

    function test_SetCuratorFee_RevertWhen_FeeTooHigh() public {
        uint256 fee = MAX_PARTICIPANT_FEE + 1;

        vm.prank(curator);
        vm.expectRevert(IFeeRegistry.FeeTooHigh.selector);
        feeRegistry.setCuratorFee(vault, fee);
    }

    function test_SetCuratorNetworkFee() public {
        uint256 fee = 2500;
        bool enable = true;

        vm.expectEmit(true, true, true, true);
        emit IFeeRegistry.SetCuratorNetworkFee(vault, network, enable, fee);

        vm.prank(curator);
        feeRegistry.setCuratorNetworkFee(vault, network, enable, fee);

        (bool isEnabled, uint256 returnedFee) = feeRegistry.getCuratorNetworkFee(vault, network);
        assertTrue(isEnabled);
        assertEq(returnedFee, fee);
    }

    function test_SetCuratorNetworkFee_Disabled() public {
        uint256 fee = 2500;
        bool enable = false;

        vm.prank(curator);
        feeRegistry.setCuratorNetworkFee(vault, network, enable, fee);

        (bool isEnabled, uint256 returnedFee) = feeRegistry.getCuratorNetworkFee(vault, network);
        assertFalse(isEnabled);
        assertEq(returnedFee, fee);
    }

    function test_SetCuratorNetworkFee_RevertWhen_NotCurator() public {
        uint256 fee = 2500;
        bool enable = true;

        vm.prank(nonCurator);
        vm.expectRevert(IFeeRegistry.NotCurator.selector);
        feeRegistry.setCuratorNetworkFee(vault, network, enable, fee);
    }

    function test_SetCuratorNetworkFee_RevertWhen_FeeTooHigh() public {
        uint256 fee = MAX_PARTICIPANT_FEE + 1;
        bool enable = true;

        vm.prank(curator);
        vm.expectRevert(IFeeRegistry.FeeTooHigh.selector);
        feeRegistry.setCuratorNetworkFee(vault, network, enable, fee);
    }

    function test_SetProtocolFee() public {
        bytes32 id = keccak256("protocolFee");
        uint256 fee = 1500;
        bool enable = true;

        vm.expectEmit(true, true, true, true);
        emit IFeeRegistry.SetProtocolFee(id, enable, fee);

        vm.prank(owner);
        feeRegistry.setProtocolFee(id, enable, fee);

        (bool isEnabled, uint256 returnedFee) = feeRegistry.getProtocolFee(id);
        assertTrue(isEnabled);
        assertEq(returnedFee, fee);
    }

    function test_SetProtocolFee_Disabled() public {
        bytes32 id = keccak256("protocolFee");
        uint256 fee = 1500;
        bool enable = false;

        vm.prank(owner);
        feeRegistry.setProtocolFee(id, enable, fee);

        (bool isEnabled, uint256 returnedFee) = feeRegistry.getProtocolFee(id);
        assertFalse(isEnabled);
        assertEq(returnedFee, fee);
    }

    function test_SetProtocolFee_RevertWhen_NotOwner() public {
        bytes32 id = keccak256("protocolFee");
        uint256 fee = 1500;
        bool enable = true;

        vm.prank(nonCurator);
        vm.expectRevert();
        feeRegistry.setProtocolFee(id, enable, fee);
    }

    function test_SetProtocolFee_RevertWhen_FeeTooHigh() public {
        bytes32 id = keccak256("protocolFee");
        uint256 fee = MAX_FEE + 1;
        bool enable = true;

        vm.prank(owner);
        vm.expectRevert(IFeeRegistry.FeeTooHigh.selector);
        feeRegistry.setProtocolFee(id, enable, fee);
    }

    function test_GetOperatorsFee_WithNetworkFee() public {
        uint256 defaultFee = 1000;
        uint256 networkFee = 2000;

        // Set default fee
        vm.prank(curator);
        feeRegistry.setOperatorsFee(vault, defaultFee);

        // Set network fee (enabled)
        vm.prank(curator);
        feeRegistry.setOperatorsNetworkFee(vault, network, true, networkFee);

        // Should return network fee when enabled
        assertEq(feeRegistry.getOperatorsFee(vault, network), networkFee);
    }

    function test_GetOperatorsFee_WithDisabledNetworkFee() public {
        uint256 defaultFee = 1000;
        uint256 networkFee = 2000;

        // Set default fee
        vm.prank(curator);
        feeRegistry.setOperatorsFee(vault, defaultFee);

        // Set network fee (disabled)
        vm.prank(curator);
        feeRegistry.setOperatorsNetworkFee(vault, network, false, networkFee);

        // Should return default fee when network fee is disabled
        assertEq(feeRegistry.getOperatorsFee(vault, network), defaultFee);
    }

    function test_GetOperatorsFee_NoNetworkFee() public {
        uint256 defaultFee = 1000;

        // Set default fee only
        vm.prank(curator);
        feeRegistry.setOperatorsFee(vault, defaultFee);

        // Should return default fee
        assertEq(feeRegistry.getOperatorsFee(vault, network), defaultFee);
    }

    function test_GetCuratorFee_WithNetworkFee() public {
        uint256 defaultFee = 1000;
        uint256 networkFee = 2000;

        // Set default fee
        vm.prank(curator);
        feeRegistry.setCuratorFee(vault, defaultFee);

        // Set network fee (enabled)
        vm.prank(curator);
        feeRegistry.setCuratorNetworkFee(vault, network, true, networkFee);

        // Should return network fee when enabled
        assertEq(feeRegistry.getCuratorFee(vault, network), networkFee);
    }

    function test_GetCuratorFee_WithDisabledNetworkFee() public {
        uint256 defaultFee = 1000;
        uint256 networkFee = 2000;

        // Set default fee
        vm.prank(curator);
        feeRegistry.setCuratorFee(vault, defaultFee);

        // Set network fee (disabled)
        vm.prank(curator);
        feeRegistry.setCuratorNetworkFee(vault, network, false, networkFee);

        // Should return default fee when network fee is disabled
        assertEq(feeRegistry.getCuratorFee(vault, network), defaultFee);
    }

    function test_GetCuratorFee_NoNetworkFee() public {
        uint256 defaultFee = 1000;

        // Set default fee only
        vm.prank(curator);
        feeRegistry.setCuratorFee(vault, defaultFee);

        // Should return default fee
        assertEq(feeRegistry.getCuratorFee(vault, network), defaultFee);
    }

    function test_HistoricalNetworkFeeQueries() public {
        uint256 fee1 = 1000;
        uint256 fee2 = 2000;
        bool enable1 = true;
        bool enable2 = false;

        // Set initial network fee
        vm.prank(curator);
        feeRegistry.setOperatorsNetworkFee(vault, network, enable1, fee1);

        // Advance time and set new network fee
        vm.warp(block.timestamp + 100);
        vm.prank(curator);
        feeRegistry.setOperatorsNetworkFee(vault, network, enable2, fee2);

        // Capture timestamps after all operations
        uint48 timestamp1 = uint48(block.timestamp - 100); // First checkpoint time
        uint48 timestamp2 = uint48(block.timestamp); // Second checkpoint time

        // Test historical queries
        (bool isEnabled1, uint256 returnedFee1) = feeRegistry.getOperatorsNetworkFeeAt(vault, network, timestamp1, "");
        assertTrue(isEnabled1);
        assertEq(returnedFee1, fee1);

        (bool isEnabled2, uint256 returnedFee2) = feeRegistry.getOperatorsNetworkFeeAt(vault, network, timestamp2, "");
        assertFalse(isEnabled2);
        assertEq(returnedFee2, fee2);
    }

    function test_GetOperatorsFeeAt_WithNetworkFee() public {
        uint256 defaultFee = 1000;
        uint256 networkFee = 2000;

        // Set default fee
        vm.prank(curator);
        feeRegistry.setOperatorsFee(vault, defaultFee);

        // Advance time and set network fee
        vm.warp(block.timestamp + 100);
        vm.prank(curator);
        feeRegistry.setOperatorsNetworkFee(vault, network, true, networkFee);

        // Capture timestamps after all operations
        uint48 timestamp1 = uint48(block.timestamp - 100); // Default fee checkpoint time
        uint48 timestamp2 = uint48(block.timestamp); // Network fee checkpoint time

        // Test at timestamp1 (should return default fee)
        assertEq(feeRegistry.getOperatorsFeeAt(vault, network, timestamp1, ""), defaultFee);

        // Test at timestamp2 (should return network fee)
        assertEq(feeRegistry.getOperatorsFeeAt(vault, network, timestamp2, ""), networkFee);
    }

    function test_GetCuratorFeeAt_WithNetworkFee() public {
        uint256 defaultFee = 1000;
        uint256 networkFee = 2000;

        // Set default fee
        vm.prank(curator);
        feeRegistry.setCuratorFee(vault, defaultFee);

        // Advance time and set network fee
        vm.warp(block.timestamp + 100);
        vm.prank(curator);
        feeRegistry.setCuratorNetworkFee(vault, network, true, networkFee);

        // Capture timestamps after all operations
        uint48 timestamp1 = uint48(block.timestamp - 100); // Default fee checkpoint time
        uint48 timestamp2 = uint48(block.timestamp); // Network fee checkpoint time

        // Test at timestamp1 (should return default fee)
        assertEq(feeRegistry.getCuratorFeeAt(vault, network, timestamp1, ""), defaultFee);

        // Test at timestamp2 (should return network fee)
        assertEq(feeRegistry.getCuratorFeeAt(vault, network, timestamp2, ""), networkFee);
    }
}
