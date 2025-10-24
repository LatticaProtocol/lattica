// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface ISiteRouter {
    /**
     * @notice Deposits collateral and borrows in one transaction
     * @dev User approves router once, router handles both steps
     * @param site ISite to interact with
     * @param collateralAsset Asset to deposit (YES or NO token)
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
     * @notice Repays debt and withdraws collateral in one transaction
     * @dev Useful for closing positions atomically
     * @param site ISite to interact with
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

    /**
     * @notice Batch deposits across multiple Sites
     * @dev Saves gas vs individual transactions
     * @param sites Array of ISite instances
     * @param assets Array of assets to deposit
     * @param amounts Array of amounts to deposit
     * @param collateralOnly Array of collateral-only flags
     */
    function batchDeposit(
        ISite[] calldata sites,
        address[] calldata assets,
        uint256[] calldata amounts,
        bool[] calldata collateralOnly
    ) external;

    /**
     * @notice Batch withdrawals across multiple Sites
     * @param sites Array of ISite instances
     * @param assets Array of assets to withdraw
     * @param shares Array of share amounts to burn
     * @param collateralOnly Array of collateral-only flags
     */
    function batchWithdraw(
        ISite[] calldata sites,
        address[] calldata assets,
        uint256[] calldata shares,
        bool[] calldata collateralOnly
    ) external;

    /**
     * @notice Migrates position between Sites
     * @dev Withdraws from one Site and deposits to another atomically
     * @param fromSite Source ISite
     * @param toSite Destination ISite
     * @param asset Asset to migrate
     * @param amount Amount to migrate
     */
    function migratePosition(
        ISite fromSite,
        ISite toSite,
        address asset,
        uint256 amount
    ) external;
}
