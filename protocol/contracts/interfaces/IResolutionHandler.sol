// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface IResolutionHandler {
    /**
     * @notice States of resolution process
     * @dev State machine: ACTIVE -> RESOLVING -> RESOLVED (or DISPUTED)
     */
    enum ResolutionState {
        ACTIVE, // Market trading normally
        RESOLVING, // Resolution triggered, grace period active
        RESOLVED, // Final resolution, can liquidate losing positions
        DISPUTED // Resolution challenged (rare)
    }

    /// @notice Emitted when resolution begins
    event ResolutionTriggered(
        bytes32 indexed conditionId,
        bool yesWon,
        uint256 gracePeriodEnd
    );

    /// @notice Emitted when resolution finalizes
    event ResolutionFinalized(bytes32 indexed conditionId, bool yesWon);

    /// @notice Emitted when resolution is disputed
    event ResolutionDisputed(bytes32 indexed conditionId);

    /// @notice Emitted when losing position is liquidated
    event LosingPositionLiquidated(
        address indexed user,
        address indexed losingAsset,
        uint256 amount
    );

    /// @notice Emitted when winnings are distributed
    event WinningsDistributed(address indexed user, uint256 amount);

    /**
     * @notice Triggers resolution process for a Site
     * @dev Begins grace period. Only callable when oracle reports resolution.
     * @param site ISite instance to resolve
     */
    function handleResolution(ISite site) external;

    /**
     * @notice Finalizes resolution after grace period
     * @dev Transitions to RESOLVED state. Enables liquidation of losing positions.
     * @param site ISite instance to finalize
     */
    function finalizeResolution(ISite site) external;

    /**
     * @notice Disputes a resolution (rare)
     * @dev Only callable by EMERGENCY_ADMIN_ROLE if resolution is incorrect
     * @param site ISite instance to dispute
     */
    function disputeResolution(ISite site) external;

    /**
     * @notice Liquidates positions backed by losing outcome
     * @dev After resolution, losing collateral is worth $0. Auto-liquidate these users.
     * @param site ISite instance
     * @param users Array of users to liquidate
     */
    function liquidateLosingPositions(
        ISite site,
        address[] calldata users
    ) external;

    /**
     * @notice Distributes $1 payout to winning collateral holders
     * @dev Users with winning shares can redeem for $1 each via CTF
     * @param site ISite instance
     * @param user User to distribute winnings to
     * @return amount Amount distributed
     */
    function distributeWinnings(
        ISite site,
        address user
    ) external returns (uint256 amount);

    /**
     * @notice Gets current resolution state
     * @param site ISite instance
     * @return Current state enum
     */
    function getResolutionState(
        ISite site
    ) external view returns (ResolutionState);

    /**
     * @notice Checks if resolution is complete
     * @param site ISite instance
     * @return True if fully resolved
     */
    function isResolutionComplete(ISite site) external view returns (bool);

    /**
     * @notice Gets when grace period ends
     * @param site ISite instance
     * @return Timestamp when grace period ends
     */
    function getGracePeriodEnd(ISite site) external view returns (uint256);

    /**
     * @notice Checks if user can withdraw asset
     * @dev During grace period, may restrict withdrawals
     * @param site ISite instance
     * @param user User address
     * @param asset Asset address
     * @return True if withdrawal allowed
     */
    function canWithdraw(
        ISite site,
        address user,
        address asset
    ) external view returns (bool);

    /**
     * @notice Checks if user can be liquidated
     * @dev Considers both solvency and resolution state
     * @param site ISite instance
     * @param user User address
     * @return True if liquidatable
     */
    function canLiquidate(
        ISite site,
        address user
    ) external view returns (bool);
}
