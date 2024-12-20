// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IDefaultOperatorRewards} from "../../interfaces/defaultOperatorRewards/IDefaultOperatorRewards.sol";
import {INetworkMiddlewareService} from "@symbioticfi/core/src/interfaces/service/INetworkMiddlewareService.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DefaultOperatorRewards is ReentrancyGuardUpgradeable, IDefaultOperatorRewards {
    using SafeERC20 for IERC20;

    /**
     * @inheritdoc IDefaultOperatorRewards
     */
    address public immutable NETWORK_MIDDLEWARE_SERVICE;

    // Mapping to store Merkle roots for each network and token
    mapping(address network => mapping(address token => bytes32 value)) public root;

    // Mapping to track total balance of rewards for each network and token
    mapping(address network => mapping(address token => uint256 amount)) public balance;

    // Mapping to track claimed rewards for each account
    mapping(address network => mapping(address token => mapping(address account => uint256 amount))) public claimed;

    constructor(
        address networkMiddlewareService
    ) {
        _disableInitializers();

        NETWORK_MIDDLEWARE_SERVICE = networkMiddlewareService;
    }

    function initialize() public initializer {
        __ReentrancyGuard_init();
    }

    /**
     * @inheritdoc IDefaultOperatorRewards
     */
    function distributeRewards(address network, address token, uint256 amount, bytes32 root_) external nonReentrant {
        // Ensure that only the authorized middleware can call this function
        if (INetworkMiddlewareService(NETWORK_MIDDLEWARE_SERVICE).middleware(network) != msg.sender) {
            revert NotNetworkMiddleware();
        }

        // Transfer tokens to the contract
        if (amount > 0) {
            uint256 balanceBefore = IERC20(token).balanceOf(address(this));
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
            amount = IERC20(token).balanceOf(address(this)) - balanceBefore;

            // Check if any tokens were actually transferred
            if (amount == 0) {
                revert InsufficientTransfer();
            }

            balance[network][token] += amount; // Update balance
        }

        root[network][token] = root_; // Set the new Merkle root

        emit DistributeRewards(network, token, amount, root_);
    }

    /**
     * @inheritdoc IDefaultOperatorRewards
     */
    function claimRewards(
        address recipient,
        address network,
        address token,
        uint256 totalClaimable,
        bytes32[] calldata proof
    ) external nonReentrant returns (uint256 amount) {
        bytes32 root_ = root[network][token];
        
        // Ensure that a Merkle root is set for the specified network and token
        if (root_ == bytes32(0)) {
            revert RootNotSet();
        }

        // Verify the proof against the Merkle root
        if (
            !MerkleProof.verifyCalldata(
                proof, root_, keccak256(bytes.concat(keccak256(abi.encode(msg.sender, totalClaimable))))
            )
        ) {
            revert InvalidProof();
        }

        uint256 claimed_ = claimed[network][token][msg.sender];
        
        // Ensure that the total claimable amount is greater than what has already been claimed
        if (totalClaimable <= claimed_) {
            revert InsufficientTotalClaimable();
        }

        amount = totalClaimable - claimed_; // Calculate the amount to claim

        uint256 balance_ = balance[network][token];
        
        // Ensure that there are sufficient funds to cover the claim
        if (amount > balance_) {
            revert InsufficientBalance();
        }

        balance[network][token] = balance_ - amount; // Deduct the claimed amount from the balance

        claimed[network][token][msg.sender] = totalClaimable; // Update the claimed amount for the user

        IERC20(token).safeTransfer(recipient, amount); // Transfer the tokens to the recipient

        emit ClaimRewards(recipient, network, token, msg.sender, amount);
    }
}
