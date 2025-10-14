// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ProtocolFees} from "./ProtocolFees.sol";
import {ICumulativeMerkleRewards} from "../../interfaces/rewardsV2/ICumulativeMerkleRewards.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

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

    uint64 constant REWARDS_TYPE_CUMULATIVE_MERKLE = 0;

    /**
     * @notice Storage structure for cumulative merkle rewards
     */
    struct CumulativeMerkleRewardsStorage {
        mapping(address network => CumulativeDistribution) _lastCumulativeDistribution;
        mapping(address network => mapping(address token => uint256 amount)) _lastTotalAmounts;
        mapping(address network => mapping(bytes32 root => bool value)) _isCumulativeDistributionRoot;
        mapping(address network => mapping(address token => uint256 amount)) _deposited;
        mapping(
            address network
                => mapping(
                    address token => mapping(address rewardee => mapping(uint256 rewardeeType => uint256 amount))
                )
        ) _claimed;
        mapping(address network => address value) _rewarder;
    }

    /* STORAGE */

    // keccak256(abi.encode(uint256(keccak256("cumulative.merkle.rewards.storage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CUMULATIVE_MERKLE_REWARDS_STORAGE_POSITION =
        0xe2b5451d896510c794b5f0b35ade2d4a663033545e0e358dd0ee29143f654400;

    /* FUNCTIONS */

    function __CumulativeMerkleRewards_init(
        CumulativeMerkleRewardsInitParams calldata initParams
    ) internal onlyInitializing {
        __EIP712_init("CumulativeMerkleRewards", "1");
        __ProtocolFees_init(initParams.protocolFeesInitParams);
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
    function isCumulativeDistributionRoot(address network, bytes32 root) public view returns (bool) {
        return _cumulativeMerkleRewardsStorage()._isCumulativeDistributionRoot[network][root];
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function withdrawable(address network, address token) public view returns (uint256 amount) {
        uint256 lastTotalAmount = _cumulativeMerkleRewardsStorage()._lastTotalAmounts[network][token];
        uint256 deposited = _cumulativeMerkleRewardsStorage()._deposited[network][token];
        return deposited > lastTotalAmount ? deposited - lastTotalAmount : 0;
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
        // Check chainIds are sorted ascending
        for (uint256 i = 1; i < totalAmounts.length; ++i) {
            if (totalAmounts[i].chainId <= totalAmounts[i - 1].chainId) {
                revert UnsortedChainIds();
            }
        }

        // Check tokens are unique and sorted ascending
        for (uint256 i = 1; i < totalAmounts.length; ++i) {
            if (totalAmounts[i].token <= totalAmounts[i - 1].token) {
                revert DuplicateOrUnsortedTokens();
            }
        }

        // Check root is not already set
        if (_cumulativeMerkleRewardsStorage()._isCumulativeDistributionRoot[network][cumulativeDistribution.merkleRoot])
        {
            revert RootAlreadySet();
        }

        // Create EIP712 hash for cross-chain compatibility
        bytes32 hash = _hashCumulativeDistributionPayload(cumulativeDistribution, totalAmounts);

        // Verify owner signature
        if (!SignatureChecker.isValidSignatureNow(owner(), hash, ownerSignature)) {
            revert InvalidSignature();
        }

        // Verify rewarder signature
        address networkRewarder = _cumulativeMerkleRewardsStorage()._rewarder[network];
        if (!SignatureChecker.isValidSignatureNow(networkRewarder, hash, rewarderSignature)) {
            revert InvalidSignature();
        }

        // Check timestamp is sequential
        CumulativeDistribution memory lastDistribution =
            _cumulativeMerkleRewardsStorage()._lastCumulativeDistribution[network];
        if (cumulativeDistribution.timestamp <= lastDistribution.timestamp) {
            revert InvalidTimestamp();
        }

        // Calculate distribution amounts and deduct protocol fees (only for current chain)
        uint64 currentChainId = uint64(block.chainid);
        for (uint256 i = 0; i < totalAmounts.length; ++i) {
            TokenAmount calldata totalAmount = totalAmounts[i];
            if (totalAmount.chainId != currentChainId) {
                continue; // Ignore amounts for other chains
            }

            uint256 lastTotalAmount = _cumulativeMerkleRewardsStorage()._lastTotalAmounts[network][totalAmount.token];

            if (totalAmount.amount == lastTotalAmount) {
                continue; // No new distribution for this token
            }

            if (totalAmount.amount < lastTotalAmount) {
                revert InvalidTotalAmount();
            }

            uint256 distributionAmount = totalAmount.amount - lastTotalAmount;

            // Deduct protocol fees
            uint256 fees =
                _deductProtocolFees(REWARDS_TYPE_CUMULATIVE_MERKLE, network, totalAmount.token, distributionAmount);

            // Update deposited amount (subtract fees)
            _cumulativeMerkleRewardsStorage()._deposited[network][totalAmount.token] -= fees;

            // Check sufficient deposited amount
            if (_cumulativeMerkleRewardsStorage()._deposited[network][totalAmount.token] < totalAmount.amount) {
                revert InsufficientDeposited();
            }

            _cumulativeMerkleRewardsStorage()._lastTotalAmounts[network][totalAmounts[i].token] = totalAmounts[i].amount;
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
    function depositCumulativeMerkleRewards(address network, address token, uint256 amount) public {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        _cumulativeMerkleRewardsStorage()._deposited[network][token] += amount;
        emit DepositCumulativeMerkleRewards(network, token, amount);
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
            revert InsufficientDeposited();
        }

        _cumulativeMerkleRewardsStorage()._deposited[network][token] -= amount;
        IERC20(token).safeTransfer(recipient, amount);
        emit WithdrawCumulativeMerkleRewards(network, token, amount);
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
        // Check root is set
        if (!_cumulativeMerkleRewardsStorage()._isCumulativeDistributionRoot[network][merkleRoot]) {
            revert InvalidMerkleRoot();
        }

        // Verify merkle proof
        if (!MerkleProof.verify(proof, merkleRoot, keccak256(abi.encode(msg.sender, leaf)))) {
            revert InvalidMerkleRoot();
        }

        // Calculate claimable amount
        uint256 claimedAmount =
            _cumulativeMerkleRewardsStorage()._claimed[network][leaf.token][msg.sender][leaf.rewardeeType];
        uint256 claimableAmount = leaf.amount > claimedAmount ? leaf.amount - claimedAmount : 0;

        if (claimableAmount == 0) {
            return;
        }

        // Update claimed amount
        _cumulativeMerkleRewardsStorage()._claimed[network][leaf.token][msg.sender][leaf.rewardeeType] = leaf.amount;

        // Transfer tokens
        IERC20(leaf.token).safeTransfer(recipient, claimableAmount);
        emit ClaimCumulativeMerkleRewards(msg.sender, network, leaf);
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function setRewarder(
        address rewarder
    ) public {
        _cumulativeMerkleRewardsStorage()._rewarder[msg.sender] = rewarder;
        emit SetRewarder(msg.sender, rewarder);
    }

    /**
     * @inheritdoc ICumulativeMerkleRewards
     */
    function claimRewards(address recipient, address token, bytes calldata data) public virtual {
        // Decode data: network (32 bytes) + merkleRoot (32 bytes) + leaf (rest)
        address network;
        bytes32 merkleRoot;
        ICumulativeMerkleRewards.CumulativeDistributionLeaf calldata leaf;
        bytes32[] calldata proof;

        assembly {
            network := calldataload(data.offset)
            merkleRoot := calldataload(add(data.offset, 0x20))
            leaf := add(data.offset, 0x40)
            proof.length := calldataload(add(data.offset, 0x100))
            proof.offset := add(data.offset, 0x120)
        }

        if (token != leaf.token) {
            revert InvalidChainId(); // Reusing error for invalid token
        }

        claimCumulativeMerkleRewards(recipient, network, leaf, proof, merkleRoot);
    }

    /* INTERNAL FUNCTIONS */

    /**
     * @notice Get the cumulative merkle rewards storage
     * @return $ The storage struct
     */
    function _cumulativeMerkleRewardsStorage() private pure returns (CumulativeMerkleRewardsStorage storage $) {
        assembly {
            $.slot := CUMULATIVE_MERKLE_REWARDS_STORAGE_POSITION
        }
    }

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

        bytes32 totalAmountsHash = keccak256(abi.encode(totalAmounts));
        for (uint256 i = 0; i < totalAmounts.length; ++i) {
            totalAmountsHash = keccak256(
                abi.encode(
                    totalAmountsHash,
                    keccak256(
                        abi.encode(
                            TOKEN_AMOUNT_TYPEHASH,
                            totalAmounts[i].chainId,
                            totalAmounts[i].token,
                            totalAmounts[i].amount
                        )
                    )
                )
            );
        }

        return _hashTypedDataV4(keccak256(abi.encode(PAYLOAD_TYPEHASH, cumulativeDistributionHash, totalAmountsHash)));
    }
}
