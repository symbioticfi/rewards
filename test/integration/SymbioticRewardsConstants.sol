// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SymbioticRewardsImports.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

library SymbioticRewardsConstants {
    using Strings for string;

    function defaultStakerRewardsFactory() internal view returns (ISymbioticDefaultStakerRewardsFactory) {
        if (block.chainid == 1) {
            // mainnet
            return ISymbioticDefaultStakerRewardsFactory(0x290CAB97a312164Ccf095d75D6175dF1C4A0a25F);
        } else if (block.chainid == 17_000) {
            // holesky
            return ISymbioticDefaultStakerRewardsFactory(0x698C36DE44D73AEfa3F0Ce3c0255A8667bdE7cFD);
        } else if (block.chainid == 11_155_111) {
            // sepolia
            return ISymbioticDefaultStakerRewardsFactory(0x70C618a13D1A57f7234c0b893b9e28C5cA8E7f37);
        } else {
            revert("SymbioticRewardsConstants.defaultStakerRewardsFactory(): chainid not supported");
        }
    }

    function defaultOperatorRewardsFactory() internal view returns (ISymbioticDefaultOperatorRewardsFactory) {
        if (block.chainid == 1) {
            // mainnet
            return ISymbioticDefaultOperatorRewardsFactory(0x6D52fC402b2dA2669348Cc2682D85c61c122755D);
        } else if (block.chainid == 17_000) {
            // holesky
            return ISymbioticDefaultOperatorRewardsFactory(0x00055dee9933F578340db42AA978b9c8B25640f6);
        } else if (block.chainid == 11_155_111) {
            // sepolia
            return ISymbioticDefaultOperatorRewardsFactory(0x8D6C873cb7ffa6BE615cE1D55801a9417Ed55f9B);
        } else {
            revert("SymbioticRewardsConstants.defaultOperatorRewardsFactory(): chainid not supported");
        }
    }
}
