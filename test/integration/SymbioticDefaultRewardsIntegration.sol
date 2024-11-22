// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@symbioticfi/core/test/integration/SymbioticCoreIntegration.sol";

import "./SymbioticDefaultRewardsInit.sol";
import {console2} from "forge-std/Test.sol";

contract SymbioticDefaultRewardsIntegration is SymbioticDefaultRewardsInit, SymbioticCoreIntegration {
    address[] public tokens_SymbioticDefaultRewards;

    mapping(address vault => address[]) public defaultStakerRewards_SymbioticDefaultRewards;
    address[] public defaultOperatorRewards_SymbioticDefaultRewards;

    mapping(address vault => address[]) public existingDefaultStakerRewards_SymbioticDefaultRewards;
    address[] public existingDefaultOperatorRewards_SymbioticDefaultRewards;

    uint256 public SYMBIOTIC_DEFAULT_REWARDS_DISTRIBUTE_STAKER_REWARDS_CHANCE = 4; // lower -> higher probability
    uint256 public SYMBIOTIC_DEFAULT_REWARDS_CLAIM_STAKER_REWARDS_CHANCE = 2;

    uint256 public SYMBIOTIC_DEFAULT_REWARDS_DISTRIBUTE_STAKER_REWARDS_MIN_AMOUNT_TIMES_1e18 = 0.1 * 1e18;
    uint256 public SYMBIOTIC_DEFAULT_REWARDS_DISTRIBUTE_STAKER_REWARDS_MAX_AMOUNT_TIMES_1e18 = 1_000_000 * 1e18;

    function setUp() public virtual override(SymbioticDefaultRewardsInit, SymbioticCoreIntegration) {
        SymbioticCoreIntegration.setUp();
        _initDefaultRewards_SymbioticDefaultRewards(SYMBIOTIC_DEFAULT_REWARDS_USE_EXISTING_DEPLOYMENT);

        _addPossibleTokens_SymbioticDefaultRewards();

        _loadExistingEntities_SymbioticDefaultRewards();
        if (SYMBIOTIC_DEFAULT_REWARDS_USE_EXISTING_DEPLOYMENT) {
            _addExistingEntities_SymbioticDefaultRewards();
        }

        if (!SYMBIOTIC_DEFAULT_REWARDS_USE_EXISTING_DEPLOYMENT) {
            _createEnvironment_SymbioticDefaultRewards();
        }
    }

    function _loadExistingEntities_SymbioticDefaultRewards() internal virtual {
        _loadExistingDefaultStakerRewards_SymbioticDefaultRewards();
        _loadExistingDefaultOperatorRewards_SymbioticDefaultRewards();
    }

    function _loadExistingDefaultStakerRewards_SymbioticDefaultRewards() internal virtual {
        if (SYMBIOTIC_DEFAULT_REWARDS_USE_EXISTING_DEPLOYMENT) {
            uint256 numberOfDefaultStakerRewards = symbioticDefaultStakerRewardsFactory.totalEntities();
            for (uint256 i; i < numberOfDefaultStakerRewards; ++i) {
                address defaultStakerRewards = symbioticDefaultStakerRewardsFactory.entity(i);
                existingDefaultStakerRewards_SymbioticDefaultRewards[ISymbioticDefaultStakerRewards(
                    defaultStakerRewards
                ).VAULT()].push(defaultStakerRewards);
            }
        }
    }

    function _loadExistingDefaultOperatorRewards_SymbioticDefaultRewards() internal virtual {
        if (SYMBIOTIC_DEFAULT_REWARDS_USE_EXISTING_DEPLOYMENT) {
            uint256 numberOfDefaultOperatorRewards = symbioticDefaultOperatorRewardsFactory.totalEntities();
            for (uint256 i; i < numberOfDefaultOperatorRewards; ++i) {
                address defaultOperatorRewards = symbioticDefaultOperatorRewardsFactory.entity(i);
                existingDefaultOperatorRewards_SymbioticDefaultRewards.push(defaultOperatorRewards);
            }
        }
    }

    function _addPossibleTokens_SymbioticDefaultRewards() internal virtual {
        tokens_SymbioticDefaultRewards.push(_getToken_SymbioticCore());
        tokens_SymbioticDefaultRewards.push(_getFeeOnTransferToken_SymbioticCore());
    }

    function _addExistingEntities_SymbioticDefaultRewards() internal virtual {
        _addExistingDefaultStakerRewards_SymbioticDefaultRewards();
        _addExistingDefaultOperatorRewards_SymbioticDefaultRewards();
    }

    function _addExistingDefaultStakerRewards_SymbioticDefaultRewards() internal virtual {
        for (uint256 i; i < vaults_SymbioticCore.length; ++i) {
            for (
                uint256 j; j < existingDefaultStakerRewards_SymbioticDefaultRewards[vaults_SymbioticCore[i]].length; ++j
            ) {
                if (
                    !_contains_Symbiotic(
                        defaultStakerRewards_SymbioticDefaultRewards[vaults_SymbioticCore[i]],
                        existingDefaultStakerRewards_SymbioticDefaultRewards[vaults_SymbioticCore[i]][i]
                    )
                ) {
                    defaultStakerRewards_SymbioticDefaultRewards[vaults_SymbioticCore[i]].push(
                        existingDefaultStakerRewards_SymbioticDefaultRewards[vaults_SymbioticCore[i]][i]
                    );
                }
            }
        }
    }

    function _addExistingDefaultOperatorRewards_SymbioticDefaultRewards() internal virtual {
        for (uint256 i; i < existingDefaultOperatorRewards_SymbioticDefaultRewards.length; ++i) {
            if (
                !_contains_Symbiotic(
                    defaultOperatorRewards_SymbioticDefaultRewards,
                    existingDefaultOperatorRewards_SymbioticDefaultRewards[i]
                )
            ) {
                defaultOperatorRewards_SymbioticDefaultRewards.push(
                    existingDefaultOperatorRewards_SymbioticDefaultRewards[i]
                );
            }
        }
    }

    function _createEnvironment_SymbioticDefaultRewards() internal virtual {
        _createParties_SymbioticDefaultRewards();

        _skipBlocks_Symbiotic(1);

        _distributeRewards_SymbioticDefaultRewards();
        _claimRewards_SymbioticDefaultRewards();
    }

    function _createParties_SymbioticDefaultRewards() internal virtual {
        _createDefaultStakerRewards_SymbioticDefaultRewards();
        _createDefaultOperatorRewards_SymbioticDefaultRewards();
    }

    function _createDefaultStakerRewards_SymbioticDefaultRewards() internal virtual {
        for (uint256 i; i < vaults_SymbioticCore.length; ++i) {
            defaultStakerRewards_SymbioticDefaultRewards[vaults_SymbioticCore[i]].push(
                _getDefaultStakerRewardsRandom_SymbioticDefaultRewards(vaults_SymbioticCore[i])
            );
        }
    }

    function _createDefaultOperatorRewards_SymbioticDefaultRewards() internal virtual {
        defaultOperatorRewards_SymbioticDefaultRewards.push(_getDefaultOperatorRewards_SymbioticDefaultRewards());
    }

    function _distributeRewards_SymbioticDefaultRewards() internal virtual {
        _distributeStakerRewards_SymbioticDefaultRewards();
        _distributeOperatorRewards_SymbioticDefaultRewards();
    }

    function _distributeStakerRewardsOnBehalfOfNetworkRandom_SymbioticDefaultRewards(
        address defaultStakerRewards,
        address network,
        address[] memory possibleTokens
    ) internal virtual {
        address currentMiddleware = symbioticCore.networkMiddlewareService.middleware(network);
        address tempMiddleware = address(this);
        _networkSetMiddleware_SymbioticCore(network, tempMiddleware);
        address token = _randomPick_Symbiotic(possibleTokens);
        _fundMiddleware_SymbioticDefaultRewards(token, tempMiddleware);
        uint256 amount = _randomWithBounds_Symbiotic(
            _normalizeForToken_Symbiotic(
                SYMBIOTIC_DEFAULT_REWARDS_DISTRIBUTE_STAKER_REWARDS_MIN_AMOUNT_TIMES_1e18, token
            ),
            _normalizeForToken_Symbiotic(
                SYMBIOTIC_DEFAULT_REWARDS_DISTRIBUTE_STAKER_REWARDS_MAX_AMOUNT_TIMES_1e18, token
            )
        );
        _distributeRewards_SymbioticDefaultRewards(
            tempMiddleware, defaultStakerRewards, network, token, amount, uint48(vm.getBlockTimestamp() - 1)
        );
        _networkSetMiddleware_SymbioticCore(network, currentMiddleware);
    }

    function _distributeStakerRewards_SymbioticDefaultRewards() internal virtual {
        for (uint256 i; i < vaults_SymbioticCore.length; ++i) {
            for (uint256 j; j < networks_SymbioticCore.length; ++j) {
                if (_randomChoice_Symbiotic(SYMBIOTIC_DEFAULT_REWARDS_DISTRIBUTE_STAKER_REWARDS_CHANCE)) {
                    _distributeStakerRewardsOnBehalfOfNetworkRandom_SymbioticDefaultRewards(
                        defaultStakerRewards_SymbioticDefaultRewards[vaults_SymbioticCore[i]][0],
                        networks_SymbioticCore[j].addr,
                        tokens_SymbioticDefaultRewards
                    );
                }
            }
        }
    }

    function _distributeOperatorRewards_SymbioticDefaultRewards() internal virtual {}

    function _claimRewards_SymbioticDefaultRewards() internal virtual {
        _claimStakerRewards_SymbioticDefaultRewards();
        _claimOperatorRewards_SymbioticDefaultRewards();
    }

    function _claimStakerRewards_SymbioticDefaultRewards() internal virtual {
        for (uint256 i; i < vaults_SymbioticCore.length; ++i) {
            for (uint256 j; j < networks_SymbioticCore.length; ++j) {
                for (uint256 k; k < stakers_SymbioticCore.length; ++k) {
                    for (uint256 l; l < tokens_SymbioticDefaultRewards.length; ++l) {
                        if (_randomChoice_Symbiotic(SYMBIOTIC_DEFAULT_REWARDS_CLAIM_STAKER_REWARDS_CHANCE)) {
                            _stakerClaimWeak_SymbioticDefaultRewards(
                                stakers_SymbioticCore[k].addr,
                                defaultStakerRewards_SymbioticDefaultRewards[vaults_SymbioticCore[i]][0],
                                tokens_SymbioticDefaultRewards[l],
                                networks_SymbioticCore[j].addr
                            );
                        }
                    }
                }
            }
        }
    }

    function _claimOperatorRewards_SymbioticDefaultRewards() internal virtual {}
}
