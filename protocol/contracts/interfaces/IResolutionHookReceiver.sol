// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IHookReceiver.sol";
import "./IResolutionHandler.sol";

interface IResolutionHookReceiver is IHookReceiver {
    /// @notice Emitted when resolution triggered
    /// @param site ISite being resolved
    /// @param conditionId Polymarket condition ID
    /// @param yesWon True if YES won, false if NO won
    /// @param gracePeriodEnd Timestamp when grace period ends
    event ResolutionTriggered(ISite indexed site, bytes32 indexed conditionId, bool yesWon, uint256 gracePeriodEnd);

    /// @notice Emitted when resolution finalized
    /// @param site ISite that was resolved
    /// @param conditionId Polymarket condition ID
    /// @param yesWon True if YES won, false if NO won
    event ResolutionFinalized(ISite indexed site, bytes32 indexed conditionId, bool yesWon);

    /// @notice Emitted when resolution disputed
    /// @param site ISite being disputed
    /// @param conditionId Polymarket condition ID
    /// @param disputer Address that disputed
    /// @param reason Reason for dispute
    event ResolutionDisputed(ISite indexed site, bytes32 indexed conditionId, address indexed disputer, string reason);

    /// @notice Emitted when losing position liquidated post-resolution
    /// @param site ISite where liquidation occurred
    /// @param user User liquidated
    /// @param losingAsset Asset that lost (worth $0)
    /// @param amount Amount liquidated
    event LosingPositionLiquidated(ISite indexed site, address indexed user, address losingAsset, uint256 amount);

    /**
     * @notice Gets resolution state for a Site
     * @dev Uses ResolutionState from IResolutionHandler
     * @param site ISite to query
     * @return Current resolution state
     */
    function getResolutionState(ISite site) external view returns (IResolutionHandler.ResolutionState);

    /**
     * @notice Gets resolution outcome
     * @dev Only valid if state is FINALIZED
     * @param site ISite to query
     * @return yesWon True if YES won, false if NO won
     */
    function getResolutionOutcome(ISite site) external view returns (bool yesWon);

    /**
     * @notice Gets grace period end timestamp
     * @param site ISite to query
     * @return Timestamp when grace period ends (0 if not in grace period)
     */
    function getGracePeriodEnd(ISite site) external view returns (uint256);

    /**
     * @notice Checks if user can be liquidated post-resolution
     * @dev After resolution, users with losing collateral can be liquidated
     * @param site ISite to check
     * @param user User to check
     * @return canLiquidate True if user has losing collateral and can be liquidated
     */
    function canLiquidatePostResolution(ISite site, address user) external view returns (bool canLiquidate);

    /**
     * @notice Batch liquidates users with losing collateral
     * @dev Only callable after resolution is finalized
     * @param site ISite where resolution occurred
     * @param users Array of users to liquidate
     * @return liquidatedUsers Array of successfully liquidated users
     * @return amounts Array of amounts liquidated
     */
    function batchLiquidateLosingPositions(ISite site, address[] calldata users)
        external
        returns (address[] memory liquidatedUsers, uint256[] memory amounts);

    /**
     * @notice Disputes a resolution
     * @dev Only callable during grace period by EMERGENCY_ADMIN_ROLE
     * @param site ISite to dispute
     * @param reason Reason for dispute
     */
    function disputeResolution(ISite site, string calldata reason) external;

    /**
     * @notice Resolves a dispute
     * @dev Only callable by EMERGENCY_ADMIN_ROLE after investigation
     * @param site ISite to resolve
     * @param correctOutcome Correct resolution outcome
     */
    function resolveDispute(ISite site, bool correctOutcome) external;
}
