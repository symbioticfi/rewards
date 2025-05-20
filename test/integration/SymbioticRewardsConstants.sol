// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SymbioticRewardsImports.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

library SymbioticRewardsConstants {
    using Strings for string;

    function defaultStakerRewardsFactory() internal view returns (ISymbioticDefaultStakerRewardsFactory) {
        if (block.chainid == 1) {
            // mainnet
            return ISymbioticDefaultStakerRewardsFactory(0xFEB871581C2ab2e1EEe6f7dDC7e6246cFa087A23);
        } else if (block.chainid == 17_000) {
            // holesky
            return ISymbioticDefaultStakerRewardsFactory(0x58E80fA5Eb938525f2ca80C5bdE724D7a99A7892);
        } else if (block.chainid == 11_155_111) {
            // sepolia
            return ISymbioticDefaultStakerRewardsFactory(0xE6381EDA7444672da17Cd859e442aFFcE7e170F0);
        }  else if (block.chainid == 560048) {
            // hoodi
            return ISymbioticDefaultStakerRewardsFactory(0x1eA0b919721C20dae19aBc4391850D94eDbe9b1c);
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
        } else if (block.chainid == 11_155_111) {
            // hoodi
            return ISymbioticDefaultOperatorRewardsFactory(0xE7e597655C3F76117302ea6103f5F2B3F3D75c5d);
        } else {
            revert("SymbioticRewardsConstants.defaultOperatorRewardsFactory(): chainid not supported");
        }
    }
}
