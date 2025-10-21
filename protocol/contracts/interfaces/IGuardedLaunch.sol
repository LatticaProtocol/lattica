// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface IGuardedLaunch {
    /// @notice Emitted when global pause is triggered
    event GlobalPaused(address indexed caller);

    /// @notice Emitted when global pause is lifted
    event GlobalUnpaused(address indexed caller);

    /// @notice Emitted when specific Site/asset is paused
    event SitePaused(ISite indexed site, address indexed asset);

    /// @notice Emitted when specific Site/asset is unpaused
    event SiteUnpaused(ISite indexed site, address indexed asset);

    /// @notice Emitted when deposit limits are toggled
    event MaxLiquidityLimitEnabled(bool enabled);

    /// @notice Emitted when Site deposit limit is set
    event SiteMaxDepositsSet(ISite indexed site, uint256 maxDeposits);

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
     * @param site ISite instance to pause
     * @param asset Asset address to pause
     * @param paused True to pause, false to unpause
     */
    function setSitePause(ISite site, address asset, bool paused) external;

    /**
     * @notice Checks if Site/asset is paused
     * @param site ISite instance
     * @param asset Asset address
     * @return True if paused
     */
    function isSitePaused(
        ISite site,
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
     * @param site ISite instance
     * @param limit Maximum total deposits in USD value
     */
    function setSiteMaxDepositsLimit(ISite site, uint256 limit) external;

    /**
     * @notice Gets current deposit limit for Site
     * @param site ISite instance
     * @return Maximum deposits in USD value
     */
    function getMaxSiteDepositsValue(
        ISite site
    ) external view returns (uint256);

    /**
     * @notice Checks if deposit would exceed limit
     * @param site ISite instance
     * @param asset Asset being deposited
     * @param amount Amount being deposited
     * @return True if would exceed limit
     */
    function isDepositLimitReached(
        ISite site,
        address asset,
        uint256 amount
    ) external view returns (bool);
}
