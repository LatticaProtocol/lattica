// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IInterestRateModel.sol";
import "./ISite.sol";

interface ISiteConfig {
    /**
     * @notice Complete asset configuration
     * @dev All risk parameters for an asset in one struct
     */
    struct AssetConfig {
        uint256 maxLoanToValue; // Max LTV in basis points (7500 = 75%)
        uint256 liquidationThreshold; // Liquidation threshold in basis points (8000 = 80%)
        uint256 liquidationTargetLtv; // Target LTV after liquidation in basis points (7000 = 70%)
        uint256 liquidationPenalty; // Liquidation penalty in basis points (500 = 5%)
        bool borrowingEnabled; // Can this asset be borrowed?
        bool depositsEnabled; // Can deposits be made?
    }

    /// @notice Emitted when LTV is updated
    event MaxLoanToValueUpdated(
        address indexed site,
        address indexed asset,
        uint256 newLTV
    );

    /// @notice Emitted when liquidation threshold updated
    event LiquidationThresholdUpdated(
        address indexed site,
        address indexed asset,
        uint256 newThreshold
    );

    /// @notice Emitted when liquidation penalty updated
    event LiquidationPenaltyUpdated(
        address indexed site,
        address indexed asset,
        uint256 newPenalty
    );

    /// @notice Emitted when interest rate model updated
    event InterestRateModelUpdated(
        address indexed site,
        IInterestRateModel indexed newModel
    );

    /// @notice Emitted when asset status updated
    event AssetStatusUpdated(
        address indexed site,
        address indexed asset,
        bool borrowingEnabled,
        bool depositsEnabled
    );

    /// @notice Emitted when resolution grace period updated
    event ResolutionGracePeriodUpdated(address indexed site, uint256 newPeriod);

    /**
     * @notice Sets maximum loan-to-value for asset
     * @dev Only callable by RISK_MANAGER_ROLE. Pushes update to Site for caching.
     * @param site ISite instance
     * @param asset Asset address
     * @param ltv New LTV in basis points
     */
    function setMaxLoanToValue(ISite site, address asset, uint256 ltv) external;

    /**
     * @notice Sets liquidation threshold for asset
     * @dev Only callable by RISK_MANAGER_ROLE. Must be >= maxLTV.
     * @param site ISite instance
     * @param asset Asset address
     * @param threshold New threshold in basis points
     */
    function setLiquidationThreshold(
        ISite site,
        address asset,
        uint256 threshold
    ) external;

    /**
     * @notice Sets liquidation target LTV for asset
     * @dev Only callable by RISK_MANAGER_ROLE. Target LTV after liquidation (prevents dust).
     *      Must be < maxLTV. Ensures position is healthy after liquidation.
     * @param site ISite instance
     * @param asset Asset address
     * @param targetLtv New target LTV in basis points (e.g., 7000 = 70%)
     */
    function setLiquidationTargetLtv(
        ISite site,
        address asset,
        uint256 targetLtv
    ) external;

    /**
     * @notice Sets liquidation penalty for asset
     * @dev Only callable by RISK_MANAGER_ROLE. Penalty paid by liquidated user.
     * @param site ISite instance
     * @param asset Asset address
     * @param penalty New penalty in basis points
     */
    function setLiquidationPenalty(
        ISite site,
        address asset,
        uint256 penalty
    ) external;

    /**
     * @notice Sets complete asset config at once
     * @dev Batch update to save gas when changing multiple parameters
     * @param site ISite instance
     * @param asset Asset address
     * @param config New configuration struct
     */
    function setAssetConfig(
        ISite site,
        address asset,
        AssetConfig calldata config
    ) external;

    /**
     * @notice Updates interest rate model for Site
     * @dev Only callable by RISK_MANAGER_ROLE. Pushes to Site.
     * @param site ISite instance
     * @param newModel New IInterestRateModel instance
     */
    function setInterestRateModel(
        ISite site,
        IInterestRateModel newModel
    ) external;

    /**
     * @notice Sets resolution grace period
     * @dev Time window after resolution trigger before finalization
     * @param site ISite instance
     * @param period Grace period in seconds
     */
    function setResolutionGracePeriod(ISite site, uint256 period) external;

    /**
     * @notice Sets delay before liquidating after resolution
     * @dev Gives users time to manually unwind positions
     * @param site ISite instance
     * @param delay Delay in seconds
     */
    function setPostResolutionLiquidationDelay(
        ISite site,
        uint256 delay
    ) external;

    /**
     * @notice Enables/disables borrowing for asset
     * @dev Emergency function to pause borrowing without full pause
     * @param site ISite instance
     * @param asset Asset address
     * @param enabled True to enable, false to disable
     */
    function setBorrowingEnabled(
        ISite site,
        address asset,
        bool enabled
    ) external;

    /**
     * @notice Enables/disables deposits for asset
     * @dev Emergency function to pause deposits without full pause
     * @param site ISite instance
     * @param asset Asset address
     * @param enabled True to enable, false to disable
     */
    function setDepositsEnabled(
        ISite site,
        address asset,
        bool enabled
    ) external;

    /**
     * @notice Gets current asset configuration
     * @dev For UI/off-chain queries. Sites use cached values.
     * @param site ISite instance
     * @param asset Asset address
     * @return Current configuration struct
     */
    function getAssetConfig(
        ISite site,
        address asset
    ) external view returns (AssetConfig memory);

    /**
     * @notice Gets resolution grace period
     * @param site ISite instance
     * @return Grace period in seconds
     */
    function getResolutionGracePeriod(
        ISite site
    ) external view returns (uint256);

    /**
     * @notice Gets post-resolution liquidation delay
     * @param site ISite instance
     * @return Delay in seconds
     */
    function getPostResolutionLiquidationDelay(
        ISite site
    ) external view returns (uint256);
}
