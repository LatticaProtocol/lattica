// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface IHookReceiver {
    /**
     * @notice Called before a protocol action executes
     * @dev Can revert to prevent the action. Used for validation and eligibility checks.
     * @param silo ISite where action is happening
     * @param action Encoded action type (see Hook library)
     * @param inputData ABI-encoded action-specific data
     */
    function beforeAction(
        ISite silo,
        uint256 action,
        bytes calldata inputData
    ) external;

    /**
     * @notice Called after a protocol action completes
     * @dev Cannot revert core action (already completed). Used for notifications and follow-up logic.
     * @param silo ISite where action happened
     * @param action Encoded action type (see Hook library)
     * @param inputData ABI-encoded action-specific data
     */
    function afterAction(
        ISite silo,
        uint256 action,
        bytes calldata inputData
    ) external;

    /**
     * @notice Gets hook configuration
     * @dev Returns bitmask of which actions have before/after hooks enabled
     * @return hooksBefore Bitmask of actions with beforeAction hooks
     * @return hooksAfter Bitmask of actions with afterAction hooks
     */
    function hookReceiverConfig(
        ISite silo
    ) external view returns (uint24 hooksBefore, uint24 hooksAfter);
}
