// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title MerkleTreeUtils
 * @notice Utility contract for creating and verifying merkle trees in tests
 */
contract MerkleTreeUtils {
    using MerkleProof for bytes32[];

    /**
     * @notice Create a merkle tree from an array of leaves
     * @param leaves Array of leaf hashes
     * @return root The merkle root
     * @return proofs Mapping of leaf to proof
     */
    function createMerkleTree(
        bytes32[] memory leaves
    ) external pure returns (bytes32 root, bytes32[][] memory proofs) {
        if (leaves.length == 0) {
            return (bytes32(0), new bytes32[][](0));
        }

        if (leaves.length == 1) {
            proofs = new bytes32[][](1);
            proofs[0] = new bytes32[](0);
            return (leaves[0], proofs);
        }

        // Create proofs for each leaf
        proofs = new bytes32[][](leaves.length);

        // Build the tree and generate proofs
        root = _buildTreeAndGenerateProofs(leaves, proofs);

        return (root, proofs);
    }

    /**
     * @notice Build merkle tree and generate proofs for all leaves
     */
    function _buildTreeAndGenerateProofs(
        bytes32[] memory leaves,
        bytes32[][] memory proofs
    ) private pure returns (bytes32) {
        uint256 n = leaves.length;

        // For each leaf, generate its proof
        for (uint256 i = 0; i < n; i++) {
            proofs[i] = _generateProofForLeaf(leaves, i);
        }

        // Build the tree to get the root
        return _buildTree(leaves);
    }

    /**
     * @notice Build merkle tree and return root
     */
    function _buildTree(
        bytes32[] memory leaves
    ) private pure returns (bytes32) {
        uint256 n = leaves.length;

        if (n == 1) {
            return leaves[0];
        }

        // Create a copy to work with
        bytes32[] memory currentLevel = new bytes32[](n);
        for (uint256 i = 0; i < n; i++) {
            currentLevel[i] = leaves[i];
        }

        while (currentLevel.length > 1) {
            uint256 nextLevelLength = (currentLevel.length + 1) / 2;
            bytes32[] memory nextLevel = new bytes32[](nextLevelLength);

            for (uint256 i = 0; i < nextLevelLength; i++) {
                if (i * 2 + 1 < currentLevel.length) {
                    nextLevel[i] = keccak256(abi.encodePacked(currentLevel[i * 2], currentLevel[i * 2 + 1]));
                } else {
                    nextLevel[i] = currentLevel[i * 2];
                }
            }

            currentLevel = nextLevel;
        }

        return currentLevel[0];
    }

    /**
     * @notice Generate proof for a specific leaf
     */
    function _generateProofForLeaf(
        bytes32[] memory leaves,
        uint256 leafIndex
    ) private pure returns (bytes32[] memory proof) {
        uint256 n = leaves.length;

        if (n <= 1) {
            return new bytes32[](0);
        }

        // Calculate proof length
        uint256 proofLength = 0;
        uint256 tempLength = n;
        while (tempLength > 1) {
            proofLength++;
            tempLength = (tempLength + 1) / 2;
        }

        proof = new bytes32[](proofLength);
        uint256 proofIndex = 0;

        // Create a copy to work with
        bytes32[] memory currentLevel = new bytes32[](n);
        for (uint256 i = 0; i < n; i++) {
            currentLevel[i] = leaves[i];
        }

        uint256 currentIndex = leafIndex;
        uint256 levelLength = n;

        while (levelLength > 1) {
            uint256 nextLevelLength = (levelLength + 1) / 2;
            bytes32[] memory nextLevel = new bytes32[](nextLevelLength);

            for (uint256 i = 0; i < nextLevelLength; i++) {
                if (i * 2 + 1 < levelLength) {
                    nextLevel[i] = keccak256(abi.encodePacked(currentLevel[i * 2], currentLevel[i * 2 + 1]));

                    // Add sibling to proof
                    if (currentIndex == i * 2) {
                        proof[proofIndex] = currentLevel[i * 2 + 1];
                        proofIndex++;
                    } else if (currentIndex == i * 2 + 1) {
                        proof[proofIndex] = currentLevel[i * 2];
                        proofIndex++;
                    }
                } else {
                    nextLevel[i] = currentLevel[i * 2];
                }
            }

            currentLevel = nextLevel;
            levelLength = nextLevelLength;
            currentIndex = currentIndex / 2;
        }

        return proof;
    }

    /**
     * @notice Verify a merkle proof
     * @param leaf The leaf hash to verify
     * @param proof The merkle proof
     * @param root The merkle root
     * @return valid Whether the proof is valid
     */
    function verifyProof(
        bytes32 leaf,
        bytes32[] memory proof,
        bytes32 root
    ) external pure returns (bool valid) {
        return MerkleProof.verify(proof, root, leaf);
    }
}
