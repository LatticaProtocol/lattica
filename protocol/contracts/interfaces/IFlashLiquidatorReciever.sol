// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IFlashLiquidationReceiver {
    /**
     * @notice Called during flash liquidation after collateral is sent
     * @dev Must repay debt by end of callback or tx reverts
     * @param user User being liquidated
     * @param collateralAssets Array of collateral assets received
     * @param collateralAmounts Array of collateral amounts received
     * @param debtAssets Array of debt assets to repay
     * @param debtAmounts Array of debt amounts to repay
     * @param liquidationData Arbitrary data passed by liquidator
     */
    function executeFlashLiquidation(
        address user,
        address[] calldata collateralAssets,
        uint256[] calldata collateralAmounts,
        address[] calldata debtAssets,
        uint256[] calldata debtAmounts,
        bytes calldata liquidationData
    ) external;
}
