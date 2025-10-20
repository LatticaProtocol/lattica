// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface ISite is IBaseSite {
    /**
     * @notice Deposits collateral into the Site
     * @dev User must approve Site to transfer tokens first
     * @param asset Address of asset to deposit (YES, NO, or USDC)
     * @param amount Amount of underlying tokens to deposit
     * @param collateralOnly True to deposit as protected collateral (cannot be borrowed)
     * @return shares Amount of share tokens minted to user
     */
    function deposit(
        address asset,
        uint256 amount,
        bool collateralOnly
    ) external returns (uint256 shares);

    /**
     * @notice Withdraws collateral from the Site
     * @dev Fails if withdrawal would make user insolvent
     * @param asset Address of asset to withdraw
     * @param shares Amount of share tokens to burn
     * @param collateralOnly True if withdrawing protected collateral
     * @return amount Amount of underlying tokens withdrawn
     */
    function withdraw(
        address asset,
        uint256 shares,
        bool collateralOnly
    ) external returns (uint256 amount);

    /**
     * @notice Borrows USDC against collateral
     * @dev Only USDC can be borrowed. Fails if borrow would make user insolvent.
     * @param asset Address of asset to borrow (must be USDC)
     * @param amount Amount of underlying tokens to borrow
     * @return shares Amount of debt shares minted to user
     */
    function borrow(
        address asset,
        uint256 amount
    ) external returns (uint256 shares);

    /**
     * @notice Repays borrowed USDC
     * @dev User must approve Site to transfer USDC first
     * @param asset Address of asset to repay (USDC)
     * @param amount Amount of underlying tokens to repay
     * @return shares Amount of debt shares burned
     */
    function repay(
        address asset,
        uint256 amount
    ) external returns (uint256 shares);

    /**
     * @notice Liquidates an insolvent user's position
     * @dev Liquidator repays user's debt and receives collateral + bonus
     * @param user Address of the user to liquidate
     * @param asset Address of the debt asset (USDC)
     * @param shareAmountToRepay Amount of debt shares to repay
     * @return seizedCollateral Amount of collateral seized
     */
    function liquidate(
        address user,
        address asset,
        uint256 shareAmountToRepay
    ) external returns (uint256 seizedCollateral);

    /**
     * @notice Accrues interest for an asset
     * @dev Updates interest calculations to current block. Can be called by anyone.
     * @param asset Address of the asset to accrue interest for
     */
    function accrueInterest(address asset) external;

    /**
     * @notice Flash liquidation with callback
     * @dev Liquidator receives collateral first, callback executes, must repay in same tx
     * @param user Address of the user to liquidate
     * @param asset Address of the debt asset
     * @param shareAmountToRepay Amount of debt shares to repay
     * @param receiverAddress Address of IFlashLiquidationReceiver implementation
     * @param data Arbitrary data to pass to callback
     * @return seizedCollateral Amount of collateral seized
     */
    function flashLiquidate(
        address user,
        address asset,
        uint256 shareAmountToRepay,
        address receiverAddress,
        bytes calldata data
    ) external returns (uint256 seizedCollateral);

    /**
     * @notice Updates cached risk parameters
     * @dev Only callable by ISiteConfiguration. This is the PUSH mechanism for cache updates.
     * @param asset Address of the asset to update config for
     * @param maxLtv New maximum loan-to-value in basis points
     * @param liquidationThreshold New liquidation threshold in basis points
     * @param liquidationPenalty New liquidation penalty in basis points
     */
    function updateCachedConfig(
        address asset,
        uint256 maxLtv,
        uint256 liquidationThreshold,
        uint256 liquidationPenalty
    ) external;

    /**
     * @notice Updates the interest rate model
     * @dev Only callable by ISiteConfiguration
     * @param newModel Address of the new interest rate model
     */
    function updateInterestRateModel(address newModel) external;
}
