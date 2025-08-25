// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/**
 * @title IFeeRegistry
 * @notice Interface for the FeeRegistry contract that manages fees for operators and curators
 * @dev This interface defines the fee management system for both operators and curators,
 * allowing for granular fee control at global, vault, network, and vault-network levels.
 * Fees are stored with timestamps to support historical fee tracking and updates.
 */
interface IFeeRegistry {
    /* EVENTS */

    /**
     * @notice Emitted when an operator's global fee is updated
     * @param operator The address of the operator whose fee was updated
     * @param isEnabled Whether the fee is enabled (true) or disabled (false)
     * @param fee The fee amount in basis points (1/100th of a percent)
     */
    event SetOperatorGlobalFee(address indexed operator, bool isEnabled, uint256 fee);

    /**
     * @notice Emitted when an operator's vault-specific fee is updated
     * @param operator The address of the operator whose fee was updated
     * @param vault The address of the vault for which the fee applies
     * @param isEnabled Whether the fee is enabled (true) or disabled (false)
     * @param fee The fee amount in basis points (1/100th of a percent)
     */
    event SetOperatorVaultFee(address indexed operator, address indexed vault, bool isEnabled, uint256 fee);

    /**
     * @notice Emitted when an operator's network-specific fee is updated
     * @param operator The address of the operator whose fee was updated
     * @param network The address of the network for which the fee applies
     * @param isEnabled Whether the fee is enabled (true) or disabled (false)
     * @param fee The fee amount in basis points (1/100th of a percent)
     */
    event SetOperatorNetworkFee(address indexed operator, address indexed network, bool isEnabled, uint256 fee);

    /**
     * @notice Emitted when an operator's vault-network specific fee is updated
     * @param operator The address of the operator whose fee was updated
     * @param vault The address of the vault for which the fee applies
     * @param network The address of the network for which the fee applies
     * @param isEnabled Whether the fee is enabled (true) or disabled (false)
     * @param fee The fee amount in basis points (1/100th of a percent)
     */
    event SetOperatorVaultNetworkFee(
        address indexed operator, address indexed vault, address indexed network, bool isEnabled, uint256 fee
    );

    /**
     * @notice Emitted when a curator's global fee is updated
     * @param curator The address of the curator whose fee was updated
     * @param isEnabled Whether the fee is enabled (true) or disabled (false)
     * @param fee The fee amount in basis points (1/100th of a percent)
     */
    event SetCuratorGlobalFee(address indexed curator, bool isEnabled, uint256 fee);

    /**
     * @notice Emitted when a curator's vault-specific fee is updated
     * @param curator The address of the curator whose fee was updated
     * @param vault The address of the vault for which the fee applies
     * @param isEnabled Whether the fee is enabled (true) or disabled (false)
     * @param fee The fee amount in basis points (1/100th of a percent)
     */
    event SetCuratorVaultFee(address indexed curator, address indexed vault, bool isEnabled, uint256 fee);

    /* ERRORS */

    error FeeTooHigh();

    /* FUNCTIONS */

