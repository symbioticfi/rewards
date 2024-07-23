// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IDefaultOperatorRewards {
    error InsufficientBalance();
    error InsufficientTotalClaimable();
    error InsufficientTransfer();
    error InvalidProof();
    error NotNetworkMiddleware();
    error RootNotSet();

    /**
     * @notice Emitted when rewards are distributed by a particular network using a given token by providing a Merkle root.
     * @param network address of the network that distributed rewards
     * @param token address of the token
     * @param amount amount of tokens sent to the contract
     * @param root Merkle root of the rewards distribution
     * @dev The Merkle tree's leaves must represent an account and a claimable amount (the total amount of the reward tokens for the whole time).
     */
    event DistributeRewards(address indexed network, address indexed token, uint256 amount, bytes32 root);

    /**
     * @notice Emitted when a reward is claimed by a particular account for a particular network using a given token.
     * @param recipient address of the reward's recipient
     * @param network address of the network
     * @param token address of the token
     * @param claimer address of the reward's claimer
     * @param amount amount of tokens claimed
     */
    event ClaimRewards(
        address recipient, address indexed network, address indexed token, address indexed claimer, uint256 amount
    );

    /**
     * @notice Get the network middleware service's address.
     * @return address of the network middleware service
     */
    function NETWORK_MIDDLEWARE_SERVICE() external view returns (address);

    /**
     * @notice Get a Merkle root of a reward distribution for a particular network and token.
     * @param network address of the network
     * @param token address of the token
     * @return Merkle root of the reward distribution
     */
    function root(address network, address token) external view returns (bytes32);

    /**
     * @notice Get an amount of tokens that can be claimed for a particular network.
     * @param network address of the network
     * @param token address of the token
     * @return amount of tokens that can be claimed
     */
    function balance(address network, address token) external view returns (uint256);

    /**
     * @notice Get a claimed amount of a reward for a particular account, network, and token.
     * @param network address of the network
     * @param token address of the token
     * @param account address of the claimer
     * @return claimed amount of tokens
     */
    function claimed(address network, address token, address account) external view returns (uint256);

    /**
     * @notice Distribute rewards by a particular network using a given token by providing a Merkle root.
     * @param network address of the network
     * @param token address of the token
     * @param amount amount of tokens to send to the contract
     * @param root Merkle root of the reward distribution
     */
    function distributeRewards(address network, address token, uint256 amount, bytes32 root) external;

    /**
     * @notice Claim rewards for a particular network and token by providing a Merkle proof.
     * @param recipient address of the reward's recipient
     * @param network address of the network
     * @param token address of the token
     * @param totalClaimable total amount of the reward tokens for the whole time
     * @param proof Merkle proof of the reward distribution
     * @return amount amount of tokens claimed
     */
    function claimRewards(
        address recipient,
        address network,
        address token,
        uint256 totalClaimable,
        bytes32[] calldata proof
    ) external returns (uint256 amount);
}
