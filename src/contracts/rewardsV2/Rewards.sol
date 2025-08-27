// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IRewards} from "../../interfaces/rewardsV2/IRewards.sol";
import {IStakerRewards} from "../../interfaces/stakerRewards/IStakerRewards.sol";

import {StaticDelegateCallable} from "@symbioticfi/core/src/contracts/common/StaticDelegateCallable.sol";

import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Time} from "@openzeppelin/contracts/utils/types/Time.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Rewards
 * @notice Manages reward distribution and claiming for networks using Merkle proofs
 * @dev This contract handles cumulative distributions, balance tracking, and reward claiming
 */
contract Rewards is Multicall, IRewards, StaticDelegateCallable {
    using EnumerableMap for EnumerableMap.AddressToBytes32Map;
    using SafeERC20 for IERC20;
    using Math for uint256;

    uint64 public constant version = 2;

    /* STATE VARIABLES */

    /**
     * @inheritdoc IRewards
     */
    mapping(address network => CumulativeDistribution) public cumulativeDistributions;

    /**
     * @inheritdoc IRewards
     */
    mapping(address network => mapping(bytes32 root => bool value)) public isCumulativeDistributionRoot;

    /**
     * @inheritdoc IRewards
     */
    mapping(address network => mapping(bytes32 root => bytes value)) public cumulativeDistributionDaData;

    /**
     * @inheritdoc IRewards
     */
    mapping(address network => mapping(address token => uint256 amount)) public balances;

    /**
     * @inheritdoc IRewards
     */
    mapping(
        address network
            => mapping(address token => mapping(address rewardee => mapping(uint256 rewardeeType => uint256 amount)))
    ) public claimed;

    /**
     * @inheritdoc IRewards
     */
    mapping(address network => address value) public rewarder;

    mapping(address network => EnumerableMap.AddressToBytes32Map) internal _distributionData;

    /* PUBLIC FUNCTIONS */

    /**
     * @inheritdoc IRewards
     */
    function claimable(address token, address rewardee, bytes calldata data) public view returns (uint256) {
        (address network, CumulativeDistributionLeaf memory leaf, bytes32[] memory proof) =
            abi.decode(data, (address, CumulativeDistributionLeaf, bytes32[]));

        // Check that current chain ID matches the leaf chain ID
        if (block.chainid != leaf.chainId) {
            return 0;
        }

        if (
            !MerkleProof.verify(
                proof,
                cumulativeDistributions[network].merkleRoot,
                keccak256(
                    bytes.concat(
                        keccak256(
                            abi.encode(
                                leaf.token,
                                leaf.rewardee,
                                leaf.amount,
                                leaf.rewardeeType,
                                leaf.rewardeeDataHash,
                                leaf.chainId
                            )
                        )
                    )
                )
            )
        ) {
            return 0;
        }

        uint256 claimedAmount = claimed[network][leaf.token][leaf.rewardee][leaf.rewardeeType];
        if (leaf.amount <= claimedAmount) {
            return 0;
        }
        return leaf.amount - claimedAmount;
    }

    /**
     * @inheritdoc IRewards
     */
    function getDistributionData(
        address network
    ) public view returns (DistributionData[] memory result) {
        EnumerableMap.AddressToBytes32Map storage networkDistributionData = _distributionData[network];
        uint256 length = networkDistributionData.length();
        result = new DistributionData[](length);

        for (uint256 i; i < length; ++i) {
            (address token, bytes32 data) = networkDistributionData.at(i);
            result[i] = DistributionData({token: token, data: data});
        }
    }

    /**
     * @inheritdoc IRewards
     */
    function distributeRewards(address network, address token, uint256 amount, bytes calldata data) public {
        CumulativeDistribution memory cumulativeDistribution = abi.decode(data, (CumulativeDistribution));
        TopUp[] memory topUps = new TopUp[](1);
        topUps[0] = TopUp({token: token, amount: amount});
        updateCumulativeDistribution(network, cumulativeDistribution, topUps);
    }

    /**
     * @inheritdoc IRewards
     */
    function topUpBalance(address network, TopUp memory topUp) public {
        IERC20(topUp.token).safeTransferFrom(msg.sender, address(this), topUp.amount);
        balances[network][topUp.token] += topUp.amount;
        emit TopUpBalance(network, topUp.token, topUp.amount);
    }

    /**
     * @inheritdoc IRewards
     */
    function claimByRoot(
        address network,
        address rewardee,
        CumulativeDistributionLeaf calldata leaf,
        bytes32[] calldata proof,
        bytes32 merkleRoot
    ) public {
        if (!isCumulativeDistributionRoot[network][merkleRoot]) {
            revert RootNotSet();
        }
        _claimRewards(network, rewardee, leaf, proof, merkleRoot);
    }

    /**
     * @inheritdoc IRewards
     */
    function claim(
        address network,
        address rewardee,
        CumulativeDistributionLeaf calldata leaf,
        bytes32[] calldata proof
    ) public {
        _claimRewards(network, rewardee, leaf, proof, cumulativeDistributions[network].merkleRoot);
    }

    /**
     * @inheritdoc IRewards
     */
    function addDistributionData(address token, bytes32 data) public {
        _distributionData[msg.sender].set(token, data);
    }

    /**
     * @inheritdoc IRewards
     */
    function removeDistributionData(
        address token
    ) public {
        _distributionData[msg.sender].remove(token);
    }

    /**
     * @inheritdoc IRewards
     */
    function setRewarder(
        address newRewarder
    ) public {
        rewarder[msg.sender] = newRewarder;
    }

    /**
     * @inheritdoc IRewards
     */
    function updateCumulativeDistribution(
        address network,
        CumulativeDistribution memory cumulativeDistribution,
        TopUp[] memory topUps
    ) public {
        if (rewarder[network] != msg.sender) {
            revert NotNetworkRewarder();
        }

        if (cumulativeDistribution.timestamp < cumulativeDistributions[network].timestamp) {
            revert InvalidTimestamp();
        }

        cumulativeDistributions[network] = cumulativeDistribution;
        isCumulativeDistributionRoot[network][cumulativeDistribution.merkleRoot] = true;
        cumulativeDistributionDaData[network][cumulativeDistribution.merkleRoot] = cumulativeDistribution.daData;

        for (uint256 i; i < topUps.length; ++i) {
            TopUp memory topUp = topUps[i];
            IERC20(topUp.token).safeTransferFrom(msg.sender, address(this), topUp.amount);
            balances[network][topUp.token] += topUp.amount;
        }
    }

    /* INTERNAL FUNCTIONS */

    function _claimRewards(
        address network,
        address rewardee,
        CumulativeDistributionLeaf calldata leaf,
        bytes32[] calldata proof,
        bytes32 root
    ) internal {
        if (root == bytes32(0)) {
            revert RootNotSet();
        }

        // Check that current chain ID matches the leaf chain ID
        if (block.chainid != leaf.chainId) {
            revert InvalidChainId();
        }

        if (
            !MerkleProof.verifyCalldata(
                proof,
                root,
                keccak256(
                    bytes.concat(
                        keccak256(
                            abi.encode(
                                leaf.token,
                                leaf.rewardee,
                                leaf.amount,
                                leaf.rewardeeType,
                                leaf.rewardeeDataHash,
                                leaf.chainId
                            )
                        )
                    )
                )
            )
        ) {
            revert InvalidProof();
        }

        uint256 claimedAmount = claimed[network][leaf.token][msg.sender][leaf.rewardeeType];
        uint256 claimableAmount = leaf.amount.saturatingSub(claimedAmount);
        if (claimableAmount == 0) {
            revert InsufficientClaimableAmount();
        }

        uint256 networkBalance = balances[network][leaf.token];

        if (claimableAmount > networkBalance) {
            revert InsufficientBalance();
        }

        claimed[network][leaf.token][msg.sender][leaf.rewardeeType] = leaf.amount;
        balances[network][leaf.token] = networkBalance - claimableAmount;

        IERC20(leaf.token).safeTransfer(rewardee, claimableAmount);
        emit ClaimRewards(network, leaf.token, msg.sender, rewardee, claimableAmount);
    }
}