    /**
     * @notice Get the operator fee for a specific vault and network at a given timestamp
     * @param operator The address of the operator
     * @param vault The address of the vault
     * @param network The address of the network
     * @param timestamp The timestamp to query the fee for
     * @param hint The hint to use for the checkpoint lookup
     * @return fee The fee amount in basis points (1/100th of a percent)
     * @dev This function returns the fee that was active at the specified timestamp,
     * allowing for historical fee queries and audit trails.
     */
    function getOperatorFeeAt(
        address operator,
        address vault,
        address network,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (uint256 fee);

    /**
     * @notice Get the current operator fee for a specific vault and network
     * @param operator The address of the operator
     * @param vault The address of the vault
     * @param network The address of the network
     * @return fee The current fee amount in basis points (1/100th of a percent)
     * @dev This function returns the most recently set fee for the operator-vault-network combination.
     * If no specific fee is set, it falls back to the appropriate parent level fee.
     */
    function getOperatorFee(address operator, address vault, address network) external view returns (uint256 fee);

    /**
     * @notice Get the operator's global fee settings at a specific timestamp
     * @param operator The address of the operator
     * @param timestamp The timestamp to query the fee for
     * @param hint The hint to use for the checkpoint lookup
     * @return isEnabled Whether the global fee was enabled (true) or disabled (false) at the timestamp
     * @return fee The global fee amount in basis points (1/100th of a percent) at the timestamp
     * @dev This function returns the fee that was active at the specified timestamp,
     * allowing for historical fee queries and audit trails.
     */
    function getOperatorGlobalFeeAt(
        address operator,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get the operator's global fee settings
     * @param operator The address of the operator
     * @return isEnabled Whether the global fee is enabled (true) or disabled (false)
     * @return fee The global fee amount in basis points (1/100th of a percent)
     * @dev Global fees serve as the default for all vaults and networks unless overridden
     */
    function getOperatorGlobalFee(
        address operator
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get the operator's vault-specific fee settings at a specific timestamp
     * @param operator The address of the operator
     * @param vault The address of the vault
     * @param timestamp The timestamp to query the fee for
     * @param hint The hint to use for the checkpoint lookup
     * @return isEnabled Whether the vault fee was enabled (true) or disabled (false) at the timestamp
     * @return fee The vault-specific fee amount in basis points (1/100th of a percent) at the timestamp
     * @dev This function returns the fee that was active at the specified timestamp,
     * allowing for historical fee queries and audit trails.
     */
    function getOperatorVaultFeeAt(
        address operator,
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get the operator's vault-specific fee settings
     * @param operator The address of the operator
     * @param vault The address of the vault
     * @return isEnabled Whether the vault fee is enabled (true) or disabled (false)
     * @return fee The vault-specific fee amount in basis points (1/100th of a percent)
     * @dev Vault fees override global fees for all networks within that specific vault
     */
    function getOperatorVaultFee(address operator, address vault) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get the operator's network-specific fee settings at a specific timestamp
     * @param operator The address of the operator
     * @param network The address of the network
     * @param timestamp The timestamp to query the fee for
     * @param hint The hint to use for the checkpoint lookup
     * @return isEnabled Whether the network fee was enabled (true) or disabled (false) at the timestamp
     * @return fee The network-specific fee amount in basis points (1/100th of a percent) at the timestamp
     * @dev This function returns the fee that was active at the specified timestamp,
     * allowing for historical fee queries and audit trails.
     */
    function getOperatorNetworkFeeAt(
        address operator,
        address network,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get the operator's network-specific fee settings
     * @param operator The address of the operator
     * @param network The address of the network
     * @return isEnabled Whether the network fee is enabled (true) or disabled (false)
     * @return fee The network-specific fee amount in basis points (1/100th of a percent)
     * @dev Network fees override global fees for all vaults within that specific network
     */
    function getOperatorNetworkFee(
        address operator,
        address network
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get the operator's vault-network specific fee settings at a specific timestamp
     * @param operator The address of the operator
     * @param vault The address of the vault
     * @param network The address of the network
     * @param timestamp The timestamp to query the fee for
     * @param hint The hint to use for the checkpoint lookup
     * @return isEnabled Whether the vault-network fee was enabled (true) or disabled (false) at the timestamp
     * @return fee The vault-network specific fee amount in basis points (1/100th of a percent) at the timestamp
     * @dev This function returns the fee that was active at the specified timestamp,
     * allowing for historical fee queries and audit trails.
     */
    function getOperatorVaultNetworkFeeAt(
        address operator,
        address vault,
        address network,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get the operator's vault-network specific fee settings
     * @param operator The address of the operator
     * @param vault The address of the vault
     * @param network The address of the network
     * @return isEnabled Whether the vault-network fee is enabled (true) or disabled (false)
     * @return fee The vault-network specific fee amount in basis points (1/100th of a percent)
     * @dev Vault-network fees provide the most granular fee control and override all parent level fees
     */
    function getOperatorVaultNetworkFee(
        address operator,
        address vault,
        address network
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get the curator fee for a specific vault at a given timestamp
     * @param curator The address of the curator
     * @param vault The address of the vault
     * @param timestamp The timestamp to query the fee for
     * @param hint The hint to use for the checkpoint lookup
     * @return fee The fee amount in basis points (1/100th of a percent)
     * @dev This function returns the fee that was active at the specified timestamp,
     * allowing for historical fee queries and audit trails.
     */
    function getCuratorFeeAt(
        address curator,
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (uint256 fee);

    /**
     * @notice Get the current curator fee for a specific vault
     * @param curator The address of the curator
     * @param vault The address of the vault
     * @return fee The current fee amount in basis points (1/100th of a percent)
     * @dev This function returns the most recently set fee for the curator-vault combination.
     * If no specific fee is set, it falls back to the global curator fee.
     */
    function getCuratorFee(address curator, address vault) external view returns (uint256 fee);

    /**
     * @notice Get the curator's global fee settings at a specific timestamp
     * @param curator The address of the curator
     * @param timestamp The timestamp to query the fee for
     * @param hint The hint to use for the checkpoint lookup
     * @return isEnabled Whether the global fee was enabled (true) or disabled (false) at the timestamp
     * @return fee The global fee amount in basis points (1/100th of a percent) at the timestamp
     * @dev This function returns the fee that was active at the specified timestamp,
     * allowing for historical fee queries and audit trails.
     */
    function getCuratorGlobalFeeAt(
        address curator,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get the curator's global fee settings
     * @param curator The address of the curator
     * @return isEnabled Whether the global fee is enabled (true) or disabled (false)
     * @return fee The global fee amount in basis points (1/100th of a percent)
     * @dev Global fees serve as the default for all vaults unless overridden by vault-specific fees
     */
    function getCuratorGlobalFee(
        address curator
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get the curator's vault-specific fee settings at a specific timestamp
     * @param curator The address of the curator
     * @param vault The address of the vault
     * @param timestamp The timestamp to query the fee for
     * @param hint The hint to use for the checkpoint lookup
     * @return isEnabled Whether the vault fee was enabled (true) or disabled (false) at the timestamp
     * @return fee The vault-specific fee amount in basis points (1/100th of a percent) at the timestamp
     * @dev This function returns the fee that was active at the specified timestamp,
     * allowing for historical fee queries and audit trails.
     */
    function getCuratorVaultFeeAt(
        address curator,
        address vault,
        uint48 timestamp,
        bytes memory hint
    ) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Get the curator's vault-specific fee settings
     * @param curator The address of the curator
     * @param vault The address of the vault
     * @return isEnabled Whether the vault fee is enabled (true) or disabled (false)
     * @return fee The vault-specific fee amount in basis points (1/100th of a percent)
     * @dev Vault fees override global fees for that specific vault
     */
    function getCuratorVaultFee(address curator, address vault) external view returns (bool isEnabled, uint256 fee);

    /**
     * @notice Set the operator's global fee
     * @param enable Whether to enable (true) or disable (false) the global fee
     * @param fee The fee amount in basis points (1/100th of a percent)
     * @dev This sets the default fee for all vaults and networks unless overridden.
     * Only callable by authorized accounts (typically the operator themselves or governance).
     */
    function setOperatorGlobalFee(bool enable, uint256 fee) external;

    /**
     * @notice Set the operator's vault-specific fee
     * @param vault The address of the vault for which to set the fee
     * @param enable Whether to enable (true) or disable (false) the vault fee
     * @param fee The fee amount in basis points (1/100th of a percent)
     * @dev This overrides the global fee for all networks within the specified vault.
     * Only callable by authorized accounts (typically the operator themselves or governance).
     */
    function setOperatorVaultFee(address vault, bool enable, uint256 fee) external;

    /**
     * @notice Set the operator's network-specific fee
     * @param network The address of the network for which to set the fee
     * @param enable Whether to enable (true) or disable (false) the network fee
     * @param fee The fee amount in basis points (1/100th of a percent)
     * @dev This overrides the global fee for all vaults within the specified network.
     * Only callable by authorized accounts (typically the operator themselves or governance).
     */
    function setOperatorNetworkFee(address network, bool enable, uint256 fee) external;

    /**
     * @notice Set the operator's vault-network specific fee
     * @param vault The address of the vault for which to set the fee
     * @param network The address of the network for which to set the fee
     * @param enable Whether to enable (true) or disable (false) the vault-network fee
     * @param fee The fee amount in basis points (1/100th of a percent)
     * @dev This provides the most granular fee control and overrides all parent level fees.
     * Only callable by authorized accounts (typically the operator themselves or governance).
     */
    function setOperatorVaultNetworkFee(address vault, address network, bool enable, uint256 fee) external;

    /**
     * @notice Set the curator's global fee
     * @param enable Whether to enable (true) or disable (false) the global fee
     * @param fee The fee amount in basis points (1/100th of a percent)
     * @dev This sets the default fee for all vaults unless overridden by vault-specific fees.
     * Only callable by authorized accounts (typically the curator themselves or governance).
     */
    function setCuratorGlobalFee(bool enable, uint256 fee) external;

    /**
     * @notice Set the curator's vault-specific fee
     * @param vault The address of the vault for which to set the fee
     * @param enable Whether to enable (true) or disable (false) the vault fee
     * @param fee The fee amount in basis points (1/100th of a percent)
     * @dev This overrides the global fee for the specified vault.
     * Only callable by authorized accounts (typically the curator themselves or governance).
     */
    function setCuratorVaultFee(address vault, bool enable, uint256 fee) external;
}
