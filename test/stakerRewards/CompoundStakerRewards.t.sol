// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";

import "forge-std/StdUtils.sol";

import {IVaultTokenized} from "@symbioticfi/core/src/interfaces/vault/IVaultTokenized.sol";

import {SymbioticRewardsIntegration} from "test/integration/SymbioticRewardsIntegration.sol";
import {IStakerRewards} from "src/interfaces/stakerRewards/IStakerRewards.sol";
import {CompoundingStakingRewards} from "src/contracts/CompoundingStakerRewards.sol";

contract CompoundStakerRewardsTest is SymbioticRewardsIntegration {
    CompoundingStakingRewards compoundingStakingRewards;
    IStakerRewards stakerRewards;
    IVaultTokenized vault;

    string name = "Compounding Staking Rewards";
    string symbol = "CSR";

    function setUp() public override {
        super.setUp();
        vault = IVaultTokenized(vaults_SymbioticCore[0]);
        stakerRewards = IStakerRewards(
            defaultStakerRewards_SymbioticRewards[address(vault)][0]
        );
        compoundingStakingRewards = new CompoundingStakingRewards(
            vault,
            stakerRewards,
            name,
            symbol
        );
    }

    function test_constructor() public {
        assertEq(address(compoundingStakingRewards.vault()), address(vault));
        assertEq(
            address(compoundingStakingRewards.rewards()),
            address(stakerRewards)
        );
        assertEq(compoundingStakingRewards.name(), name);
        assertEq(compoundingStakingRewards.symbol(), symbol);
        assertEq(
            address(compoundingStakingRewards.token()),
            vault.collateral()
        );
    }

    function test_compound_revertsWhenNoRewards() public {
        vm.expectRevert();
        compoundingStakingRewards.compound();
    }

    function test_compound() public {
        uint256 amount = 1;

        // give address(this) amount of tokenized vault
        deal(address(vault), address(this), amount);

        compoundingStakingRewards.deposit(amount, address(this));

        _distributeStakerRewards_SymbioticRewards();
        compoundingStakingRewards.compound();
    }
}
