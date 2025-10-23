// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IHookReceiver.sol";

interface IAnalyticsHookReceiver is IHookReceiver {
    /**
     * @notice Aggregated metrics for a Site
     * @dev All cumulative metrics for analytics dashboards
     */
    struct SiteMetrics {
        uint256 totalDeposits; // Cumulative deposits (all time)
        uint256 totalBorrows; // Cumulative borrows (all time)
        uint256 totalRepayments; // Cumulative repayments
        uint256 totalWithdrawals; // Cumulative withdrawals
        uint256 totalLiquidations; // Number of liquidations
        uint256 totalLiquidationVolume; // Total value liquidated
        uint256 uniqueDepositors; // Unique depositor count
        uint256 uniqueBorrowers; // Unique borrower count
        uint256 lastUpdateTimestamp; // Last metric update
    }

    /**
     * @notice User-specific metrics
     * @dev All historical data for a user across a Site
     */
    struct UserMetrics {
        uint256 totalDeposited; // User's cumulative deposits
        uint256 totalBorrowed; // User's cumulative borrows
        uint256 totalRepaid; // User's cumulative repayments
        uint256 totalWithdrawn; // User's cumulative withdrawals
        uint256 liquidationCount; // Times user was liquidated
        uint256 firstInteractionTime; // First interaction timestamp
        uint256 lastInteractionTime; // Last interaction timestamp
    }

    /**
     * @notice Gets metrics for a Site
     * @param site ISite to query
     * @return SiteMetrics struct with all cumulative data
     */
    function getSiteMetrics(
        ISite site
    ) external view returns (SiteMetrics memory);

    /**
     * @notice Gets metrics for a user across a Site
     * @param site ISite to query
     * @param user User to query
     * @return UserMetrics struct with user's historical data
     */
    function getUserMetrics(
        ISite site,
        address user
    ) external view returns (UserMetrics memory);

    /**
     * @notice Gets protocol-wide aggregated metrics
     * @return totalValueLocked Total value locked across all Sites
     * @return totalBorrows Total borrows across all Sites
     * @return avgUtilization Average utilization rate
     * @return numberOfSites Number of active Sites
     */
    function getProtocolMetrics()
        external
        view
        returns (
            uint256 totalValueLocked,
            uint256 totalBorrows,
            uint256 avgUtilization,
            uint256 numberOfSites
        );

    /**
     * @notice Gets top depositors in a Site
     * @param site ISite to query
     * @param limit Number of top depositors to return
     * @return users Array of user addresses
     * @return amounts Array of deposit amounts
     */
    function getTopDepositors(
        ISite site,
        uint256 limit
    ) external view returns (address[] memory users, uint256[] memory amounts);

    /**
     * @notice Gets recent activity in a Site
     * @param site ISite to query
     * @param limit Number of recent actions to return
     * @return actions Array of action IDs
     * @return users Array of user addresses
     * @return amounts Array of amounts
     * @return timestamps Array of timestamps
     */
    function getRecentActivity(
        ISite site,
        uint256 limit
    )
        external
        view
        returns (
            uint256[] memory actions,
            address[] memory users,
            uint256[] memory amounts,
            uint256[] memory timestamps
        );
}
