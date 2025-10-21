// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IOzEIP712} from "../../interfaces/base/IOzEIP712.sol";

import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {IERC5267} from "@openzeppelin/contracts/interfaces/IERC5267.sol";

import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

abstract contract OzEIP712 is EIP712Upgradeable, IOzEIP712 {
    bytes32 private constant CROSS_CHAIN_TYPE_HASH = keccak256("EIP712Domain(string name,string version)");

    function __OzEIP712_init(
        OzEIP712InitParams memory initParams
    ) internal virtual onlyInitializing {
        __EIP712_init(initParams.name, initParams.version);
        emit InitEIP712(initParams.name, initParams.version);
    }

    /**
     * @inheritdoc IOzEIP712
     */
    function hashTypedDataV4(
        bytes32 structHash
    ) public view returns (bytes32) {
        return _hashTypedDataV4(structHash);
    }

    /**
     * @inheritdoc IOzEIP712
     */
    function hashTypedDataV4CrossChain(
        bytes32 structHash
    ) public view virtual returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(
            keccak256(abi.encode(CROSS_CHAIN_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash())), structHash
        );
    }
}
