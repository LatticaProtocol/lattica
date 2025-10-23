// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IFlashLiquidationReceiver.sol";
import "./IHookReceiver.sol";

interface IFlashLiquidation is IHookReceiver {
    /**
     * @notice Executes flash liquidation with callback
     * @dev Process: 1) Send collateral, 2) Callback, 3) Verify debt repaid
     * @param user User to liquidate
     * @param collateralAsset Collateral to seize
     * @param maxDebtToCover Maximum debt to repay
     * @param receiver Address implementing IFlashLiquidationReceiver
     * @param liquidationData Arbitrary data to pass to callback
     * @return collateralSeized Amount of collateral seized
     * @return debtRepaid Amount of debt repaid
     */
    function flashLiquidate(
        address user,
        address collateralAsset,
        uint256 maxDebtToCover,
        IFlashLiquidationReceiver receiver,
        bytes calldata liquidationData
    ) external returns (uint256 collateralSeized, uint256 debtRepaid);

    /**
     * @notice Gets flash liquidation fee
     * @dev Fee charged on top of liquidation penalty
     * @return Fee in basis points
     */
    function getFlashLiquidationFee() external view returns (uint256);
}
