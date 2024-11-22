// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SymbioticDefaultRewardsImports.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

library SymbioticDefaultRewardsConstants {
    using Strings for string;

    function defaultStakerRewardsFactory() internal view returns (ISymbioticDefaultStakerRewardsFactory) {
        if (block.chainid == 1) {
            // mainnet
            revert("SymbioticDefaultRewardsConstants.defaultStakerRewardsFactory(): mainnet not supported yet");
        } else if (block.chainid == 17_000) {
            // holesky
            return ISymbioticDefaultStakerRewardsFactory(0x698C36DE44D73AEfa3F0Ce3c0255A8667bdE7cFD);
        } else {
            revert("SymbioticDefaultRewardsConstants.defaultStakerRewardsFactory(): chainid not supported");
        }
    }

    function defaultOperatorRewardsFactory() internal view returns (ISymbioticDefaultOperatorRewardsFactory) {
        if (block.chainid == 1) {
            // mainnet
            revert("SymbioticDefaultRewardsConstants.defaultOperatorRewardsFactory(): mainnet not supported yet");
        } else if (block.chainid == 17_000) {
            // holesky
            return ISymbioticDefaultOperatorRewardsFactory(0x00055dee9933F578340db42AA978b9c8B25640f6);
        } else {
            revert("SymbioticDefaultRewardsConstants.defaultOperatorRewardsFactory(): chainid not supported");
        }
    }
}
