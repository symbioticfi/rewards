// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@symbioticfi/core/test/integration/SymbioticCoreIntegration.sol";

import "./SymbioticRewardsInit.sol";

contract SymbioticRewardsIntegration is SymbioticRewardsInit, SymbioticCoreIntegration {
    address[] public tokens_SymbioticRewards;

    mapping(address vault => address[]) public defaultStakerRewards_SymbioticRewards;
    address[] public defaultOperatorRewards_SymbioticRewards;

    mapping(address vault => address[]) public existingDefaultStakerRewards_SymbioticRewards;
    address[] public existingDefaultOperatorRewards_SymbioticRewards;

    uint256 public SYMBIOTIC_REWARDS_DISTRIBUTE_STAKER_REWARDS_CHANCE = 4; // lower -> higher probability
    uint256 public SYMBIOTIC_REWARDS_CLAIM_STAKER_REWARDS_CHANCE = 2;

    uint256 public SYMBIOTIC_REWARDS_DISTRIBUTE_STAKER_REWARDS_MIN_AMOUNT_TIMES_1e18 = 0.1 * 1e18;
    uint256 public SYMBIOTIC_REWARDS_DISTRIBUTE_STAKER_REWARDS_MAX_AMOUNT_TIMES_1e18 = 1_000_000 * 1e18;

    function setUp() public virtual override(SymbioticRewardsInit, SymbioticCoreIntegration) {
        SymbioticCoreIntegration.setUp();
        _initRewards_SymbioticRewards(SYMBIOTIC_REWARDS_USE_EXISTING_DEPLOYMENT);

        _addPossibleTokens_SymbioticRewards();

        _loadExistingEntities_SymbioticRewards();
        if (SYMBIOTIC_REWARDS_USE_EXISTING_DEPLOYMENT) {
            _addExistingEntities_SymbioticRewards();
        }

        if (!SYMBIOTIC_REWARDS_USE_EXISTING_DEPLOYMENT) {
            _createEnvironment_SymbioticRewards();
        }
    }

    function _loadExistingEntities_SymbioticRewards() internal virtual {
        _loadExistingDefaultStakerRewards_SymbioticRewards();
        _loadExistingDefaultOperatorRewards_SymbioticRewards();
    }

    function _loadExistingDefaultStakerRewards_SymbioticRewards() internal virtual {
        if (SYMBIOTIC_REWARDS_USE_EXISTING_DEPLOYMENT) {
            uint256 numberOfDefaultStakerRewards = symbioticDefaultStakerRewardsFactory.totalEntities();
            for (uint256 i; i < numberOfDefaultStakerRewards; ++i) {
                address defaultStakerRewards = symbioticDefaultStakerRewardsFactory.entity(i);
                existingDefaultStakerRewards_SymbioticRewards[ISymbioticDefaultStakerRewards(defaultStakerRewards).VAULT(
                )].push(defaultStakerRewards);
            }
        }
    }

    function _loadExistingDefaultOperatorRewards_SymbioticRewards() internal virtual {
        if (SYMBIOTIC_REWARDS_USE_EXISTING_DEPLOYMENT) {
            uint256 numberOfDefaultOperatorRewards = symbioticDefaultOperatorRewardsFactory.totalEntities();
            for (uint256 i; i < numberOfDefaultOperatorRewards; ++i) {
                address defaultOperatorRewards = symbioticDefaultOperatorRewardsFactory.entity(i);
                existingDefaultOperatorRewards_SymbioticRewards.push(defaultOperatorRewards);
            }
        }
    }

    function _addPossibleTokens_SymbioticRewards() internal virtual {
        tokens_SymbioticRewards.push(_getToken_SymbioticCore());
        tokens_SymbioticRewards.push(_getFeeOnTransferToken_SymbioticCore());
    }

    function _addExistingEntities_SymbioticRewards() internal virtual {
        _addExistingDefaultStakerRewards_SymbioticRewards();
        _addExistingDefaultOperatorRewards_SymbioticRewards();
    }

    function _addExistingDefaultStakerRewards_SymbioticRewards() internal virtual {
        for (uint256 i; i < vaults_SymbioticCore.length; ++i) {
            for (uint256 j; j < existingDefaultStakerRewards_SymbioticRewards[vaults_SymbioticCore[i]].length; ++j) {
                if (
                    !_contains_Symbiotic(
                        defaultStakerRewards_SymbioticRewards[vaults_SymbioticCore[i]],
                        existingDefaultStakerRewards_SymbioticRewards[vaults_SymbioticCore[i]][j]
                    )
                ) {
                    defaultStakerRewards_SymbioticRewards[vaults_SymbioticCore[i]].push(
                        existingDefaultStakerRewards_SymbioticRewards[vaults_SymbioticCore[i]][j]
                    );
                }
            }
        }
    }

    function _addExistingDefaultOperatorRewards_SymbioticRewards() internal virtual {
        for (uint256 i; i < existingDefaultOperatorRewards_SymbioticRewards.length; ++i) {
            if (
                !_contains_Symbiotic(
                    defaultOperatorRewards_SymbioticRewards, existingDefaultOperatorRewards_SymbioticRewards[i]
                )
            ) {
                defaultOperatorRewards_SymbioticRewards.push(existingDefaultOperatorRewards_SymbioticRewards[i]);
            }
        }
    }

    function _createEnvironment_SymbioticRewards() internal virtual {
        _createParties_SymbioticRewards();

        _skipBlocks_Symbiotic(1);

        _distributeRewards_SymbioticRewards();
        _claimRewards_SymbioticRewards();
    }

    function _createParties_SymbioticRewards() internal virtual {
        _createDefaultStakerRewards_SymbioticRewards();
        _createDefaultOperatorRewards_SymbioticRewards();
    }

    function _createDefaultStakerRewards_SymbioticRewards() internal virtual {
        for (uint256 i; i < vaults_SymbioticCore.length; ++i) {
            defaultStakerRewards_SymbioticRewards[vaults_SymbioticCore[i]].push(
                _getDefaultStakerRewardsRandom_SymbioticRewards(vaults_SymbioticCore[i])
            );
        }
    }

    function _createDefaultOperatorRewards_SymbioticRewards() internal virtual {
        defaultOperatorRewards_SymbioticRewards.push(_getDefaultOperatorRewards_SymbioticRewards());
    }

    function _distributeRewards_SymbioticRewards() internal virtual {
        _distributeStakerRewards_SymbioticRewards();
        _distributeOperatorRewards_SymbioticRewards();
    }

    function _distributeStakerRewardsOnBehalfOfNetworkRandom_SymbioticRewards(
        address defaultStakerRewards,
        address network,
        address[] memory possibleTokens
    ) internal virtual {
        uint48 captureTimestamp = uint48(vm.getBlockTimestamp() - 1);
        address vault = ISymbioticDefaultStakerRewards(defaultStakerRewards).VAULT();
        if (ISymbioticVault(vault).activeStakeAt(captureTimestamp, new bytes(0)) == 0) {
            return;
        }
        address currentMiddleware = symbioticCore.networkMiddlewareService.middleware(network);
        address tempMiddleware = address(this);
        _networkSetMiddleware_SymbioticCore(network, tempMiddleware);
        address token = _randomPick_Symbiotic(possibleTokens);
        _fundMiddleware_SymbioticRewards(token, tempMiddleware);
        uint256 amount = _randomWithBounds_Symbiotic(
            _normalizeForToken_Symbiotic(SYMBIOTIC_REWARDS_DISTRIBUTE_STAKER_REWARDS_MIN_AMOUNT_TIMES_1e18, token),
            _normalizeForToken_Symbiotic(SYMBIOTIC_REWARDS_DISTRIBUTE_STAKER_REWARDS_MAX_AMOUNT_TIMES_1e18, token)
        );
        _distributeRewards_SymbioticRewards(
            tempMiddleware, defaultStakerRewards, network, token, amount, captureTimestamp
        );
        _networkSetMiddleware_SymbioticCore(network, currentMiddleware);
    }

    function _distributeStakerRewards_SymbioticRewards() internal virtual {
        for (uint256 i; i < vaults_SymbioticCore.length; ++i) {
            for (uint256 j; j < networks_SymbioticCore.length; ++j) {
                if (_randomChoice_Symbiotic(SYMBIOTIC_REWARDS_DISTRIBUTE_STAKER_REWARDS_CHANCE)) {
                    _distributeStakerRewardsOnBehalfOfNetworkRandom_SymbioticRewards(
                        defaultStakerRewards_SymbioticRewards[vaults_SymbioticCore[i]][0],
                        networks_SymbioticCore[j].addr,
                        tokens_SymbioticRewards
                    );
                }
            }
        }
    }

    function _distributeOperatorRewards_SymbioticRewards() internal virtual {}

    function _claimRewards_SymbioticRewards() internal virtual {
        _claimStakerRewards_SymbioticRewards();
        _claimOperatorRewards_SymbioticRewards();
    }

    function _claimStakerRewards_SymbioticRewards() internal virtual {
        for (uint256 i; i < vaults_SymbioticCore.length; ++i) {
            for (uint256 j; j < networks_SymbioticCore.length; ++j) {
                for (uint256 k; k < stakers_SymbioticCore.length; ++k) {
                    for (uint256 l; l < tokens_SymbioticRewards.length; ++l) {
                        if (_randomChoice_Symbiotic(SYMBIOTIC_REWARDS_CLAIM_STAKER_REWARDS_CHANCE)) {
                            _stakerClaimWeak_SymbioticRewards(
                                stakers_SymbioticCore[k].addr,
                                defaultStakerRewards_SymbioticRewards[vaults_SymbioticCore[i]][0],
                                tokens_SymbioticRewards[l],
                                networks_SymbioticCore[j].addr
                            );
                        }
                    }
                }
            }
        }
    }

    function _claimOperatorRewards_SymbioticRewards() internal virtual {}
}
