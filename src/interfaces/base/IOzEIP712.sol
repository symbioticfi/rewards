// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC5267} from "@openzeppelin/contracts/interfaces/IERC5267.sol";

interface IOzEIP712 is IERC5267 {
    /**
     * @notice The parameters for the initialization of the OzEIP712 contract.
     * @param name The name for EIP712.
     * @param version The version for EIP712.
     */
    struct OzEIP712InitParams {
        string name;
        string version;
    }

    /**
     * @notice Emitted during the OzEIP712 initialization.
     * @param name The name for EIP712.
     * @param version The version for EIP712.
     */
    event InitEIP712(string name, string version);

    /**
     * @notice Returns the EIP712 hash of the typed data.
     * @param structHash The hash of the typed data struct.
     * @return The EIP712 formatted hash.
     */
    function hashTypedDataV4(
        bytes32 structHash
    ) external view returns (bytes32);

    /**
     * @notice Wraps the `structHash` to the EIP712 format for cross-chain usage.
     * @param structHash The hash of the typed data struct.
     * @return The EIP712 formatted hash.
     * @dev It doesn't include `chainId` and `verifyingContract` fields for the domain separator.
     */
    function hashTypedDataV4CrossChain(
        bytes32 structHash
    ) external view returns (bytes32);
}
