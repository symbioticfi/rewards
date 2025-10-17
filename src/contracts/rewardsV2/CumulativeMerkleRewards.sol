// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ProtocolFees} from "./ProtocolFees.sol";

import {ICumulativeMerkleRewards} from "../../interfaces/rewardsV2/ICumulativeMerkleRewards.sol";
import {IRewards} from "../../interfaces/rewardsV2/IRewards.sol";

import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract CumulativeMerkleRewards is EIP712Upgradeable, ProtocolFees, ICumulativeMerkleRewards {
    using SafeERC20 for IERC20;
    using Math for uint256;

    /* CONSTANTS */

    bytes32 private constant CUMULATIVE_DISTRIBUTION_TYPEHASH =
        keccak256("CumulativeDistribution(uint48 timestamp,bytes32 merkleRoot)");

    bytes32 private constant TOKEN_AMOUNT_TYPEHASH =
        keccak256("TokenAmount(uint64 chainId,address token,uint256 amount)");

    bytes32 private constant PAYLOAD_TYPEHASH = keccak256(
        "CumulativeDistributionPayload(CumulativeDistribution cumulativeDistribution,TokenAmount[] totalAmounts)CumulativeDistribution(uint48 timestamp,bytes32 merkleRoot)TokenAmount(uint64 chainId,address token,uint256 amount)"
    );

    /* STORAGE */

    struct CumulativeMerkleRewardsStorage {
        mapping(address network => CumulativeDistribution) _lastCumulativeDistribution;
        mapping(address network => mapping(address token => uint256 amount)) _lastTotalAmounts;
        mapping(address network => mapping(bytes32 root => bool value)) _isCumulativeDistributionRoot;
        mapping(address network => mapping(address token => uint256 amount)) _balances;
        mapping(
            address network
                => mapping(
                address token => mapping(address rewardee => mapping(uint256 rewardeeType => uint256 amount))
            )
        ) _claimed;
        mapping(address network => address value) _rewarder;
    }

    // keccak256(abi.encode(uint256(keccak256("symbiotic.rewards.CumulativeMerkleRewards")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CUMULATIVE_MERKLE_REWARDS_STORAGE_POSITION =
        0xb35d10d93f469d2505237bd5d8067e02fbabfe765e611799bdbd03de345d3300;

    function _cumulativeMerkleRewardsStorage() private pure returns (CumulativeMerkleRewardsStorage storage $) {
        assembly {
            $.slot := CUMULATIVE_MERKLE_REWARDS_STORAGE_POSITION
        }
    }

    /* FUNCTIONS */

    function __CumulativeMerkleRewards_init() internal onlyInitializing {
        __EIP712_init("CumulativeMerkleRewards", "1");
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function lastCumulativeDistribution(
        address network
    ) public view returns (CumulativeDistribution memory) {
        return _cumulativeMerkleRewardsStorage()._lastCumulativeDistribution[network];
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function lastTotalAmount(
        address network,
        address token
    ) public view returns (uint256) {
        return _cumulativeMerkleRewardsStorage()._lastTotalAmounts[network][token];
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function isCumulativeDistributionRoot(
        address network,
        bytes32 root
    ) public view returns (bool) {
        return _cumulativeMerkleRewardsStorage()._isCumulativeDistributionRoot[network][root];
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function withdrawable(
        address network,
        address token
    ) public view returns (uint256 amount) {
        return _cumulativeMerkleRewardsStorage()._balances[network][token];
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function claimed(
        address network,
        address token,
        address rewardee,
        uint256 rewardeeType
    ) public view returns (uint256 amount) {
        return _cumulativeMerkleRewardsStorage()._claimed[network][token][rewardee][rewardeeType];
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function rewarder(
        address network
    ) public view returns (address) {
        return _cumulativeMerkleRewardsStorage()._rewarder[network];
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function distributeCumulativeMerkleRewards(
        address network,
        CumulativeDistribution calldata cumulativeDistribution,
        TokenAmount[] calldata totalAmounts,
        bytes calldata ownerSignature,
        bytes calldata rewarderSignature
    ) public {
        // Check entries are sorted by chainId ascending; within the same chainId, tokens strictly ascending
        uint64 prevChainId = totalAmounts.length > 0 ? totalAmounts[0].chainId : 0;
        for (uint256 i = 1; i < totalAmounts.length; ++i) {
            uint64 currChainId = totalAmounts[i].chainId;
            if (currChainId < prevChainId) {
                revert UnsortedChainIds();
            }

            // When within the same chain, token addresses must be strictly increasing (unique and sorted)
            if (currChainId == prevChainId && totalAmounts[i].token <= totalAmounts[i - 1].token) {
                revert DuplicateOrUnsortedTokens();
            }
            prevChainId = currChainId;
        }

        if (_cumulativeMerkleRewardsStorage()._isCumulativeDistributionRoot[network][cumulativeDistribution.merkleRoot])
        {
            revert RootAlreadySet();
        }

        // Create EIP712 hash
        bytes32 hash = _hashCumulativeDistributionPayload(cumulativeDistribution, totalAmounts);

        // Verify owner signature
        if (!SignatureChecker.isValidSignatureNow(owner(), hash, ownerSignature)) {
            revert InvalidSignature();
        }

        // Verify rewarder signature
        if (!SignatureChecker.isValidSignatureNow(rewarder(network), hash, rewarderSignature)) {
            revert InvalidSignature();
        }

        // Check timestamp is sequential
        CumulativeDistribution memory lastDistribution =
            _cumulativeMerkleRewardsStorage()._lastCumulativeDistribution[network];
        if (cumulativeDistribution.timestamp <= lastDistribution.timestamp) {
            revert InvalidTimestamp();
        }

        // Calculate distribution amounts and deduct protocol fees (only for current chain)
        for (uint256 i; i < totalAmounts.length; ++i) {
            TokenAmount calldata totalAmount = totalAmounts[i];
            if (totalAmount.chainId != uint64(block.chainid)) {
                continue; // Ignore amounts for other chains
            }

            uint256 distributionAmount = totalAmount.amount - lastTotalAmount(network, totalAmount.token);

            // Update deposited amount (subtract fees)
            uint256 fees = _deductProtocolFees(
                uint64(IRewards.RewardsType.CUMULATIVE_MERKLE), network, totalAmount.token, totalAmount.amount
            );

            // Check sufficient deposited amount
            if (_cumulativeMerkleRewardsStorage()._balances[network][totalAmount.token] < totalAmount.amount + fees) {
                revert InsufficientDeposited(network, totalAmount.token);
            }

            _cumulativeMerkleRewardsStorage()._balances[network][totalAmount.token] -= totalAmount.amount + fees;
        }

        // Update storage
        _cumulativeMerkleRewardsStorage()._lastCumulativeDistribution[network] = cumulativeDistribution;
        _cumulativeMerkleRewardsStorage()._isCumulativeDistributionRoot[network][cumulativeDistribution.merkleRoot] =
            true;

        emit DistributeCumulativeMerkleRewards(network, cumulativeDistribution);
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function depositCumulativeMerkleRewards(
        address network,
        address token,
        uint256 amount
    ) public {
        uint256 balanceBefore = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        uint256 actualAmount = IERC20(token).balanceOf(address(this)) - balanceBefore;

        if (actualAmount == 0) {
            revert InsufficientTransfer();
        }

        _cumulativeMerkleRewardsStorage()._balances[network][token] += actualAmount;
        emit DepositCumulativeMerkleRewards(network, token, actualAmount);
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function withdrawCumulativeMerkleRewards(
        address recipient,
        address network,
        address token,
        uint256 amount
    ) public {
        if (_cumulativeMerkleRewardsStorage()._rewarder[network] != msg.sender) {
            revert NotRewarder();
        }

        uint256 withdrawableAmount = withdrawable(network, token);
        if (amount > withdrawableAmount) {
            revert InsufficientDeposited(network, token);
        }

        _cumulativeMerkleRewardsStorage()._balances[network][token] -= amount;

        uint256 balanceBefore = IERC20(token).balanceOf(recipient);
        IERC20(token).safeTransfer(recipient, amount);
        uint256 actualAmount = IERC20(token).balanceOf(recipient) - balanceBefore;

        emit WithdrawCumulativeMerkleRewards(network, token, actualAmount);
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function claimCumulativeMerkleRewards(
        address recipient,
        address network,
        CumulativeDistributionLeaf calldata leaf,
        bytes32[] calldata proof,
        bytes32 merkleRoot
    ) public {
        if (!isCumulativeDistributionRoot(network, merkleRoot)) {
            revert InvalidMerkleRoot();
        }

        if (!MerkleProof.verifyCalldata(proof, merkleRoot, keccak256(abi.encode(msg.sender, leaf)))) {
            revert InvalidMerkleRoot();
        }

        uint256 claimableAmount = leaf.amount
            .saturatingSub(
                _cumulativeMerkleRewardsStorage()._claimed[network][leaf.token][msg.sender][leaf.rewardeeType]
            );

        if (claimableAmount == 0) {
            revert NoCumulativeRewardsToClaim();
        }

        _cumulativeMerkleRewardsStorage()._claimed[network][leaf.token][msg.sender][leaf.rewardeeType] = leaf.amount;

        IERC20(leaf.token).safeTransfer(recipient, claimableAmount);
        emit ClaimCumulativeMerkleRewards(msg.sender, network, leaf);
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function setRewarder(
        address rewarder_
    ) public {
        _cumulativeMerkleRewardsStorage()._rewarder[msg.sender] = rewarder_;
        emit SetRewarder(msg.sender, rewarder_);
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function claimRewards(
        address recipient,
        address token,
        bytes calldata data
    ) public virtual {
        // Decode data: network (32 bytes) + merkleRoot (32 bytes) + leaf (160 bytes) + proof (dynamic)
        address network;
        bytes32 merkleRoot;
        ICumulativeMerkleRewards.CumulativeDistributionLeaf calldata leaf;
        bytes32[] calldata proof;

        assembly {
            network := calldataload(data.offset)
            merkleRoot := calldataload(add(data.offset, 0x20))
            leaf := add(data.offset, 0x40)
            proof.length := calldataload(add(data.offset, 0xE0))
            proof.offset := add(data.offset, 0x100)
        }

        if (token != leaf.token) {
            revert InvalidToken();
        }

        claimCumulativeMerkleRewards(recipient, network, leaf, proof, merkleRoot);
    }

    /* INTERNAL FUNCTIONS */

    /**
     * @notice Hash cumulative distribution payload for EIP712
     * @param cumulativeDistribution The cumulative distribution
     * @param totalAmounts Array of total amounts
     * @return The hash
     */
    function _hashCumulativeDistributionPayload(
        CumulativeDistribution calldata cumulativeDistribution,
        TokenAmount[] calldata totalAmounts
    ) private view returns (bytes32) {
        bytes32 cumulativeDistributionHash = keccak256(
            abi.encode(
                CUMULATIVE_DISTRIBUTION_TYPEHASH, cumulativeDistribution.timestamp, cumulativeDistribution.merkleRoot
            )
        );

        bytes32[] memory tokenAmountHashes = new bytes32[](totalAmounts.length);
        for (uint256 i = 0; i < totalAmounts.length; i++) {
            tokenAmountHashes[i] = keccak256(
                abi.encode(
                    TOKEN_AMOUNT_TYPEHASH, totalAmounts[i].chainId, totalAmounts[i].token, totalAmounts[i].amount
                )
            );
        }

        bytes32 totalAmountsHash = keccak256(abi.encodePacked(tokenAmountHashes));

        return _hashTypedDataV4(keccak256(abi.encode(PAYLOAD_TYPEHASH, cumulativeDistributionHash, totalAmountsHash)));
    }
}
