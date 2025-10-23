// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IHookReceiver.sol";
import "./ISite.sol";

interface IPartialLiquidation is IHookReceiver {
    /// @notice User is solvent, cannot liquidate
    error UserIsSolvent();

    /// @notice User has no debt to cover
    error NoDebtToCover();

    /// @notice Wrong collateral token provided
    error UnexpectedCollateralToken();

    /// @notice Wrong debt token provided
    error UnexpectedDebtToken();

    /// @notice User's position requires full liquidation
    error FullLiquidationRequired();

    /// @notice Site config is empty/invalid
    error EmptySiteConfig();

    /// @notice Emitted when liquidation executes
    /// @param liquidator Address executing liquidation
    /// @param user Address being liquidated
    /// @param debtAsset Asset being repaid (USDC)
    /// @param debtRepaid Amount of debt repaid
    /// @param collateralSeized Amount of collateral seized
    /// @param liquidationBonus Bonus paid to liquidator
    event LiquidationExecuted(
        address indexed liquidator,
        address indexed user,
        address indexed debtAsset,
        uint256 debtRepaid,
        uint256 collateralSeized,
        uint256 liquidationBonus
    );

    /**
     * @notice Liquidates an insolvent position
     * @dev Main entry point for liquidators. Not called via hooks.
     * @param collateralAsset Asset to seize (YES or NO token)
     * @param debtAsset Asset to repay (USDC)
     * @param borrower User being liquidated
     * @param maxDebtToCover Maximum debt liquidator wants to repay
     * @param receiveShareToken True to receive sTokens, false for underlying
     * @return collateralSeized Amount of collateral liquidator receives
     * @return debtRepaid Amount of debt actually repaid
     */
    function liquidationCall(
        address collateralAsset,
        address debtAsset,
        address borrower,
        uint256 maxDebtToCover,
        bool receiveShareToken
    ) external returns (uint256 collateralSeized, uint256 debtRepaid);

    /**
     * @notice Calculates maximum liquidation amounts
     * @dev Useful for liquidation bots
     * @param borrower User to check
     * @return collateralToLiquidate Maximum collateral that can be seized
     * @return debtToRepay Maximum debt that can be repaid
     * @return shareTokenRequired True if must receive sTokens (can't unwrap)
     */
    function maxLiquidation(
        address borrower
    )
        external
        view
        returns (
            uint256 collateralToLiquidate,
            uint256 debtToRepay,
            bool shareTokenRequired
        );

    /**
     * @notice Previews liquidation outcome
     * @param borrower User to liquidate
     * @param debtAsset Debt asset to repay
     * @param debtAmount Amount of debt to repay
     * @return collateralAmount Collateral that would be seized
     * @return liquidationBonus Bonus liquidator would receive
     * @return newLTV User's LTV after liquidation
     */
    function previewLiquidation(
        address borrower,
        address debtAsset,
        uint256 debtAmount
    )
        external
        view
        returns (
            uint256 collateralAmount,
            uint256 liquidationBonus,
            uint256 newLTV
        );

    /**
     * @notice Gets liquidation target LTV for this Site
     * @dev After liquidation, user's LTV should be at or below this
     * @return Target LTV in basis points
     */
    function getLiquidationTargetLtv() external view returns (uint256);
}
