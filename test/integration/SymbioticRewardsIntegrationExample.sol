// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SymbioticRewardsIntegration.sol";

import {console2} from "forge-std/Test.sol";

contract SymbioticRewardsIntegrationExample is SymbioticRewardsIntegration {
    using SymbioticSubnetwork for bytes32;
    using SymbioticSubnetwork for address;

    address[] public networkVaults;

    address[] public confirmedNetworkVaults;
    mapping(address vault => address[]) public confirmedNetworkOperators;
    mapping(address vault => bytes32[]) public neighborNetworks;

    uint256 public SELECT_OPERATOR_CHANCE = 1; // lower -> higher probability

    function setUp() public override {
        SYMBIOTIC_CORE_PROJECT_ROOT = "lib/core/";
        SYMBIOTIC_REWARDS_PROJECT_ROOT = "";
        // vm.selectFork(vm.createFork(vm.rpcUrl("holesky")));
        // SYMBIOTIC_INIT_BLOCK = 2_727_202;
        // SYMBIOTIC_CORE_USE_EXISTING_DEPLOYMENT = true;
        // SYMBIOTIC_REWARDS_USE_EXISTING_DEPLOYMENT = true;

        SYMBIOTIC_CORE_NUMBER_OF_STAKERS = 10;

        super.setUp();
    }

    function test_NetworkDistributeRewardsForStake() public {
        address middleware = address(111);
        Vm.Wallet memory network = _getNetworkWithMiddleware_SymbioticCore(middleware);
        uint96 identifier = 0;
        address collateral = tokens_SymbioticCore[0];
        bytes32 subnetwork = network.addr.subnetwork(identifier);
        address rewardsToken = tokens_SymbioticCore[0];

        console2.log("Network:", network.addr);
        console2.log("Identifier:", identifier);
        console2.log("Collateral:", collateral);
        console2.log("Rewards Token:", rewardsToken);

        for (uint256 i; i < vaults_SymbioticCore.length; ++i) {
            if (ISymbioticVault(vaults_SymbioticCore[i]).collateral() == collateral) {
                networkVaults.push(vaults_SymbioticCore[i]);
            }
        }

        console2.log("Network Vaults:", networkVaults.length);

        for (uint256 i; i < networkVaults.length; ++i) {
            _networkSetMaxNetworkLimitRandom_SymbioticCore(network.addr, networkVaults[i], identifier);
            if (_delegateToNetworkTry_SymbioticCore(networkVaults[i], subnetwork)) {
                confirmedNetworkVaults.push(networkVaults[i]);
            }
        }

        console2.log("Confirmed Network Vaults:", confirmedNetworkVaults.length);
        console2.log("Operators:", operators_SymbioticCore.length);

        for (uint256 i; i < confirmedNetworkVaults.length; ++i) {
            for (uint256 j; j < operators_SymbioticCore.length; ++j) {
                if (
                    ISymbioticOptInService(symbioticCore.operatorVaultOptInService).isOptedIn(
                        operators_SymbioticCore[j].addr, confirmedNetworkVaults[i]
                    ) && _randomChoice_Symbiotic(SELECT_OPERATOR_CHANCE)
                ) {
                    _operatorOptInWeak_SymbioticCore(operators_SymbioticCore[j].addr, network.addr);
                    if (
                        _delegateToOperatorTry_SymbioticCore(
                            confirmedNetworkVaults[i], subnetwork, operators_SymbioticCore[j].addr
                        )
                    ) {
                        confirmedNetworkOperators[confirmedNetworkVaults[i]].push(operators_SymbioticCore[j].addr);
                    }
                }
            }

            console2.log("Confirmed Network Operators:", confirmedNetworkOperators[confirmedNetworkVaults[i]].length);
        }

        for (uint256 i; i < confirmedNetworkVaults.length; ++i) {
            console2.log("Confirmed Network Vault:", confirmedNetworkVaults[i]);
            console2.log("Confirmed Network Operators:", confirmedNetworkOperators[confirmedNetworkVaults[i]].length);
            for (uint256 j; j < confirmedNetworkOperators[confirmedNetworkVaults[i]].length; ++j) {
                console2.log("Operator:", confirmedNetworkOperators[confirmedNetworkVaults[i]][j]);
                console2.log(
                    "Stake:",
                    ISymbioticBaseDelegator(ISymbioticVault(confirmedNetworkVaults[i]).delegator()).stake(
                        subnetwork, confirmedNetworkOperators[confirmedNetworkVaults[i]][j]
                    )
                );
            }
        }

        _skipBlocks_Symbiotic(1);

        uint48 captureTimestamp = uint48(vm.getBlockTimestamp() - 1);
        _fundMiddleware_SymbioticRewards(rewardsToken, middleware);
        for (uint256 i; i < confirmedNetworkVaults.length; ++i) {
            uint256 delegatedAmount;
            for (uint256 j; j < confirmedNetworkOperators[confirmedNetworkVaults[i]].length; ++j) {
                delegatedAmount += ISymbioticBaseDelegator(ISymbioticVault(confirmedNetworkVaults[i]).delegator())
                    .stakeAt(
                    subnetwork, confirmedNetworkOperators[confirmedNetworkVaults[i]][j], captureTimestamp, new bytes(0)
                );
            }
            if (delegatedAmount == 0) {
                continue;
            }

            if (defaultStakerRewards_SymbioticRewards[confirmedNetworkVaults[i]].length == 0) {
                continue;
            }

            _distributeRewards_SymbioticRewards(
                middleware,
                defaultStakerRewards_SymbioticRewards[confirmedNetworkVaults[i]][0],
                network.addr,
                rewardsToken,
                delegatedAmount,
                captureTimestamp
            );
        }

        for (uint256 i; i < stakers_SymbioticCore.length; ++i) {
            if (defaultStakerRewards_SymbioticRewards[confirmedNetworkVaults[0]].length == 0) {
                continue;
            }
            uint256 claimable = ISymbioticDefaultStakerRewards(
                defaultStakerRewards_SymbioticRewards[confirmedNetworkVaults[0]][0]
            ).claimable(rewardsToken, stakers_SymbioticCore[i].addr, abi.encode(network.addr, 1000));
            _stakerClaimWeak_SymbioticRewards(
                stakers_SymbioticCore[i].addr,
                defaultStakerRewards_SymbioticRewards[confirmedNetworkVaults[0]][0],
                rewardsToken,
                network.addr
            );
            console2.log("Staker ", stakers_SymbioticCore[i].addr, " claimed ", claimable);
        }

        if (defaultStakerRewards_SymbioticRewards[confirmedNetworkVaults[0]].length > 0) {
            uint256 claimableAdminFee = ISymbioticDefaultStakerRewards(
                defaultStakerRewards_SymbioticRewards[confirmedNetworkVaults[0]][0]
            ).claimableAdminFee(rewardsToken);
            _curatorClaimWeak_SymbioticRewards(
                address(this), defaultStakerRewards_SymbioticRewards[confirmedNetworkVaults[0]][0], rewardsToken
            );
            console2.log("Admin claimed ", claimableAdminFee);
        }
    }
}
