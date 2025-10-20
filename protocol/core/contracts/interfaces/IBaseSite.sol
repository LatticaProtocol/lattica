// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IBaseSite {
    /// @notice Status of an asset within a Site
    enum AssetStatus {
        Undefined, // Asset has not been initialized
        Active, // Asset is active and can be used
        Removed // Asset has been removed and cannot be used
    }

    /**
     * @notice Storage for asset-specific data
     * @dev Tracks all token addresses and total amounts for an asset
     */
    struct AssetStorage {
        address collateralToken; // Share token for borrowable collateral
        address collateralOnlyToken; // Share token for protected collateral
        address debtToken; // Debt token (uses IERC20R)
        uint256 totalDeposits; // Total deposits (borrowable collateral)
        uint256 collateralOnlyDeposits; // Total protected collateral deposits
        uint256 totalBorrowAmount; // Total amount borrowed
    }

    /**
     * @notice Interest accrual data for an asset
     * @dev Tracks fees and timestamps for interest calculations
     */
    struct AssetInterestData {
        uint256 harvestedProtocolFees; // Protocol fees already collected
        uint256 protocolFees; // Protocol fees pending collection
        uint64 interestRateTimestamp; // Last time interest was accrued
        AssetStatus status; // Current status of the asset
    }

    /**
     * @notice User's position in a specific asset
     * @dev All amounts are in underlying token units (not shares)
     */
    struct UserPosition {
        uint256 collateralAmount; // User's borrowable collateral
        uint256 collateralOnlyAmount; // User's protected collateral
        uint256 debtAmount; // User's debt amount
    }

    /**
     * @notice Utilization data for interest rate calculations
     * @dev Used by interest rate models to determine current rates
     */
    struct UtilizationData {
        uint256 totalDeposits; // Total deposits available
        uint256 totalBorrowAmount; // Total amount borrowed
        uint64 interestRateTimestamp; // Last interest accrual timestamp
    }

    /// @notice Emitted when a user deposits collateral
    /// @param asset Address of the asset deposited
    /// @param depositor Address of the user depositing
    /// @param amount Amount of underlying tokens deposited
    /// @param collateralOnly True if deposit is protected collateral, false if borrowable
    event Deposit(
        address indexed asset,
        address indexed depositor,
        uint256 amount,
        bool collateralOnly
    );

    /// @notice Emitted when a user withdraws collateral
    /// @param asset Address of the asset withdrawn
    /// @param depositor Address of the user withdrawing
    /// @param amount Amount of underlying tokens withdrawn
    /// @param collateralOnly True if withdrawing protected collateral, false if borrowable
    event Withdraw(
        address indexed asset,
        address indexed depositor,
        uint256 amount,
        bool collateralOnly
    );

    /// @notice Emitted when a user borrows
    /// @param asset Address of the asset borrowed (always USDC for PolyLend)
    /// @param borrower Address of the user borrowing
    /// @param amount Amount of underlying tokens borrowed
    event Borrow(
        address indexed asset,
        address indexed borrower,
        uint256 amount
    );

    /// @notice Emitted when a user repays debt
    /// @param asset Address of the asset repaid
    /// @param borrower Address of the user repaying
    /// @param amount Amount of underlying tokens repaid
    event Repay(
        address indexed asset,
        address indexed borrower,
        uint256 amount
    );

    /// @notice Emitted when a user is liquidated
    /// @param asset Address of the debt asset being repaid
    /// @param user Address of the user being liquidated
    /// @param shareAmountRepaid Amount of debt shares repaid by liquidator
    /// @param seizedCollateral Amount of collateral seized
    event Liquidate(
        address indexed asset,
        address indexed user,
        uint256 shareAmountRepaid,
        uint256 seizedCollateral
    );

    /**
     * @notice Gets storage data for an asset
     * @param asset Address of the asset to query
     * @return AssetStorage struct containing token addresses and totals
     */
    function assetStorage(
        address asset
    ) external view returns (AssetStorage memory);

    /**
     * @notice Gets interest data for an asset
     * @param asset Address of the asset to query
     * @return AssetInterestData struct containing fee and timestamp data
     */
    function interestData(
        address asset
    ) external view returns (AssetInterestData memory);

    /**
     * @notice Gets utilization data for an asset
     * @dev Used by interest rate models and UI
     * @param asset Address of the asset to query
     * @return UtilizationData struct for interest calculations
     */
    function utilizationData(
        address asset
    ) external view returns (UtilizationData memory);

    /**
     * @notice Gets a user's complete position for an asset
     * @param asset Address of the asset to query
     * @param user Address of the user
     * @return UserPosition struct containing all position data
     */
    function getUserPosition(
        address asset,
        address user
    ) external view returns (UserPosition memory);

    /**
     * @notice Gets user's borrowable collateral balance in underlying tokens
     * @param asset Address of the collateral asset
     * @param user Address of the user
     * @return Balance in underlying token units
     */
    function collateralBalanceOfUnderlying(
        address asset,
        address user
    ) external view returns (uint256);

    /**
     * @notice Gets user's protected collateral balance in underlying tokens
     * @param asset Address of the collateral asset
     * @param user Address of the user
     * @return Balance in underlying token units
     */
    function collateralOnlyBalanceOfUnderlying(
        address asset,
        address user
    ) external view returns (uint256);

    /**
     * @notice Gets user's debt balance in underlying tokens
     * @param asset Address of the debt asset
     * @param user Address of the user
     * @return Debt balance in underlying token units
     */
    function debtBalanceOfUnderlying(
        address asset,
        address user
    ) external view returns (uint256);

    /**
     * @notice Checks if a user is solvent (not liquidatable)
     * @dev Returns true if user's LTV is below liquidation threshold
     * @param user Address of the user to check
     * @return True if solvent, false if liquidatable
     */
    function isSolvent(address user) external view returns (bool);

    /**
     * @notice Gets user's current loan-to-value ratio
     * @dev Returns LTV in basis points (e.g., 7500 = 75%)
     * @param user Address of the user
     * @return Current LTV in basis points
     */
    function getUserLTV(address user) external view returns (uint256);

    /**
     * @notice Gets user's liquidation threshold
     * @dev Weighted average of liquidation thresholds across user's collateral
     * @param user Address of the user
     * @return Liquidation threshold in basis points
     */
    function getUserLiquidationThreshold(
        address user
    ) external view returns (uint256);

    /**
     * @notice Calculates maximum amount a user can withdraw while staying solvent
     * @param asset Address of the asset to withdraw
     * @param user Address of the user
     * @return Maximum withdrawable amount in underlying tokens
     */
    function getMaxWithdraw(
        address asset,
        address user
    ) external view returns (uint256);

    /**
     * @notice Calculates maximum amount a user can borrow while staying solvent
     * @param asset Address of the asset to borrow (USDC for PolyLend)
     * @param user Address of the user
     * @return Maximum borrowable amount in underlying tokens
     */
    function getMaxBorrow(
        address asset,
        address user
    ) external view returns (uint256);

    /**
     * @notice Gets the Polymarket condition ID for this Site
     * @return Condition ID bytes32
     */
    function conditionId() external view returns (bytes32);

    /**
     * @notice Gets the YES token address for this market
     * @return Address of the YES share token in Polymarket CTF
     */
    function yesToken() external view returns (address);

    /**
     * @notice Gets the NO token address for this market
     * @return Address of the NO share token in Polymarket CTF
     */
    function noToken() external view returns (address);

    /**
     * @notice Gets the borrowable asset address (always USDC)
     * @return Address of USDC token
     */
    function borrowToken() external view returns (address);

    /**
     * @notice Gets the repository address
     * @return Address of the ISiteRepository contract
     */
    function repository() external view returns (address);

    /**
     * @notice Gets the interest rate model address
     * @return Address of the IInterestRateModel contract for this Site
     */
    function interestRateModel() external view returns (address);
}
