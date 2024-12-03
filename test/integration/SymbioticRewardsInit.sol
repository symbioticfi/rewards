// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@symbioticfi/core/test/integration/SymbioticCoreInit.sol";

import "./SymbioticRewardsImports.sol";

import {SymbioticRewardsConstants} from "./SymbioticRewardsConstants.sol";
import {SymbioticRewardsBindings} from "./SymbioticRewardsBindings.sol";

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract SymbioticRewardsInit is SymbioticCoreInit, SymbioticRewardsBindings {
    using SafeERC20 for IERC20;
    using Math for uint256;

    // General config

    string public SYMBIOTIC_REWARDS_PROJECT_ROOT = "";
    bool public SYMBIOTIC_REWARDS_USE_EXISTING_DEPLOYMENT = false;

    // Middleware-related config

    uint256 public SYMBIOTIC_REWARDS_TOKENS_TO_SET_TIMES_1e18 = 100_000_000 * 1e18;

    // DefaultStakerRewards-related config

    uint256 public SYMBIOTIC_REWARDS_MIN_ADMIN_FEE = 0;
    uint256 public SYMBIOTIC_REWARDS_MAX_ADMIN_FEE = 5000;

    ISymbioticDefaultStakerRewardsFactory public symbioticDefaultStakerRewardsFactory;
    ISymbioticDefaultOperatorRewardsFactory public symbioticDefaultOperatorRewardsFactory;

    function setUp() public virtual override {
        super.setUp();

        _initRewards_SymbioticRewards(SYMBIOTIC_REWARDS_USE_EXISTING_DEPLOYMENT);
    }

    // ------------------------------------------------------------ GENERAL HELPERS ------------------------------------------------------------ //

    function _initRewards_SymbioticRewards() internal virtual {
        symbioticDefaultStakerRewardsFactory = SymbioticRewardsConstants.defaultStakerRewardsFactory();
        symbioticDefaultOperatorRewardsFactory = SymbioticRewardsConstants.defaultOperatorRewardsFactory();
    }

    function _initRewards_SymbioticRewards(
        bool useExisting
    ) internal virtual {
        if (useExisting) {
            _initRewards_SymbioticRewards();
        } else {
            address defaultStakerRewardsImplementation = deployCode(
                string.concat(SYMBIOTIC_REWARDS_PROJECT_ROOT, "out/DefaultStakerRewards.sol/DefaultStakerRewards.json"),
                abi.encode(address(symbioticCore.vaultFactory), address(symbioticCore.networkMiddlewareService))
            );
            symbioticDefaultStakerRewardsFactory = ISymbioticDefaultStakerRewardsFactory(
                deployCode(
                    string.concat(
                        SYMBIOTIC_REWARDS_PROJECT_ROOT,
                        "out/DefaultStakerRewardsFactory.sol/DefaultStakerRewardsFactory.json"
                    ),
                    abi.encode(defaultStakerRewardsImplementation)
                )
            );
            address defaultOperatorRewardsImplementation = deployCode(
                string.concat(
                    SYMBIOTIC_REWARDS_PROJECT_ROOT, "out/DefaultOperatorRewards.sol/DefaultOperatorRewards.json"
                ),
                abi.encode(address(symbioticCore.networkMiddlewareService))
            );
            symbioticDefaultOperatorRewardsFactory = ISymbioticDefaultOperatorRewardsFactory(
                deployCode(
                    string.concat(
                        SYMBIOTIC_REWARDS_PROJECT_ROOT,
                        "out/DefaultOperatorRewardsFactory.sol/DefaultOperatorRewardsFactory.json"
                    ),
                    abi.encode(defaultOperatorRewardsImplementation)
                )
            );
        }
    }

    // ------------------------------------------------------------ REWARDS-RELATED HELPERS ------------------------------------------------------------ //

    function _getDefaultStakerRewards_SymbioticRewards(
        address vault
    ) internal virtual returns (address) {
        return _createDefaultStakerRewards_SymbioticRewards({
            symbioticDefaultStakerRewardsFactory: symbioticDefaultStakerRewardsFactory,
            who: address(this),
            vault: vault,
            adminFee: 1000,
            defaultAdminRoleHolder: address(this),
            adminFeeClaimRoleHolder: address(this),
            adminFeeSetRoleHolder: address(this)
        });
    }

    function _getDefaultStakerRewards_SymbioticRewards(
        address vault,
        uint256 adminFee,
        address admin
    ) internal virtual returns (address) {
        return _createDefaultStakerRewards_SymbioticRewards({
            symbioticDefaultStakerRewardsFactory: symbioticDefaultStakerRewardsFactory,
            who: address(this),
            vault: vault,
            adminFee: adminFee,
            defaultAdminRoleHolder: admin,
            adminFeeClaimRoleHolder: admin,
            adminFeeSetRoleHolder: admin
        });
    }

    function _getDefaultStakerRewardsRandom_SymbioticRewards(
        address vault
    ) internal virtual returns (address) {
        return _getDefaultStakerRewards_SymbioticRewards(
            vault,
            _randomWithBounds_Symbiotic(SYMBIOTIC_REWARDS_MIN_ADMIN_FEE, SYMBIOTIC_REWARDS_MAX_ADMIN_FEE),
            address(this)
        );
    }

    function _getDefaultOperatorRewards_SymbioticRewards() internal virtual returns (address) {
        return _createDefaultOperatorRewards_SymbioticRewards({
            symbioticDefaultOperatorRewardsFactory: symbioticDefaultOperatorRewardsFactory,
            who: address(this)
        });
    }

    function _getDefaultOperatorRewardsRandom_SymbioticRewards() internal virtual returns (address) {
        return _getDefaultOperatorRewards_SymbioticRewards();
    }

    function _fundMiddleware_SymbioticRewards(address token, address middleware) internal virtual {
        deal(token, middleware, _normalizeForToken_Symbiotic(SYMBIOTIC_REWARDS_TOKENS_TO_SET_TIMES_1e18, token), true); // should cover most cases
    }

    // ------------------------------------------------------------ STAKER-RELATED HELPERS ------------------------------------------------------------ //

    function _stakerClaim_SymbioticRewards(
        address staker,
        address defaultStakerRewards,
        address token,
        address network
    ) internal virtual {
        _claimRewards_SymbioticRewards(staker, defaultStakerRewards, token, network);
    }

    function _stakerClaimWeak_SymbioticRewards(
        address staker,
        address defaultStakerRewards,
        address token,
        address network
    ) internal virtual returns (bool) {
        if (
            ISymbioticDefaultStakerRewards(defaultStakerRewards).claimable(token, staker, abi.encode(network, 1000)) > 0
        ) {
            _stakerClaim_SymbioticRewards(staker, defaultStakerRewards, token, network);
            return true;
        }
        return false;
    }

    // ------------------------------------------------------------ OPERATOR-RELATED HELPERS ------------------------------------------------------------ //

    function _operatorClaim_SymbioticRewards(
        address operator,
        address defaultOperatorRewards,
        address network,
        address token,
        uint256 totalClaimable,
        bytes32[] memory proof
    ) internal virtual {
        _claimRewards_SymbioticRewards(operator, defaultOperatorRewards, network, token, totalClaimable, proof);
    }

    // ------------------------------------------------------------ CURATOR-RELATED HELPERS ------------------------------------------------------------ //

    function _curatorClaim_SymbioticRewards(
        address curator,
        address defaultStakerRewards,
        address token
    ) public virtual {
        _claimAdminFee_SymbioticRewards(curator, defaultStakerRewards, token);
    }

    function _curatorClaimWeak_SymbioticRewards(
        address curator,
        address defaultStakerRewards,
        address token
    ) internal virtual returns (bool) {
        try this._curatorClaim_SymbioticRewards(curator, defaultStakerRewards, token) {
            return true;
        } catch {
            return false;
        }
    }

    function _curatorSetAdminFee_SymbioticRewards(
        address curator,
        address defaultStakerRewards,
        uint256 adminFee
    ) internal virtual {
        _setAdminFee_SymbioticRewards(curator, defaultStakerRewards, adminFee);
    }
}
