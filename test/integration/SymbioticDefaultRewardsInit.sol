// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@symbioticfi/core/test/integration/SymbioticCoreInit.sol";

import "./SymbioticDefaultRewardsImports.sol";

import {SymbioticDefaultRewardsConstants} from "./SymbioticDefaultRewardsConstants.sol";
import {SymbioticDefaultRewardsBindings} from "./SymbioticDefaultRewardsBindings.sol";

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract SymbioticDefaultRewardsInit is SymbioticCoreInit, SymbioticDefaultRewardsBindings {
    using SafeERC20 for IERC20;
    using Math for uint256;

    // General config

    string public SYMBIOTIC_DEFAULT_REWARDS_PROJECT_ROOT = "";
    bool public SYMBIOTIC_DEFAULT_REWARDS_USE_EXISTING_DEPLOYMENT = false;

    // Middleware-related config

    uint256 public SYMBIOTIC_DEFAULT_REWARDS_TOKENS_TO_SET_TIMES_1e18 = 100_000_000 * 1e18;

    // DefaultStakerRewards-related config

    uint256 public SYMBIOTIC_DEFAULT_REWARDS_MIN_ADMIN_FEE = 0;
    uint256 public SYMBIOTIC_DEFAULT_REWARDS_MAX_ADMIN_FEE = 5000;

    ISymbioticDefaultStakerRewardsFactory symbioticDefaultStakerRewardsFactory;
    ISymbioticDefaultOperatorRewardsFactory symbioticDefaultOperatorRewardsFactory;

    function setUp() public virtual override {
        super.setUp();

        _initDefaultRewards_SymbioticDefaultRewards(SYMBIOTIC_DEFAULT_REWARDS_USE_EXISTING_DEPLOYMENT);
    }

    // ------------------------------------------------------------ GENERAL HELPERS ------------------------------------------------------------ //

    function _initDefaultRewards_SymbioticDefaultRewards() internal virtual {
        symbioticDefaultStakerRewardsFactory = SymbioticDefaultRewardsConstants.defaultStakerRewardsFactory();
        symbioticDefaultOperatorRewardsFactory = SymbioticDefaultRewardsConstants.defaultOperatorRewardsFactory();
    }

    function _initDefaultRewards_SymbioticDefaultRewards(
        bool useExisting
    ) internal virtual {
        if (useExisting) {
            _initDefaultRewards_SymbioticDefaultRewards();
        } else {
            address defaultStakerRewardsImplementation = deployCode(
                string.concat(
                    SYMBIOTIC_DEFAULT_REWARDS_PROJECT_ROOT, "out/DefaultStakerRewards.sol/DefaultStakerRewards.json"
                ),
                abi.encode(address(symbioticCore.vaultFactory), address(symbioticCore.networkMiddlewareService))
            );
            symbioticDefaultStakerRewardsFactory = ISymbioticDefaultStakerRewardsFactory(
                deployCode(
                    string.concat(
                        SYMBIOTIC_DEFAULT_REWARDS_PROJECT_ROOT,
                        "out/DefaultStakerRewardsFactory.sol/DefaultStakerRewardsFactory.json"
                    ),
                    abi.encode(defaultStakerRewardsImplementation)
                )
            );
            address defaultOperatorRewardsImplementation = deployCode(
                string.concat(
                    SYMBIOTIC_DEFAULT_REWARDS_PROJECT_ROOT, "out/DefaultOperatorRewards.sol/DefaultOperatorRewards.json"
                ),
                abi.encode(address(symbioticCore.networkMiddlewareService))
            );
            symbioticDefaultOperatorRewardsFactory = ISymbioticDefaultOperatorRewardsFactory(
                deployCode(
                    string.concat(
                        SYMBIOTIC_DEFAULT_REWARDS_PROJECT_ROOT,
                        "out/DefaultOperatorRewardsFactory.sol/DefaultOperatorRewardsFactory.json"
                    ),
                    abi.encode(defaultOperatorRewardsImplementation)
                )
            );
        }
    }

    // ------------------------------------------------------------ DEFAULT-REWARDS-RELATED HELPERS ------------------------------------------------------------ //

    function _getDefaultStakerRewards_SymbioticDefaultRewards(
        address vault
    ) internal virtual returns (address) {
        return _createDefaultStakerRewards_SymbioticDefaultRewards({
            symbioticDefaultStakerRewardsFactory: symbioticDefaultStakerRewardsFactory,
            who: address(this),
            vault: vault,
            adminFee: 1000,
            defaultAdminRoleHolder: address(this),
            adminFeeClaimRoleHolder: address(this),
            adminFeeSetRoleHolder: address(this)
        });
    }

    function _getDefaultStakerRewards_SymbioticDefaultRewards(
        address vault,
        uint256 adminFee,
        address admin
    ) internal virtual returns (address) {
        return _createDefaultStakerRewards_SymbioticDefaultRewards({
            symbioticDefaultStakerRewardsFactory: symbioticDefaultStakerRewardsFactory,
            who: address(this),
            vault: vault,
            adminFee: adminFee,
            defaultAdminRoleHolder: admin,
            adminFeeClaimRoleHolder: admin,
            adminFeeSetRoleHolder: admin
        });
    }

    function _getDefaultStakerRewardsRandom_SymbioticDefaultRewards(
        address vault
    ) internal virtual returns (address) {
        return _getDefaultStakerRewards_SymbioticDefaultRewards(
            vault,
            _randomWithBounds_Symbiotic(
                SYMBIOTIC_DEFAULT_REWARDS_MIN_ADMIN_FEE, SYMBIOTIC_DEFAULT_REWARDS_MAX_ADMIN_FEE
            ),
            address(this)
        );
    }

    function _getDefaultOperatorRewards_SymbioticDefaultRewards() internal virtual returns (address) {
        return _createDefaultOperatorRewards_SymbioticDefaultRewards({
            symbioticDefaultOperatorRewardsFactory: symbioticDefaultOperatorRewardsFactory,
            who: address(this)
        });
    }

    function _getDefaultOperatorRewardsRandom_SymbioticDefaultRewards() internal virtual returns (address) {
        return _getDefaultOperatorRewards_SymbioticDefaultRewards();
    }

    function _fundMiddleware_SymbioticDefaultRewards(address token, address middleware) internal virtual {
        deal(
            token,
            middleware,
            _normalizeForToken_Symbiotic(SYMBIOTIC_DEFAULT_REWARDS_TOKENS_TO_SET_TIMES_1e18, token),
            true
        ); // should cover most cases
    }

    // ------------------------------------------------------------ STAKER-RELATED HELPERS ------------------------------------------------------------ //

    function _stakerClaim_SymbioticDefaultRewards(
        address staker,
        address defaultStakerRewards,
        address token,
        address network
    ) internal virtual {
        _claimRewards_SymbioticDefaultRewards(staker, defaultStakerRewards, token, network);
    }

    function _stakerClaimWeak_SymbioticDefaultRewards(
        address staker,
        address defaultStakerRewards,
        address token,
        address network
    ) internal virtual returns (bool) {
        if (
            ISymbioticDefaultStakerRewards(defaultStakerRewards).claimable(token, staker, abi.encode(network, 1000)) > 0
        ) {
            _stakerClaim_SymbioticDefaultRewards(staker, defaultStakerRewards, token, network);
            return true;
        }
        return false;
    }

    // ------------------------------------------------------------ OPERATOR-RELATED HELPERS ------------------------------------------------------------ //

    function _operatorClaim_SymbioticDefaultRewards(
        address operator,
        address defaultOperatorRewards,
        address network,
        address token,
        uint256 totalClaimable,
        bytes32[] memory proof
    ) internal virtual {
        _claimRewards_SymbioticDefaultRewards(operator, defaultOperatorRewards, network, token, totalClaimable, proof);
    }

    // ------------------------------------------------------------ CURATOR-RELATED HELPERS ------------------------------------------------------------ //

    function _curatorClaim_SymbioticDefaultRewards(
        address curator,
        address defaultStakerRewards,
        address token
    ) public virtual {
        _claimAdminFee_SymbioticDefaultRewards(curator, defaultStakerRewards, token);
    }

    function _curatorClaimWeak_SymbioticDefaultRewards(
        address curator,
        address defaultStakerRewards,
        address token
    ) internal virtual returns (bool) {
        try this._curatorClaim_SymbioticDefaultRewards(curator, defaultStakerRewards, token) {
            return true;
        } catch {
            return false;
        }
    }

    function _curatorSetAdminFee_SymbioticDefaultRewards(
        address curator,
        address defaultStakerRewards,
        uint256 adminFee
    ) internal virtual {
        _setAdminFee_SymbioticDefaultRewards(curator, defaultStakerRewards, adminFee);
    }
}
