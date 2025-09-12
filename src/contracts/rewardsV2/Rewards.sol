// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IRewards} from "../../interfaces/rewardsV2/IRewards.sol";
import {IStakerRewardsClaim} from "../../interfaces/stakerRewards/IStakerRewardsClaim.sol";

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
contract Rewards is Multicall, IRewards, IStakerRewardsClaim {
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
        uint256 balanceBefore = IERC20(topUp.token).balanceOf(address(this));
        IERC20(topUp.token).safeTransferFrom(msg.sender, address(this), topUp.amount);
        uint256 balanceAfter = IERC20(topUp.token).balanceOf(address(this));
        uint256 actualAmount = balanceAfter - balanceBefore;
        balances[network][topUp.token] += actualAmount;
        emit TopUpBalance(network, topUp.token, actualAmount);
    }

    /**
     * @inheritdoc IRewards
     */
    function claimByRoot(
        address network,
        CumulativeDistributionLeaf calldata leaf,
        bytes32[] calldata proof,
        bytes32 merkleRoot
    ) public {
        if (!isCumulativeDistributionRoot[network][merkleRoot]) {
            revert RootNotSet();
        }
        _claimRewards(network, leaf, proof, merkleRoot);
    }

    /**
     * @inheritdoc IRewards
     */
    function claim(address network, CumulativeDistributionLeaf calldata leaf, bytes32[] calldata proof) public {
        _claimRewards(network, leaf, proof, cumulativeDistributions[network].merkleRoot);
    }

    /**
     * @inheritdoc IStakerRewardsClaim
     */
    function claimRewards(address recipient, address token, bytes calldata data) external override {
        address network;
        bytes32 merkleRoot;
        CumulativeDistributionLeaf calldata leaf;
        bytes32[] calldata proof;
        assembly {
            network := calldataload(data.offset)
            merkleRoot := calldataload(add(data.offset, 0x20))
            leaf := add(data.offset, 0x40)
            proof.length := calldataload(add(data.offset, 0x120))
            proof.offset := add(data.offset, 0x140)
        }
        if (recipient != leaf.rewardee || token != leaf.token) {
            revert IvalidClaimParams();
        }
        claimByRoot(network, leaf, proof, merkleRoot);
    }

    /**
     * @inheritdoc IRewards
     */
    function addDistributionData(address token, bytes32 data) public {
        _distributionData[msg.sender].set(token, data);
        emit AddDistributionData(msg.sender, token, data);
    }

    /**
     * @inheritdoc IRewards
     */
    function removeDistributionData(
        address token
    ) public {
        _distributionData[msg.sender].remove(token);
        emit RemoveDistributionData(msg.sender, token);
    }

    /**
     * @inheritdoc IRewards
     */
    function setRewarder(
        address newRewarder
    ) public {
        rewarder[msg.sender] = newRewarder;
        emit SetRewarder(msg.sender, newRewarder);
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

        for (uint256 i; i < topUps.length; ++i) {
            if (i > 0 && topUps[i].token <= topUps[i - 1].token) {
                revert DuplicatedOrUnsortedTopUp();
            }
            TopUp memory topUp = topUps[i];
            topUpBalance(network, topUp);
        }

        cumulativeDistributions[network] = cumulativeDistribution;
        isCumulativeDistributionRoot[network][cumulativeDistribution.merkleRoot] = true;
        cumulativeDistributionDaData[network][cumulativeDistribution.merkleRoot] = cumulativeDistribution.daData;

        emit UpdateCumulativeDistribution(network, cumulativeDistribution);
    }

    /* INTERNAL FUNCTIONS */

    function _claimRewards(
        address network,
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
                                leaf.chainId,
                                leaf.token,
                                leaf.rewardee,
                                leaf.rewardeeType,
                                leaf.amount,
                                leaf.rewardeeDataHash
                            )
                        )
                    )
                )
            )
        ) {
            revert InvalidProof();
        }

        uint256 claimedAmount = claimed[network][leaf.token][leaf.rewardee][leaf.rewardeeType];
        uint256 claimableAmount = leaf.amount.saturatingSub(claimedAmount);
        if (claimableAmount == 0) {
            revert InsufficientClaimableAmount();
        }

        balances[network][leaf.token] -= claimableAmount;
        claimed[network][leaf.token][leaf.rewardee][leaf.rewardeeType] = leaf.amount;

        IERC20(leaf.token).safeTransfer(leaf.rewardee, claimableAmount);
        emit ClaimRewards(network, leaf.token, msg.sender, leaf.rewardee, claimableAmount);
    }
}
