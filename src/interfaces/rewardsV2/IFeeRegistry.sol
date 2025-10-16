// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title IFeeRegistry
 * @notice Manages fee settings for operators and curators with historical tracking
 * @dev Defines fee management for both operators and curators with granular control at vault
 * and network levels. Fees are checkpointed with timestamps to support historical queries.
 */
interface IFeeRegistry {
    /* ERRORS */

    error FeeTooHigh();
    error NotCurator();
    error CuratorRegistryIsZero();


    /* STRUCTS */

    struct ProtocolFeesInitParams {
        address owner;
        RewardsTypeFee[] fees;
    }

    struct RewardsTypeFee {
        bytes32 id;
        uint256 fee;
    }

    /* EVENTS */

    /**
     * @notice Emitted when operator fee is set for a vault
     * @param vault The vault address
     * @param fee The fee amount
     */
    event SetOperatorsFee(address indexed vault, uint256 fee);

    /**
     * @notice Emitted when operator network fee is set for a vault
     * @param vault The vault address
     * @param network The network address
     * @param enable Whether the fee is enabled
     * @param fee The fee amount
     */
    event SetOperatorsNetworkFee(address indexed vault, address indexed network, bool enable, uint256 fee);

    /**
     * @notice Emitted when curator fee is set for a vault
     * @param vault The vault address
     * @param fee The fee amount
     */
    event SetCuratorFee(address indexed vault, uint256 fee);

    /**
     * @notice Emitted when curator network fee is set for a vault
     * @param vault The vault address
     * @param network The network address
     * @param enable Whether the fee is enabled
     * @param fee The fee amount
     */
    event SetCuratorNetworkFee(address indexed vault, address indexed network, bool enable, uint256 fee);

    /**
     * @notice Emitted when protocol fee is set
     * @param id The id of the protocol
     * @param enable Whether the fee is enabled
     * @param fee The fee amount
     */
    event SetProtocolFee(bytes32 indexed id, bool enable, uint256 fee);

    /* FUNCTIONS */

    /**
     * @notice Get the maximum fee value
     * @return The maximum fee value
     */
    function MAX_FEE() external view returns (uint256);

    /**
     * @notice Get operator fee for a vault and network at a specific timestamp
     * @param vault The vault address
     * @param network The network address
     * @param timestamp The timestamp to query
     * @return fee The fee amount
     */
    function getOperatorsFeeAt(
        address vault,
        address network,
        uint48 timestamp
    ) external view returns (uint256 fee);

    /**
     * @notice Get operator fee for a vault and network
     * @param vault The vault address
     * @param network The network address
     * @return fee The fee amount
     */
    function getOperatorsFee(
        address vault,
        address network
    ) external view returns (uint256 fee);

    /**
     * @notice Get operator network fee at a specific timestamp
     * @param vault The vault address
     * @param network The network address
     * @param timestamp The timestamp to query
     * @return isEnabled Whether the fee is enabled
     * @return fee The fee amount
     */
    function getOperatorsNetworkFeeAt(
        address vault,
        address network,
        uint48 timestamp
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get operator network fee
     * @param vault The vault address
     * @param network The network address
     * @return isEnabled Whether the fee is enabled
     * @return fee The fee amount
     */
    function getOperatorsNetworkFee(
        address vault,
        address network
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get operator default fee at a specific timestamp
     * @param vault The vault address
     * @param timestamp The timestamp to query
     * @return fee The fee amount
     */
    function getOperatorsDefaultFeeAt(
        address vault,
        uint48 timestamp
    ) external view returns (uint256 fee);

    /**
     * @notice Get operator default fee
     * @param vault The vault address
     * @return fee The fee amount
     */
    function getOperatorsDefaultFee(
        address vault
    ) external view returns (uint256 fee);

    /**
     * @notice Get curator fee at a specific timestamp
     * @param vault The vault address
     * @param timestamp The timestamp to query
     * @return fee The fee amount
     */
    function getCuratorFeeAt(
        address vault,
        address network,
        uint48 timestamp
    ) external view returns (uint256 fee);

    /**
     * @notice Get curator fee
     * @param vault The vault address
     * @return fee The fee amount
     */
    function getCuratorFee(
        address vault,
        address network
    ) external view returns (uint256 fee);

    /**
     * @notice Get curator network fee at a specific timestamp
     * @param vault The vault address
     * @param network The network address
     * @param timestamp The timestamp to query
     * @return isEnabled Whether the fee is enabled
     * @return fee The fee amount
     */
    function getCuratorNetworkFeeAt(
        address vault,
        address network,
        uint48 timestamp
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get curator network fee
     * @param vault The vault address
     * @param network The network address
     * @return isEnabled Whether the fee is enabled
     * @return fee The fee amount
     */
    function getCuratorNetworkFee(
        address vault,
        address network
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get curator default fee at a specific timestamp
     * @param vault The vault address
     * @param timestamp The timestamp to query
     * @return fee The fee amount
     */
    function getCuratorDefaultFeeAt(
        address vault,
        uint48 timestamp
    ) external view returns (uint256 fee);

    /**
     * @notice Get curator default fee
     * @param vault The vault address
     * @return fee The fee amount
     */
    function getCuratorDefaultFee(
        address vault
    ) external view returns (uint256 fee);

    /**
     * @notice Get protocol fee
     * @param id The id of the protocol
     * @return isEnabled Whether the fee is enabled
     * @return fee The fee amount
     */
    function getProtocolFee(
        bytes32 id
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Set operator fee for a vault (only curator)
     * @param vault The vault address
     * @param fee The fee amount
     */
    function setOperatorsFee(
        address vault,
        uint256 fee
    ) external;

    /**
     * @notice Set operator network fee for a vault (only curator)
     * @param vault The vault address
     * @param network The network address
     * @param enable Whether the fee is enabled
     * @param fee The fee amount
     */
    function setOperatorsNetworkFee(
        address vault,
        address network,
        bool enable,
        uint256 fee
    ) external;

    /**
     * @notice Set curator fee for a vault (only curator)
     * @param vault The vault address
     * @param fee The fee amount
     */
    function setCuratorFee(
        address vault,
        uint256 fee
    ) external;

    /**
     * @notice Set curator network fee for a vault (only curator)
     * @param vault The vault address
     * @param network The network address
     * @param enable Whether the fee is enabled
     * @param fee The fee amount
     */
    function setCuratorNetworkFee(
        address vault,
        address network,
        bool enable,
        uint256 fee
    ) external;

    /**
     * @notice Set protocol fee
     * @param id The id of the protocol
     * @param enable Whether the fee is enabled
     * @param fee The fee amount
     */
    function setProtocolFee(
        bytes32 id,
        bool enable,
        uint256 fee
    ) external;
}
