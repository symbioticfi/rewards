// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";

import {CuratorRegistry} from "../../src/contracts/rewardsV2/CuratorRegistry.sol";
import {ICuratorRegistry} from "../../src/interfaces/rewardsV2/ICuratorRegistry.sol";
import {MockVault} from "../mocks/MockVault.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CuratorRegistryTest is Test {
    CuratorRegistry curatorRegistry;
    MockVault mockVault;

    address symbioticAdmin;
    address vaultOwner;
    address curator1;
    address curator2;
    address unauthorizedUser;
    address zeroAddress = address(0);

    uint256 vaultOwnerPrivateKey;
    uint256 curator1PrivateKey;
    uint256 curator2PrivateKey;
    uint256 unauthorizedUserPrivateKey;

    function setUp() public {
        (symbioticAdmin,) = makeAddrAndKey("symbioticAdmin");
        (vaultOwner, vaultOwnerPrivateKey) = makeAddrAndKey("vaultOwner");
        (curator1, curator1PrivateKey) = makeAddrAndKey("curator1");
        (curator2, curator2PrivateKey) = makeAddrAndKey("curator2");
        (unauthorizedUser, unauthorizedUserPrivateKey) = makeAddrAndKey("unauthorizedUser");

        curatorRegistry = new CuratorRegistry(symbioticAdmin);
        mockVault = new MockVault(vaultOwner);
    }

    /* CONSTRUCTOR TESTS */

    function test_Constructor() public view {
        assertEq(curatorRegistry.SYMBIOTIC_ADMIN(), symbioticAdmin);
    }

    /* SET CURATOR TESTS */

    function test_SetCuratorByVaultOwner() public {
        vm.startPrank(vaultOwner);

        curatorRegistry.setCurator(address(mockVault), vaultOwner); // vaultOwner sets themselves as curator

        address retrievedCurator = curatorRegistry.getCurator(address(mockVault));
        assertEq(retrievedCurator, vaultOwner);

        vm.stopPrank();
    }

    function test_SetCuratorBySymbioticAdmin() public {
        // Create a mock vault that returns zero address for owner
        address mockVaultWithZeroOwner = makeAddr("vaultWithZeroOwner");
        vm.mockCall(mockVaultWithZeroOwner, abi.encodeWithSelector(Ownable.owner.selector), abi.encode(zeroAddress));

        vm.startPrank(symbioticAdmin);

        curatorRegistry.setCurator(mockVaultWithZeroOwner, symbioticAdmin); // symbioticAdmin sets themselves as curator

        address retrievedCurator = curatorRegistry.getCurator(mockVaultWithZeroOwner);
        assertEq(retrievedCurator, symbioticAdmin);

        vm.stopPrank();
    }

    function test_SetCuratorByCurrentCurator() public {
        // First set curator as vault owner
        vm.startPrank(vaultOwner);
        curatorRegistry.setCurator(address(mockVault), vaultOwner);
        vm.stopPrank();

        // Current curator can only set themselves (not change to someone else)
        vm.startPrank(vaultOwner);
        curatorRegistry.setCurator(address(mockVault), vaultOwner); // Same curator

        address retrievedCurator = curatorRegistry.getCurator(address(mockVault));
        assertEq(retrievedCurator, vaultOwner);

        vm.stopPrank();
    }

    function test_SetCuratorEmitsEvent() public {
        vm.startPrank(vaultOwner);

        vm.expectEmit(true, true, true, true);
        emit ICuratorRegistry.SetCurator(address(mockVault), vaultOwner);

        curatorRegistry.setCurator(address(mockVault), vaultOwner);

        vm.stopPrank();
    }

    function test_RevertWhenNotAuthorized() public {
        vm.startPrank(unauthorizedUser);

        vm.expectRevert(ICuratorRegistry.NotAuthorized.selector);
        curatorRegistry.setCurator(address(mockVault), unauthorizedUser);

        vm.stopPrank();
    }

    function test_RevertWhenVaultOwnerIsZero() public {
        // Create a mock vault that returns zero address for owner
        address mockVaultWithZeroOwner = makeAddr("vaultWithZeroOwner");

        // Mock the owner() call to return zero address
        vm.mockCall(mockVaultWithZeroOwner, abi.encodeWithSelector(Ownable.owner.selector), abi.encode(zeroAddress));

        vm.startPrank(unauthorizedUser);

        vm.expectRevert(ICuratorRegistry.NotAuthorized.selector);
        curatorRegistry.setCurator(mockVaultWithZeroOwner, unauthorizedUser);

        vm.stopPrank();
    }

    function test_SetCuratorBySymbioticAdminWhenNoOwner() public {
        // Create a mock vault that returns zero address for owner
        address mockVaultWithZeroOwner = makeAddr("vaultWithZeroOwner");

        // Mock the owner() call to return zero address
        vm.mockCall(mockVaultWithZeroOwner, abi.encodeWithSelector(Ownable.owner.selector), abi.encode(zeroAddress));

        vm.startPrank(symbioticAdmin);

        curatorRegistry.setCurator(mockVaultWithZeroOwner, curator1);

        address retrievedCurator = curatorRegistry.getCurator(mockVaultWithZeroOwner);
        assertEq(retrievedCurator, curator1);

        vm.stopPrank();
    }

    function test_RevertWhenCurrentCuratorTriesToChangeToDifferentCurator() public {
        // First set curator as vault owner
        vm.startPrank(vaultOwner);
        curatorRegistry.setCurator(address(mockVault), vaultOwner);
        vm.stopPrank();

        // Current curator tries to change to different curator - should revert
        vm.startPrank(vaultOwner);

        vm.expectRevert(ICuratorRegistry.NotAuthorized.selector);
        curatorRegistry.setCurator(address(mockVault), curator1);

        vm.stopPrank();
    }

    function test_RevertWhenVaultOwnerTriesToSetDifferentCurator() public {
        vm.startPrank(vaultOwner);

        vm.expectRevert(ICuratorRegistry.NotAuthorized.selector);
        curatorRegistry.setCurator(address(mockVault), curator1); // vaultOwner != curator1

        vm.stopPrank();
    }

    function test_RevertWhenSymbioticAdminTriesToSetDifferentCurator() public {
        vm.startPrank(symbioticAdmin);

        vm.expectRevert(ICuratorRegistry.NotAuthorized.selector);
        curatorRegistry.setCurator(address(mockVault), curator1); // symbioticAdmin != curator1

        vm.stopPrank();
    }

    /* GET CURATOR TESTS */

    function test_GetCurator() public {
        vm.startPrank(vaultOwner);

        curatorRegistry.setCurator(address(mockVault), vaultOwner);

        address retrievedCurator = curatorRegistry.getCurator(address(mockVault));
        assertEq(retrievedCurator, vaultOwner);

        vm.stopPrank();
    }

    function test_GetCuratorReturnsZeroForUnsetVault() public view {
        address retrievedCurator = curatorRegistry.getCurator(address(mockVault));
        assertEq(retrievedCurator, zeroAddress);
    }

    function test_GetCuratorAt() public {
        vm.startPrank(vaultOwner);

        // Set initial timestamp
        uint256 timestamp1 = 1000;
        vm.warp(timestamp1);
        curatorRegistry.setCurator(address(mockVault), vaultOwner);

        // Advance time and set second curator (same curator can update themselves)
        uint256 timestamp2 = timestamp1 + 100;
        vm.warp(timestamp2);
        curatorRegistry.setCurator(address(mockVault), vaultOwner);

        // Check curator at first timestamp
        address curatorAtTime1 = curatorRegistry.getCuratorAt(address(mockVault), uint48(timestamp1), "");
        assertEq(curatorAtTime1, vaultOwner);

        // Check curator at second timestamp
        address curatorAtTime2 = curatorRegistry.getCuratorAt(address(mockVault), uint48(timestamp2), "");
        assertEq(curatorAtTime2, vaultOwner);

        // Check curator at time between checkpoints (should return first curator)
        uint256 timestampBetween = timestamp1 + 50;
        address curatorAtTimeBetween = curatorRegistry.getCuratorAt(address(mockVault), uint48(timestampBetween), "");
        assertEq(curatorAtTimeBetween, vaultOwner);

        vm.stopPrank();
    }

    function test_GetCuratorAtWithHint() public {
        vm.startPrank(vaultOwner);

        uint256 timestamp1 = 1000;
        vm.warp(timestamp1);
        curatorRegistry.setCurator(address(mockVault), vaultOwner);

        uint256 timestamp2 = timestamp1 + 100;
        vm.warp(timestamp2);
        curatorRegistry.setCurator(address(mockVault), vaultOwner);

        // Test with empty hint (should work)
        address curatorAtTime1 = curatorRegistry.getCuratorAt(address(mockVault), uint48(timestamp1), "");
        assertEq(curatorAtTime1, vaultOwner);

        vm.stopPrank();
    }
}
