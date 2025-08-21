    // SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IRewards {
    error InsufficientBalance();
    error InsufficientClaimableAmount();
    error InvalidProof();
    error NotNetworkRewarder();
    error RootNotSet();
    error InvalidTimestamp();

    event ClaimRewards(
        address indexed network, address indexed token, address indexed claimer, address rewardee, uint256 amount
    );

    struct CumulativeDistribution {
        uint48 timestamp;
        bytes32 merkleRoot;
        bytes daData;
    }

    struct CumulativeDistributionLeaf {
        address token;
        address rewardee;
        uint256 amount;
    }

    struct TopUp {
        address token;
        uint256 amount;
    }

    struct DistributionData {
        address token;
        bytes32 data;
    }

    function claimable(address token, address rewardee, bytes calldata data) external view returns (uint256);

    function isCumulativeDistributionRoot(address network, bytes32 merkleRoot) external view returns (bool);

    function getDistributionData(
        address network
    ) external view returns (DistributionData[] memory);

    function updateCumulativeDistribution(
        address network,
        CumulativeDistribution memory cumulativeDistribution,
        TopUp[] memory topUps
    ) external;

    function distributeRewards(address network, address token, uint256 amount, bytes calldata data) external;

    function topUpBalance(address network, TopUp memory topUp) external;

    function claimByRoot(
        address network,
        address rewardee,
        CumulativeDistributionLeaf calldata leaf,
        bytes32[] calldata proof,
        bytes32 merkleRoot
    ) external;

    function claim(
        address network,
        address rewardee,
        CumulativeDistributionLeaf calldata leaf,
        bytes32[] calldata proof
    ) external;


    function addDistributionData(address token, bytes32 data) external;


    function removeDistributionData(
        address token
    ) external;


    function setRewarder(
        address rewarder_
    ) external;

    function version() external view returns (uint64);
}
