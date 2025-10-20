// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IGuardedLaunch {
    /// @notice Emitted when global pause is triggered
    event GlobalPaused(address indexed caller);

    /// @notice Emitted when global pause is lifted
    event GlobalUnpaused(address indexed caller);

    /// @notice Emitted when specific Site/asset is paused
    event SitePaused(address indexed site, address indexed asset);

    /// @notice Emitted when specific Site/asset is unpaused
    event SiteUnpaused(address indexed site, address indexed asset);

    /// @notice Emitted when deposit limits are toggled
    event MaxLiquidityLimitEnabled(bool enabled);

    /// @notice Emitted when Site deposit limit is set
    event SiteMaxDepositsSet(address indexed site, uint256 maxDeposits);

    /**
     * @notice Pauses/unpauses all Sites
     * @dev Only callable by EMERGENCY_ADMIN_ROLE. Nuclear option.
     * @param paused True to pause, false to unpause
     */
    function setGlobalPause(bool paused) external;

    /**
     * @notice Checks if protocol is globally paused
     * @return True if paused
     */
    function isGlobalPaused() external view returns (bool);

    /**
     * @notice Pauses specific Site and asset
     * @dev Only callable by EMERGENCY_ADMIN_ROLE
     * @param site Site address to pause
     * @param asset Asset address to pause
     * @param paused True to pause, false to unpause
     */
    function setSitePause(address site, address asset, bool paused) external;

    /**
     * @notice Checks if Site/asset is paused
     * @param site Site address
     * @param asset Asset address
     * @return True if paused
     */
    function isSitePaused(
        address site,
        address asset
    ) external view returns (bool);

    /**
     * @notice Enables/disables deposit limits
     * @dev Only callable by owner. Used during guarded launch.
     * @param enabled True to enable limits
     */
    function setLimitedMaxLiquidity(bool enabled) external;

    /**
     * @notice Sets default deposit limit for new Sites
     * @param limit Maximum total deposits in USD value
     */
    function setDefaultSiteMaxDepositsLimit(uint256 limit) external;

    /**
     * @notice Sets deposit limit for specific Site
     * @param site Site address
     * @param limit Maximum total deposits in USD value
     */
    function setSiteMaxDepositsLimit(address site, uint256 limit) external;

    /**
     * @notice Gets current deposit limit for Site
     * @param site Site address
     * @return Maximum deposits in USD value
     */
    function getMaxSiteDepositsValue(
        address site
    ) external view returns (uint256);

    /**
     * @notice Checks if deposit would exceed limit
     * @param site Site address
     * @param asset Asset being deposited
     * @param amount Amount being deposited
     * @return True if would exceed limit
     */
    function isDepositLimitReached(
        address site,
        address asset,
        uint256 amount
    ) external view returns (bool);
}

