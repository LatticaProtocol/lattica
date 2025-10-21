// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IInterestRateModel {
    /**
     * @notice Pool state for rate calculations
     * @dev Extended to support pool balance incentives
     */
    struct PoolState {
        uint256 totalDeposits; // Total deposits in pool
        uint256 totalBorrows; // Total borrowed amount
        uint256 yesPoolBalance; // YES collateral balance
        uint256 noPoolBalance; // NO collateral balance
    }

    /**
     * @notice Rate breakdown for transparency
     * @dev Shows components of final rate calculation
     */
    struct RateBreakdown {
        uint256 baseRate; // Base rate component
        uint256 utilizationRate; // Utilization-based component
        uint256 poolBalanceAdjustment; // Adjustment for imbalanced pools
        uint256 finalRate; // Combined final rate
    }

    /**
     * @notice Calculates current borrow rate
     * @dev Rate increases with utilization, jumps at kink point
     * @param totalDeposits Total deposited in pool
     * @param totalBorrows Total borrowed from pool
     * @return Borrow rate per year in ray (1e27 = 100%)
     */
    function getBorrowRate(
        uint256 totalDeposits,
        uint256 totalBorrows
    ) external view returns (uint256);

    /**
     * @notice Calculates current supply rate
     * @dev Supply rate = borrow rate * utilization * (1 - protocolFee)
     * @param totalDeposits Total deposited in pool
     * @param totalBorrows Total borrowed from pool
     * @param protocolFeeBps Protocol fee in basis points
     * @return Supply rate per year in ray (1e27 = 100%)
     */
    function getSupplyRate(
        uint256 totalDeposits,
        uint256 totalBorrows,
        uint256 protocolFeeBps
    ) external view returns (uint256);

    /**
     * @notice Gets detailed rate breakdown
     * @param state Current pool state
     * @return Breakdown of rate components
     */
    function getRateBreakdown(
        PoolState calldata state
    ) external view returns (RateBreakdown memory);

    /**
     * @notice Calculates compound interest
     * @dev Interest = principal * (1 + rate)^time
     * @param principal Starting principal
     * @param rate Interest rate per second
     * @param timeElapsed Seconds elapsed
     * @return Total amount with interest
     */
    function calculateCompoundInterest(
        uint256 principal,
        uint256 rate,
        uint256 timeElapsed
    ) external pure returns (uint256);

    /**
     * @notice Constructs pool state from parameters
     * @dev Helper for rate calculations
     * @param totalDeposits Total deposits
     * @param totalBorrows Total borrows
     * @param yesPoolBalance YES collateral balance
     * @param noPoolBalance NO collateral balance
     * @return Constructed pool state
     */
    function calculatePoolState(
        uint256 totalDeposits,
        uint256 totalBorrows,
        uint256 yesPoolBalance,
        uint256 noPoolBalance
    ) external view returns (PoolState memory);

    // Model parameters
    function baseRatePerYear() external view returns (uint256);
    function multiplierPerYear() external view returns (uint256);
    function jumpMultiplierPerYear() external view returns (uint256);
    function kink() external view returns (uint256);
}
