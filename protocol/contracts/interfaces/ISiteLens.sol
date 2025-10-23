// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface ISiteLens {
    /**
     * @notice User's complete portfolio across a Site
     * @dev All position data in one struct
     */
    struct UserPortfolio {
        address site; // Site address
        bytes32 conditionId; // Polymarket condition ID
        uint256 yesCollateral; // YES token collateral
        uint256 noCollateral; // NO token collateral
        uint256 usdcDebt; // USDC debt
        uint256 healthFactor; // Health factor (10000 = 100%)
        uint256 ltv; // Current LTV in basis points
    }

    /**
     * @notice Gets user's positions across all Sites
     * @dev Aggregates data from all Sites user has positions in
     * @param user User to query
     * @return Array of UserPortfolio structs
     */
    function getUserPositionAcrossSites(
        address user
    ) external view returns (UserPortfolio[] memory);

    /**
     * @notice Gets user's overall health
     * @dev Aggregates across all Sites
     * @param user User to query
     * @return healthFactor Overall health factor
     * @return isSolvent True if solvent across all Sites
     */
    function getUserHealth(
        address user
    ) external view returns (uint256 healthFactor, bool isSolvent);

    /**
     * @notice Calculates maximum withdrawable amount
     * @dev Considers solvency constraints
     * @param site ISite to query
     * @param asset Asset to withdraw
     * @param user User to query
     * @return Maximum amount user can withdraw while staying solvent
     */
    function getMaxWithdrawable(
        ISite site,
        address asset,
        address user
    ) external view returns (uint256);

    /**
     * @notice Calculates maximum borrowable amount
     * @param site ISite to query
     * @param user User to query
     * @return Maximum amount user can borrow while staying solvent
     */
    function getMaxBorrowable(
        ISite site,
        address user
    ) external view returns (uint256);

    /**
     * @notice Gets all APYs for a Site
     * @param site ISite to query
     * @return yesSupplyAPY YES collateral supply APY
     * @return noSupplyAPY NO collateral supply APY
     * @return usdcSupplyAPY USDC supply APY
     * @return usdcBorrowAPY USDC borrow APY
     */
    function getSiteAPYs(
        ISite site
    )
        external
        view
        returns (
            uint256 yesSupplyAPY,
            uint256 noSupplyAPY,
            uint256 usdcSupplyAPY,
            uint256 usdcBorrowAPY
        );

    /**
     * @notice Gets total value locked in a Site
     * @param site ISite to query
     * @return Total value locked in USDC terms
     */
    function getTotalValueLocked(ISite site) external view returns (uint256);

    /**
     * @notice Gets protocol-wide TVL
     * @return Total value locked across all Sites
     */
    function getProtocolTVL() external view returns (uint256);

    /**
     * @notice Previews liquidation outcome
     * @param site ISite where liquidation would occur
     * @param user User to liquidate
     * @param repayAmount Debt amount to repay
     * @return seizedCollateral Amount of collateral that would be seized
     * @return liquidationBonus Bonus liquidator would receive
     */
    function getLiquidationPreview(
        ISite site,
        address user,
        uint256 repayAmount
    )
        external
        view
        returns (uint256 seizedCollateral, uint256 liquidationBonus);

    /**
     * @notice Checks if user is liquidatable
     * @param site ISite to check
     * @param user User to check
     * @return True if user is insolvent and can be liquidated
     */
    function isLiquidatable(
        ISite site,
        address user
    ) external view returns (bool);
}
