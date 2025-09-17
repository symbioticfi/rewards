// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IRewards} from "../../interfaces/rewardsV2/IRewards.sol";
import {IStakerRewardsClaim} from "../../interfaces/stakerRewards/IStakerRewardsClaim.sol";

import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
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
        uint256 length = _distributionData[network].length();
        result = new DistributionData[](length);
        for (uint256 i; i < length; ++i) {
            (address token, bytes32 data) = _distributionData[network].at(i);
            result[i] = DistributionData({token: token, data: data});
        }
    }

    /**
     * @inheritdoc IRewards
     */
    function updateCumulativeDistribution(
        address network,
        CumulativeDistribution calldata cumulativeDistribution,
        TopUp[] calldata topUps
    ) public {
        if (rewarder[network] != msg.sender) {
            revert NotNetworkRewarder();
        }

        if (cumulativeDistribution.merkleRoot == bytes32(0)) {
            revert InvalidMerkleRoot();
        }
        if (
            cumulativeDistribution.timestamp >= block.timestamp
                || cumulativeDistribution.timestamp < cumulativeDistributions[network].timestamp
        ) {
            revert InvalidTimestamp();
        }

        for (uint256 i; i < topUps.length; ++i) {
            if (i > 0 && topUps[i].token <= topUps[i - 1].token) {
                revert DuplicatedOrUnsortedTopUp();
            }
            topUpBalance(network, topUps[i]);
        }

        cumulativeDistributions[network] = cumulativeDistribution;
        isCumulativeDistributionRoot[network][cumulativeDistribution.merkleRoot] = true;
        cumulativeDistributionDaData[network][cumulativeDistribution.merkleRoot] = cumulativeDistribution.daData;

        emit UpdateCumulativeDistribution(network, cumulativeDistribution);
    }

    /**
     * @inheritdoc IRewards
     */
    function topUpBalance(address network, TopUp calldata topUp) public {
        uint256 balanceBefore = IERC20(topUp.token).balanceOf(address(this));
        IERC20(topUp.token).safeTransferFrom(msg.sender, address(this), topUp.amount);
        uint256 balanceAfter = IERC20(topUp.token).balanceOf(address(this));
        uint256 actualAmount = balanceAfter - balanceBefore;
        balances[network][topUp.token] += actualAmount;
        emit TopUpBalance(network, topUp.token, actualAmount);
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
            proof.length := calldataload(add(data.offset, 0x100))
            proof.offset := add(data.offset, 0x120)
        }
        if (token != leaf.token) {
            revert InvalidClaimParams();
        }
        claim(recipient, network, leaf, proof, merkleRoot);
    }

    /**
     * @inheritdoc IRewards
     */
    function claim(
        address recipient,
        address network,
        CumulativeDistributionLeaf calldata leaf,
        bytes32[] calldata proof,
        bytes32 merkleRoot
    ) public {
        if (!isCumulativeDistributionRoot[network][merkleRoot]) {
            revert RootNotSet();
        }

        // Check that current chain ID matches the leaf chain ID
        if (block.chainid != leaf.chainId) {
            revert InvalidChainId();
        }

        if (
            !MerkleProof.verifyCalldata(
                proof, merkleRoot, keccak256(bytes.concat(keccak256(abi.encode(msg.sender, leaf))))
            )
        ) {
            revert InvalidProof();
        }

        uint256 claimableAmount = leaf.amount.saturatingSub(claimed[network][leaf.token][msg.sender][leaf.rewardeeType]);
        if (claimableAmount == 0) {
            revert InsufficientClaimableAmount();
        }

        balances[network][leaf.token] -= claimableAmount;
        claimed[network][leaf.token][msg.sender][leaf.rewardeeType] = leaf.amount;

        IERC20(leaf.token).safeTransfer(recipient, claimableAmount);
        emit ClaimRewards(network, leaf.token, msg.sender, recipient, claimableAmount);
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
}
