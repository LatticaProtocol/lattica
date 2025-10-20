// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IFlashLiquidationReceiver {
    /**
     * @notice Callback executed during flash liquidation
     * @dev Must repay debt by end of this function or tx reverts
     * @param user Address being liquidated
     * @param assets Array of assets involved (debt + collateral)
     * @param receivedCollaterals Array of collateral amounts received
     * @param shareAmountsToRepaid Array of debt shares that must be repaid
     * @param flashReceiverData Arbitrary data passed by liquidator
     */
    function siteLiquidationCallback(
        address user,
        address[] calldata assets,
        uint256[] calldata receivedCollaterals,
        uint256[] calldata shareAmountsToRepaid,
        bytes calldata flashReceiverData
    ) external;
}
