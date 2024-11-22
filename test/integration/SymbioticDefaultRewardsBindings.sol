// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SymbioticDefaultRewardsImports.sol";

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {Test} from "forge-std/Test.sol";

contract SymbioticDefaultRewardsBindings is Test {
    using SafeERC20 for IERC20;

    function _createDefaultStakerRewards_SymbioticDefaultRewards(
        ISymbioticDefaultStakerRewardsFactory symbioticDefaultStakerRewardsFactory,
        address who,
        address vault,
        uint256 adminFee,
        address defaultAdminRoleHolder,
        address adminFeeClaimRoleHolder,
        address adminFeeSetRoleHolder
    ) internal virtual returns (address defaultStakerRewards) {
        vm.startPrank(who);
        defaultStakerRewards = symbioticDefaultStakerRewardsFactory.create(
            ISymbioticDefaultStakerRewards.InitParams({
                vault: vault,
                adminFee: adminFee,
                defaultAdminRoleHolder: defaultAdminRoleHolder,
                adminFeeClaimRoleHolder: adminFeeClaimRoleHolder,
                adminFeeSetRoleHolder: adminFeeSetRoleHolder
            })
        );
        vm.stopPrank();
    }

    function _createDefaultOperatorRewards_SymbioticDefaultRewards(
        ISymbioticDefaultOperatorRewardsFactory symbioticDefaultOperatorRewardsFactory,
        address who
    ) internal virtual returns (address defaultOperatorRewards) {
        vm.startPrank(who);
        defaultOperatorRewards = symbioticDefaultOperatorRewardsFactory.create();
        vm.stopPrank();
    }

    function _distributeRewards_SymbioticDefaultRewards(
        address who,
        address defaultStakerRewards,
        address network,
        address token,
        uint256 amount,
        uint48 captureTimestamp
    ) internal virtual {
        vm.startPrank(who);
        IERC20(token).forceApprove(defaultStakerRewards, amount);
        ISymbioticDefaultStakerRewards(defaultStakerRewards).distributeRewards(
            network,
            token,
            amount,
            abi.encode(
                captureTimestamp,
                ISymbioticDefaultStakerRewards(defaultStakerRewards).ADMIN_FEE_BASE(),
                new bytes(0),
                new bytes(0)
            )
        );
        vm.stopPrank();
    }

    function _claimRewards_SymbioticDefaultRewards(
        address who,
        address defaultStakerRewards,
        address recipient,
        address token,
        address network
    ) internal virtual {
        vm.startPrank(who);
        uint256 maxRewards = 1000;
        ISymbioticDefaultStakerRewards(defaultStakerRewards).claimRewards(
            recipient, token, abi.encode(network, maxRewards, new bytes[](0))
        );
        vm.stopPrank();
    }

    function _claimRewards_SymbioticDefaultRewards(
        address who,
        address defaultStakerRewards,
        address token,
        address network
    ) internal virtual {
        _claimRewards_SymbioticDefaultRewards(who, defaultStakerRewards, who, token, network);
    }

    function _claimAdminFee_SymbioticDefaultRewards(
        address who,
        address defaultStakerRewards,
        address recipient,
        address token
    ) internal virtual {
        vm.startPrank(who);
        ISymbioticDefaultStakerRewards(defaultStakerRewards).claimAdminFee(recipient, token);
        vm.stopPrank();
    }

    function _claimAdminFee_SymbioticDefaultRewards(
        address who,
        address defaultStakerRewards,
        address token
    ) internal virtual {
        _claimAdminFee_SymbioticDefaultRewards(who, defaultStakerRewards, who, token);
    }

    function _setAdminFee_SymbioticDefaultRewards(
        address who,
        address defaultStakerRewards,
        uint256 adminFee
    ) internal virtual {
        vm.startPrank(who);
        ISymbioticDefaultStakerRewards(defaultStakerRewards).setAdminFee(adminFee);
        vm.stopPrank();
    }

    function _distributeRewards_SymbioticDefaultRewards(
        address who,
        address defaultOperatorRewards,
        address network,
        address token,
        uint256 amount,
        bytes32 root
    ) internal virtual {
        vm.startPrank(who);
        IERC20(token).forceApprove(defaultOperatorRewards, amount);
        ISymbioticDefaultOperatorRewards(defaultOperatorRewards).distributeRewards(network, token, amount, root);
        vm.stopPrank();
    }

    function _claimRewards_SymbioticDefaultRewards(
        address who,
        address defaultOperatorRewards,
        address recipient,
        address network,
        address token,
        uint256 totalClaimable,
        bytes32[] memory proof
    ) internal virtual {
        vm.startPrank(who);
        ISymbioticDefaultOperatorRewards(defaultOperatorRewards).claimRewards(
            recipient, network, token, totalClaimable, proof
        );
        vm.stopPrank();
    }

    function _claimRewards_SymbioticDefaultRewards(
        address who,
        address defaultOperatorRewards,
        address network,
        address token,
        uint256 totalClaimable,
        bytes32[] memory proof
    ) internal virtual {
        _claimRewards_SymbioticDefaultRewards(who, defaultOperatorRewards, who, network, token, totalClaimable, proof);
    }

    function _grantRole_SymbioticDefaultRewards(
        address who,
        address where,
        bytes32 role,
        address account
    ) internal virtual {
        vm.startPrank(who);
        AccessControl(where).grantRole(role, account);
        vm.stopPrank();
    }

    function _grantRoleDefaultAdmin_SymbioticDefaultRewards(
        address who,
        address where,
        address account
    ) internal virtual {
        _grantRole_SymbioticDefaultRewards(who, where, AccessControl(where).DEFAULT_ADMIN_ROLE(), account);
    }

    function _grantRoleAdminFeeClaim_SymbioticDefaultRewards(
        address who,
        address where,
        address account
    ) internal virtual {
        _grantRole_SymbioticDefaultRewards(
            who, where, ISymbioticDefaultStakerRewards(where).ADMIN_FEE_CLAIM_ROLE(), account
        );
    }

    function _grantRoleAdminFeeSet_SymbioticDefaultRewards(
        address who,
        address where,
        address account
    ) internal virtual {
        _grantRole_SymbioticDefaultRewards(
            who, where, ISymbioticDefaultStakerRewards(where).ADMIN_FEE_SET_ROLE(), account
        );
    }
}
