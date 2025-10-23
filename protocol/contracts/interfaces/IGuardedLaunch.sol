// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface IGuardedLaunch {
    /// @notice Emitted when global pause state changes
    /// @param caller Address that triggered pause
    event GlobalPaused(address indexed caller);

    /// @notice Emitted when global unpause occurs
    /// @param caller Address that triggered unpause
    event GlobalUnpaused(address indexed caller);

    /// @notice Emitted when Site-specific pause occurs
    /// @param site ISite that was paused
    /// @param asset Asset that was paused
    event SitePaused(ISite indexed site, address indexed asset);

    /// @notice Emitted when Site-specific unpause occurs
    /// @param site ISite that was unpaused
    /// @param asset Asset that was unpaused
    event SiteUnpaused(ISite indexed site, address indexed asset);

    /// @notice Emitted when max liquidity limit enabled/disabled
    /// @param enabled True if enabled
    event MaxLiquidityLimitEnabled(bool enabled);

    /// @notice Emitted when Site deposit limit set
    /// @param site ISite with new limit
    /// @param maxDeposits New maximum deposit limit
    event SiteMaxDepositsSet(ISite indexed site, uint256 maxDeposits);

    /**
     * @notice Sets global pause state
     * @dev Only callable by EMERGENCY_ADMIN_ROLE. Pauses all Sites.
     * @param paused True to pause, false to unpause
     */
    function setGlobalPause(bool paused) external;

    /**
     * @notice Checks if protocol is globally paused
     * @return True if globally paused
     */
    function isGlobalPaused() external view returns (bool);

    /**
     * @notice Pauses specific Site and asset
     * @dev Only callable by EMERGENCY_ADMIN_ROLE. More granular than global pause.
     * @param site ISite to pause
     * @param asset Asset to pause (or address(0) for all assets)
     * @param paused True to pause, false to unpause
     */
    function setSitePause(ISite site, address asset, bool paused) external;

    /**
     * @notice Checks if Site/asset is paused
     * @param site ISite to check
     * @param asset Asset to check
     * @return True if paused
     */
    function isSitePaused(
        ISite site,
        address asset
    ) external view returns (bool);

    /**
     * @notice Enables/disables deposit limits
     * @dev For gradual launch. Start with limits, remove as confidence grows.
     * @param enabled True to enable limits
     */
    function setLimitedMaxLiquidity(bool enabled) external;

    /**
     * @notice Sets default deposit limit for all Sites
     * @dev Applied to Sites that don't have custom limits
     * @param limit Maximum deposits in USDC value
     */
    function setDefaultSiteMaxDepositsLimit(uint256 limit) external;

    /**
     * @notice Sets custom deposit limit for specific Site
     * @param site ISite to set limit for
     * @param limit Maximum deposits in USDC value
     */
    function setSiteMaxDepositsLimit(ISite site, uint256 limit) external;

    /**
     * @notice Gets maximum deposit value for a Site
     * @param site ISite to query
     * @return Maximum deposits allowed (in USDC value)
     */
    function getMaxSiteDepositsValue(
        ISite site
    ) external view returns (uint256);

    /**
     * @notice Checks if deposit would exceed limit
     * @param site ISite to check
     * @param asset Asset being deposited
     * @param amount Amount to deposit
     * @return True if deposit exceeds limit
     */
    function isDepositLimitReached(
        ISite site,
        address asset,
        uint256 amount
    ) external view returns (bool);
}
