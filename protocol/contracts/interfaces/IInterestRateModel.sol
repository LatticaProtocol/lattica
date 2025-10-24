// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IInterestRateModel {
    /**
     * @notice Pool state for interest calculations
     * @dev All data needed to calculate current rates
     */
    struct PoolState {
        uint256 totalDeposits; // Total deposits in pool
        uint256 totalBorrows; // Total borrows from pool
        uint256 yesPoolBalance; // YES token pool balance
        uint256 noPoolBalance; // NO token pool balance
    }

    /**
     * @notice Rate breakdown for transparency
     * @dev Shows how final rate is calculated
     */
    struct RateBreakdown {
        uint256 baseRate; // Base rate component
        uint256 utilizationRate; // Rate from utilization
        uint256 poolBalanceAdjustment; // Adjustment from YES/NO imbalance
        uint256 finalRate; // Final calculated rate
    }

    /**
     * @notice Calculates current borrow rate
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
     * @dev Useful for UI and debugging
     * @param state Current pool state
     * @return RateBreakdown struct with all components
     */
    function getRateBreakdown(
        PoolState calldata state
    ) external view returns (RateBreakdown memory);

    /**
     * @notice Calculates compound interest
     * @dev Helper for off-chain calculations
     * @param principal Starting amount
     * @param rate Interest rate per year (in ray, 1e27 = 100%)
     * @param timeElapsed Time in seconds
     * @return Final amount after compound interest
     */
    function calculateCompoundInterest(
        uint256 principal,
        uint256 rate,
        uint256 timeElapsed
    ) external pure returns (uint256);

    /**
     * @notice Calculates pool state from raw data
     * @dev Helper to construct PoolState struct
     * @param totalDeposits Total deposits
     * @param totalBorrows Total borrows
     * @param yesPoolBalance YES token balance
     * @param noPoolBalance NO token balance
     * @return PoolState struct
     */
    function calculatePoolState(
        uint256 totalDeposits,
        uint256 totalBorrows,
        uint256 yesPoolBalance,
        uint256 noPoolBalance
    ) external view returns (PoolState memory);

    /**
     * @notice Gets base rate per year
     * @dev Rate at 0% utilization
     * @return Base rate in ray (1e27 = 100%)
     */
    function baseRatePerYear() external view returns (uint256);

    /**
     * @notice Gets rate multiplier per year
     * @dev Slope of interest rate curve before kink
     * @return Multiplier in ray
     */
    function multiplierPerYear() external view returns (uint256);

    /**
     * @notice Gets jump multiplier per year
     * @dev Slope of interest rate curve after kink
     * @return Jump multiplier in ray
     */
    function jumpMultiplierPerYear() external view returns (uint256);

    /**
     * @notice Gets kink utilization point
     * @dev Utilization where slope changes (e.g., 80% = 8000 basis points)
     * @return Kink in basis points
     */
    function kink() external view returns (uint256);
}
