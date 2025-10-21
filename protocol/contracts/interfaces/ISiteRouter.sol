// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface ISiteRouter {
    /**
     * @notice Deposits collateral and borrows in single transaction
     * @dev Saves gas vs two separate transactions
     * @param site ISite instance
     * @param collateralAsset Asset to deposit (YES/NO)
     * @param collateralAmount Amount to deposit
     * @param borrowAsset Asset to borrow (USDC)
     * @param borrowAmount Amount to borrow
     */
    function depositAndBorrow(
        ISite site,
        address collateralAsset,
        uint256 collateralAmount,
        address borrowAsset,
        uint256 borrowAmount
    ) external;

    /**
     * @notice Repays debt and withdraws collateral in single transaction
     * @param site ISite instance
     * @param debtAsset Asset to repay (USDC)
     * @param repayAmount Amount to repay
     * @param collateralAsset Asset to withdraw
     * @param withdrawAmount Amount to withdraw
     */
    function repayAndWithdraw(
        ISite site,
        address debtAsset,
        uint256 repayAmount,
        address collateralAsset,
        uint256 withdrawAmount
    ) external;
}
