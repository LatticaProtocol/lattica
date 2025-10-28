// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface ILiquidationExecutor {
    /**
     * @notice Parameters for liquidation with swap
     * @dev All data needed for liquidation + DEX swap
     */
    struct LiquidationParams {
        ISite site; // Site where liquidation occurs
        address user; // User to liquidate
        address collateralAsset; // Collateral to seize
        uint256 maxDebtToCover; // Max debt liquidator wants to cover
        address swapper; // ISwapper instance for DEX integration
        bytes swapData; // Swap parameters
    }

    /**
     * @notice Executes liquidation with immediate swap to USDC
     * @dev Uses normal liquidation, then swaps collateral to USDC
     * @param params Liquidation parameters
     * @return profit Profit made by liquidator (in USDC)
     */
    function executeLiquidationWithSwap(LiquidationParams calldata params) external returns (uint256 profit);

    /**
     * @notice Executes flash liquidation with swap
     * @dev Zero capital needed. Receives collateral, swaps, repays debt.
     * @param params Liquidation parameters
     * @return profit Profit made by liquidator (in USDC)
     */
    function executeFlashLiquidationWithSwap(LiquidationParams calldata params) external returns (uint256 profit);
}
