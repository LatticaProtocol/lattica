// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface IResolutionHandler {
    /// @notice Resolution state for a market
    enum ResolutionState {
        ACTIVE, // Market trading normally
        TRIGGERED, // Resolution reported by oracle
        GRACE_PERIOD, // Waiting for disputes
        FINALIZED, // Resolution complete
        DISPUTED // Resolution challenged
    }

    /// @notice Emitted when resolution triggered
    /// @param conditionId Polymarket condition ID
    /// @param yesWon True if YES won
    /// @param gracePeriodEnd Grace period end timestamp
    event ResolutionTriggered(
        bytes32 indexed conditionId,
        bool yesWon,
        uint256 gracePeriodEnd
    );

    /// @notice Emitted when resolution finalized
    /// @param conditionId Polymarket condition ID
    /// @param yesWon True if YES won
    event ResolutionFinalized(bytes32 indexed conditionId, bool yesWon);

    /// @notice Emitted when resolution disputed
    /// @param conditionId Polymarket condition ID
    event ResolutionDisputed(bytes32 indexed conditionId);

    /// @notice Emitted when losing position liquidated
    /// @param user User liquidated
    /// @param losingAsset Asset that lost
    /// @param amount Amount liquidated
    event LosingPositionLiquidated(
        address indexed user,
        address indexed losingAsset,
        uint256 amount
    );

    /// @notice Emitted when winnings distributed
    /// @param user User receiving winnings
    /// @param amount Amount distributed
    event WinningsDistributed(address indexed user, uint256 amount);

    /**
     * @notice Handles resolution trigger
     * @dev Called when oracle reports resolution
     * @param site ISite to resolve
     */
    function handleResolution(ISite site) external;

    /**
     * @notice Finalizes resolution after grace period
     * @dev Makes resolution immutable
     * @param site ISite to finalize
     */
    function finalizeResolution(ISite site) external;

    /**
     * @notice Disputes resolution
     * @dev Only callable during grace period
     * @param site ISite to dispute
     */
    function disputeResolution(ISite site) external;

    /**
     * @notice Liquidates users holding losing collateral
     * @param site ISite where resolution occurred
     * @param users Array of users to liquidate
     */
    function liquidateLosingPositions(
        ISite site,
        address[] calldata users
    ) external;

    /**
     * @notice Distributes winnings to user
     * @dev Redeems winning CTF tokens for USDC
     * @param site ISite where user won
     * @param user User to distribute to
     * @return amount Amount distributed
     */
    function distributeWinnings(
        ISite site,
        address user
    ) external returns (uint256 amount);

    /**
     * @notice Gets resolution state
     * @param site ISite to query
     * @return Current resolution state
     */
    function getResolutionState(
        ISite site
    ) external view returns (ResolutionState);

    /**
     * @notice Checks if resolution is complete
     * @param site ISite to query
     * @return True if finalized
     */
    function isResolutionComplete(ISite site) external view returns (bool);

    /**
     * @notice Gets grace period end timestamp
     * @param site ISite to query
     * @return Grace period end timestamp
     */
    function getGracePeriodEnd(ISite site) external view returns (uint256);

    /**
     * @notice Checks if user can withdraw asset
     * @param site ISite to check
     * @param user User to check
     * @param asset Asset to check
     * @return True if withdrawal allowed
     */
    function canWithdraw(
        ISite site,
        address user,
        address asset
    ) external view returns (bool);

    /**
     * @notice Checks if user can be liquidated
     * @param site ISite to check
     * @param user User to check
     * @return True if liquidation allowed
     */
    function canLiquidate(
        ISite site,
        address user
    ) external view returns (bool);
}
