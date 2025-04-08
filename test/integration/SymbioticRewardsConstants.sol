// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SymbioticRewardsImports.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

library SymbioticRewardsConstants {
    using Strings for string;

    function defaultStakerRewardsFactory() internal view returns (ISymbioticDefaultStakerRewardsFactory) {
        if (block.chainid == 1) {
            // mainnet
            return ISymbioticDefaultStakerRewardsFactory(0x0000000000000000000000000000000000000000);
        } else if (block.chainid == 17_000) {
            // holesky
            return ISymbioticDefaultStakerRewardsFactory(0x58E80fA5Eb938525f2ca80C5bdE724D7a99A7892);
        } else if (block.chainid == 11_155_111) {
            // sepolia
            return ISymbioticDefaultStakerRewardsFactory(0xE6381EDA7444672da17Cd859e442aFFcE7e170F0);
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
