// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "../integration/SymbioticRewardsIntegration.sol";

import {CompoundStakerRewards} from "../../src/contracts/CompoundStakerRewards.sol";

contract CompoundStakerRewardsTest is SymbioticRewardsIntegration {
    CompoundStakerRewards compoundStakerRewards;
    ISymbioticStakerRewards stakerRewards;
    ISymbioticVaultTokenized vault;

    string name = "Compounding Staking Rewards";
    string symbol = "CSR";

    function setUp() public override {
        SYMBIOTIC_CORE_PROJECT_ROOT = "lib/core/";
        SYMBIOTIC_REWARDS_PROJECT_ROOT = "";

        SYMBIOTIC_CORE_NUMBER_OF_VAULTS = 0;
        SYMBIOTIC_CORE_NUMBER_OF_NETWORKS = 1;
        SYMBIOTIC_CORE_NUMBER_OF_OPERATORS = 0;
        SYMBIOTIC_CORE_NUMBER_OF_STAKERS = 0;

        super.setUp();

        vault = ISymbioticVaultTokenized(
            _getVault_SymbioticCore(tokens_SymbioticRewards[0])
        );
        stakerRewards = ISymbioticStakerRewards(
            _getDefaultStakerRewards_SymbioticRewards(address(vault))
        );
        compoundStakerRewards = new CompoundStakerRewards(
            vault,
            stakerRewards,
            name,
            symbol
        );
    }

    function test_constructor() public {
        assertEq(address(compoundStakerRewards.vault()), address(vault));
        assertEq(
            address(compoundStakerRewards.rewards()),
            address(stakerRewards)
        );
        assertEq(compoundStakerRewards.name(), name);
        assertEq(compoundStakerRewards.symbol(), symbol);
        assertEq(address(compoundStakerRewards.token()), vault.collateral());
    }

    function test_compound_revertsWhenNoRewards() public {
        vm.expectRevert(
            ISymbioticDefaultStakerRewards.NoRewardsToClaim.selector
        );
        compoundStakerRewards.compound(networks_SymbioticCore[0].addr);
    }

    function test_compound() public {
        uint256 amount = 1;

        // give address(this) amount of tokenized vault
        _deal_Symbiotic(
            address(compoundStakerRewards.token()),
            address(this),
            amount,
            true
        );
        _deposit_SymbioticCore(
            address(this),
            address(vault),
            address(this),
            amount
        );
        IERC20(address(vault)).approve(address(compoundStakerRewards), amount);
        compoundStakerRewards.deposit(amount, address(this));

        _skipBlocks_Symbiotic(1);

        address network = networks_SymbioticCore[0].addr;

        _distributeStakerRewardsOnBehalfOfNetworkRandom_SymbioticRewards(
            address(stakerRewards),
            network,
            address(compoundStakerRewards.token())
        );
        compoundStakerRewards.compound(network);
    }

    function _getVault_SymbioticCore(
        address collateral
    ) internal override returns (address) {
        address owner = address(this);
        uint48 epochDuration = 7 days;
        uint48 vetoDuration = 1 days;
        address[] memory networkLimitSetRoleHolders = new address[](1);
        networkLimitSetRoleHolders[0] = owner;
        address[] memory operatorNetworkSharesSetRoleHolders = new address[](1);
        operatorNetworkSharesSetRoleHolders[0] = owner;
        (address vault_, , ) = _createVault_SymbioticCore({
            symbioticCore: symbioticCore,
            who: address(this),
            version: 2,
            owner: owner,
            vaultParams: abi.encode(
                ISymbioticVaultTokenized.InitParamsTokenized({
                    baseParams: ISymbioticVault.InitParams({
                        collateral: collateral,
                        burner: 0x000000000000000000000000000000000000dEaD,
                        epochDuration: epochDuration,
                        depositWhitelist: false,
                        isDepositLimit: false,
                        depositLimit: 0,
                        defaultAdminRoleHolder: owner,
                        depositWhitelistSetRoleHolder: owner,
                        depositorWhitelistRoleHolder: owner,
                        isDepositLimitSetRoleHolder: owner,
                        depositLimitSetRoleHolder: owner
                    }),
                    name: "Test",
                    symbol: "TEST"
                })
            ),
            delegatorIndex: 0,
            delegatorParams: abi.encode(
                ISymbioticNetworkRestakeDelegator.InitParams({
                    baseParams: ISymbioticBaseDelegator.BaseParams({
                        defaultAdminRoleHolder: owner,
                        hook: 0x0000000000000000000000000000000000000000,
                        hookSetRoleHolder: owner
                    }),
                    networkLimitSetRoleHolders: networkLimitSetRoleHolders,
                    operatorNetworkSharesSetRoleHolders: operatorNetworkSharesSetRoleHolders
                })
            ),
            withSlasher: true,
            slasherIndex: 1,
            slasherParams: abi.encode(
                ISymbioticVetoSlasher.InitParams({
                    baseParams: ISymbioticBaseSlasher.BaseParams({
                        isBurnerHook: true
                    }),
                    vetoDuration: vetoDuration,
                    resolverSetEpochsDelay: 3
                })
            )
        });

        return vault_;
    }

    function _distributeStakerRewardsOnBehalfOfNetworkRandom_SymbioticRewards(
        address defaultStakerRewards,
        address network,
        address token
    ) internal {
        uint48 captureTimestamp = uint48(vm.getBlockTimestamp() - 1);
        address vault_ = ISymbioticDefaultStakerRewards(defaultStakerRewards)
            .VAULT();
        if (
            ISymbioticVault(vault_).activeStakeAt(
                captureTimestamp,
                new bytes(0)
            ) == 0
        ) {
            return;
        }
        address currentMiddleware = symbioticCore
            .networkMiddlewareService
            .middleware(network);
        address tempMiddleware = address(this);
        _networkSetMiddleware_SymbioticCore(network, tempMiddleware);
        _fundMiddleware_SymbioticRewards(token, tempMiddleware);
        uint256 amount = _randomWithBounds_Symbiotic(
            _normalizeForToken_Symbiotic(
                SYMBIOTIC_REWARDS_DISTRIBUTE_STAKER_REWARDS_MIN_AMOUNT_TIMES_1e18,
                token
            ),
            _normalizeForToken_Symbiotic(
                SYMBIOTIC_REWARDS_DISTRIBUTE_STAKER_REWARDS_MAX_AMOUNT_TIMES_1e18,
                token
            )
        );
        _distributeRewards_SymbioticRewards(
            tempMiddleware,
            defaultStakerRewards,
            network,
            token,
            amount,
            captureTimestamp
        );
        _networkSetMiddleware_SymbioticCore(network, currentMiddleware);
    }
}
