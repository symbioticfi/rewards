// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IProtocolFees} from "./IProtocolFees.sol";

/**
 * @title ICumulativeMerkleRewards
 * @notice Interface for managing cumulative merkle-based reward distributions
 * @dev Allows creating cumulative rewards distributions using merkle trees constructed off-chain,
 * with signature validation and cross-chain compatibility. Storage is checkpointed for lookups.
 */
interface ICumulativeMerkleRewards {
    /* ERRORS */

    error InvalidChainId();
    error InvalidSignature();
    error InvalidTimestamp();
    error InvalidMerkleRoot();
    error InvalidToken();
    error InsufficientTransfer();
    error NotRewarder();
    error RootAlreadySet();
    error UnsortedChainIds();
    error DuplicateOrUnsortedTokens();
    error NotRewardee();
    error InvalidTotalAmount();
    error NoCumulativeRewardsToClaim();
    error NoTotalAmounts();

    /* STRUCTS */

    struct CumulativeDistribution {
        uint48 timestamp;
        bytes32 merkleRoot;
    }

    struct TokenAmount {
        uint64 chainId;
        address token;
        uint256 amount;
    }

    struct CumulativeDistributionLeaf {
        uint64 chainId;
        address token;
        uint256 rewardeeType;
        uint256 amount;
        bytes32 rewardeeDataHash;
    }

    /* EVENTS */

    event DistributeCumulativeMerkleRewards(address indexed network, CumulativeDistribution cumulativeDistribution);
    event DepositCumulativeMerkleRewards(address indexed network, address indexed token, uint256 amount);
    event WithdrawCumulativeMerkleRewards(address indexed network, address indexed token, uint256 amount);
    event ClaimCumulativeMerkleRewards(
        address indexed rewardee, address indexed network, CumulativeDistributionLeaf leaf
    );
    event SetRewarder(address indexed network, address rewarder);
    event SetProtocol(address indexed protocol);

    /* FUNCTIONS */

    /**
     * @notice Get the last cumulative distribution for a network
     * @param network The network address
     * @return The last cumulative distribution
     */
    function lastCumulativeDistribution(
        address network
    ) external view returns (CumulativeDistribution memory);

    /**
     * @notice Get the last total amount for a network and token
     * @param network The network address
     * @param token The token address
     * @return The last total amount
     */
    function lastTotalAmount(
        address network,
        address token
    ) external view returns (uint256);

    /**
     * @notice Check if a cumulative distribution root exists for a network
     * @param network The network address
     * @param root The merkle root to check
     * @return True if the root exists
     */
    function isCumulativeDistributionRoot(
        address network,
        bytes32 root
    ) external view returns (bool);

    /**
     * @notice Get the balance for a network and token
     * @param network The network address
     * @param token The token address
     * @return amount The balance amount
     */
    function balance(
        address network,
        address token
    ) external view returns (uint256 amount);

    /**
     * @notice Get the claimed amount for a rewardee
     * @param network The network address
     * @param token The token address
     * @param rewardee The rewardee address
     * @param rewardeeType The rewardee type
     * @return amount The claimed amount
     */
    function claimed(
        address network,
        address token,
        address rewardee,
        uint256 rewardeeType
    ) external view returns (uint256 amount);

    /**
     * @notice Get the rewarder for a network
     * @param network The network address
     * @return The rewarder address
     */
    function rewarder(
        address network
    ) external view returns (address);

    /**
     * @notice Get the protocol address
     * @return The protocol address
     */
    function protocol() external view returns (address);

    /**
     * @notice Distribute cumulative merkle rewards
     * @param network The network address
     * @param cumulativeDistribution The cumulative distribution data
     * @param totalAmounts Array of total amounts per token and chainId
     * @param ownerSignature Signature by the contract owner over the payload
     * @param rewarderSignature Signature by the network rewarder over the payload
     */
    function distributeCumulativeMerkleRewards(
        address network,
        CumulativeDistribution calldata cumulativeDistribution,
        TokenAmount[] calldata totalAmounts,
        bytes calldata ownerSignature,
        bytes calldata rewarderSignature
    ) external;

    /**
     * @notice Deposit cumulative merkle rewards
     * @param network The network address
     * @param token The token address
     * @param amount The amount to deposit
     */
    function depositCumulativeMerkleRewards(
        address network,
        address token,
        uint256 amount
    ) external;

    /**
     * @notice Withdraw cumulative merkle rewards (only rewarder)
     * @param recipient The recipient address
     * @param network The network address
     * @param token The token address
     * @param amount The amount to withdraw
     */
    function withdrawCumulativeMerkleRewards(
        address recipient,
        address network,
        address token,
        uint256 amount
    ) external;

    /**
     * @notice Claim cumulative merkle rewards
     * @param recipient The recipient address
     * @param network The network address
     * @param leaf The distribution leaf data
     * @param proof The merkle proof
     * @param merkleRoot The merkle root
     */
    function claimCumulativeMerkleRewards(
        address recipient,
        address network,
        CumulativeDistributionLeaf calldata leaf,
        bytes32[] calldata proof,
        bytes32 merkleRoot
    ) external;

    /**
     * @notice Set rewarder for a network
     * @param rewarder The rewarder address
     */
    function setRewarder(
        address rewarder
    ) external;

    /**
     * @notice Claim rewards via the cumulative merkle path
     * @param recipient The recipient address
     * @param token The token address
     * @param data The encoded claim data
     */
    function claimRewards(
        address recipient,
        address token,
        bytes calldata data
    ) external;

    /**
     * @notice Set the protocol address
     * @param protocol The protocol address
     */
    function setProtocol(
        address protocol
    ) external;
}
