// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Multicall} from "@openzeppelin/contracts/utils/Multicall.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IRewards} from "../../interfaces/rewardsV2/IRewards.sol";
import {IStakerRewards} from "../../interfaces/stakerRewards/IStakerRewards.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Time} from "@openzeppelin/contracts/utils/types/Time.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

/**
 * @title Rewards
 * @notice Manages reward distribution and claiming for networks using Merkle proofs
 * @dev This contract handles cumulative distributions, balance tracking, and reward claiming
 */
contract Rewards is Multicall, IRewards {
    using EnumerableMap for EnumerableMap.AddressToBytes32Map;
    using SafeERC20 for IERC20;

    // State variables
    mapping(address network => CumulativeDistribution) internal cumulativeDistributions;
    mapping(address network => mapping(bytes32 root => CumulativeDistribution value)) public
        cumulativeDistributionsByRoot;
    mapping(address network => mapping(address token => uint256 amount)) public balances;
    mapping(address network => mapping(address token => mapping(address rewardee => uint256 amount))) public claimed;
    mapping(address network => address value) public rewarder;

    mapping(address network => EnumerableMap.AddressToBytes32Map) internal distributionData;

    // Modifiers
    modifier onlyNetworkRewarder(
        address network
    ) {
        if (rewarder[network] != msg.sender) {
            revert NotNetworkRewarder();
        }
        _;
    }

    // Constructor
    // (No constructor in this contract)

    // External functions
    /**
     * @inheritdoc IRewards
     */
    function claimable(address token, address rewardee, bytes calldata data) external view returns (uint256) {
        uint256 amount = abi.decode(data, (uint256));
        uint256 claimedAmount = claimed[msg.sender][token][rewardee];

        if (amount <= claimedAmount) {
            return 0;
        }

        return amount - claimedAmount;
    }

    /**
     * @inheritdoc IRewards
     */
    function getDistributionData(
        address network
    ) external view returns (DistributionData[] memory) {
        EnumerableMap.AddressToBytes32Map storage networkDistributionData = distributionData[network];
        uint256 length = networkDistributionData.length();
        DistributionData[] memory result = new DistributionData[](length);

        for (uint256 i = 0; i < length; i++) {
            (address token, bytes32 data) = networkDistributionData.at(i);
            result[i] = DistributionData({token: token, data: data});
        }

        return result;
    }

    /**
     * @inheritdoc IRewards
     */
    function distributeRewards(
        address network,
        address token,
        uint256 amount,
        bytes calldata data
    ) external onlyNetworkRewarder(network) {
        CumulativeDistribution memory cumulativeDistribution = abi.decode(data, (CumulativeDistribution));
        TopUp[] memory topUps = new TopUp[](1);
        topUps[0] = TopUp({token: token, amount: amount});
        updateCumulativeDistribution(network, cumulativeDistribution, topUps);
    }

    /**
     * @inheritdoc IRewards
     */
    function topUpBalance(address network, TopUp memory topUp) external {
        IERC20(topUp.token).safeTransferFrom(msg.sender, address(this), topUp.amount);
        balances[network][topUp.token] += topUp.amount;
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
    ) external {
        if (!isCumulativeDistributionRoot(network, merkleRoot)) {
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
    ) external {
        bytes32 root = cumulativeDistributions[network].merkleRoot;
        _claimRewards(network, rewardee, leaf, proof, root);
    }

    /**
     * @inheritdoc IRewards
     */
    function addDistributionData(address token, bytes32 data) external {
        distributionData[msg.sender].set(token, data);
    }

    /**
     * @inheritdoc IRewards
     */
    function removeDistributionData(
        address token
    ) external {
        distributionData[msg.sender].remove(token);
    }

    /**
     * @inheritdoc IRewards
     */
    function setRewarder(
        address newRewarder
    ) external {
        rewarder[msg.sender] = newRewarder;
    }

    /**
     * @inheritdoc IRewards
     */
    function version() external pure returns (uint64) {
        return 2;
    }

    // Public functions
    /**
     * @inheritdoc IRewards
     */
    function updateCumulativeDistribution(
        address network,
        CumulativeDistribution memory cumulativeDistribution,
        TopUp[] memory topUps
    ) public onlyNetworkRewarder(network) {
        if (cumulativeDistribution.timestamp < cumulativeDistributions[network].timestamp) {
            revert InvalidTimestamp();
        }

        cumulativeDistributions[network] = cumulativeDistribution;
        cumulativeDistributionsByRoot[network][cumulativeDistribution.merkleRoot] = cumulativeDistribution;

        for (uint256 i = 0; i < topUps.length; i++) {
            TopUp memory topUp = topUps[i];
            IERC20(topUp.token).safeTransferFrom(msg.sender, address(this), topUp.amount);
            balances[network][topUp.token] += topUp.amount;
        }
    }

    /**
     * @inheritdoc IRewards
     */
    function isCumulativeDistributionRoot(address network, bytes32 merkleRoot) public view returns (bool) {
        return cumulativeDistributionsByRoot[network][merkleRoot].timestamp > 0;
    }

    // Internal functions
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

        bytes32 leafHash = keccak256(bytes.concat(keccak256(abi.encode(leaf.token, leaf.rewardee, leaf.amount))));

        if (!MerkleProof.verifyCalldata(proof, root, leafHash)) {
            revert InvalidProof();
        }

        uint256 claimedAmount = claimed[network][leaf.token][msg.sender];
        if (leaf.amount <= claimedAmount) {
            revert InsufficientClaimableAmount();
        }

        uint256 networkBalance = balances[network][leaf.token];
        if (leaf.amount > networkBalance) {
            revert InsufficientBalance();
        }

        uint256 claimableAmount = leaf.amount - claimedAmount;
        claimed[network][leaf.token][msg.sender] = leaf.amount;
        balances[network][leaf.token] = networkBalance - claimableAmount;

        IERC20(leaf.token).safeTransfer(rewardee, claimableAmount);

        emit ClaimRewards(network, leaf.token, msg.sender, rewardee, claimableAmount);
    }

    // Private functions
    // (No private functions in this contract)
}
