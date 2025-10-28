// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface IHookReceiver {
    /**
     * @notice Called before a protocol action executes
     * @dev Can revert to prevent the action. Must be gas-efficient.
     * @param site ISite where action is happening
     * @param action Action ID (see Hook library)
     * @param inputData ABI-encoded action-specific data
     */
    function beforeAction(ISite site, uint256 action, bytes calldata inputData) external;

    /**
     * @notice Called after a protocol action completes
     * @dev Cannot revert core action (already completed). Used for notifications.
     * @param site ISite where action happened
     * @param action Action ID (see Hook library)
     * @param inputData ABI-encoded action-specific data
     */
    function afterAction(ISite site, uint256 action, bytes calldata inputData) external;

    /**
     * @notice Returns hook configuration for a Site
     * @dev Sites cache this configuration for gas efficiency
     * @param site ISite to get configuration for
     * @return hooksBefore Bitmask of actions with beforeAction hooks
     * @return hooksAfter Bitmask of actions with afterAction hooks
     */
    function hookReceiverConfig(ISite site) external view returns (uint24 hooksBefore, uint24 hooksAfter);

    /**
     * @notice Returns hook receiver version
     * @return Version string (e.g., "1.0.0")
     */
    function version() external pure returns (string memory);

    /**
     * @notice Returns hook receiver name
     * @return Name string (e.g., "PartialLiquidation")
     */
    function name() external pure returns (string memory);
}
