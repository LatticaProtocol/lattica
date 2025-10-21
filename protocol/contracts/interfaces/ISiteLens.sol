// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface ISiteLens {
    /**
     * @notice User's position in a single Site
     * @dev Complete portfolio view for one market
     */
    struct UserPortfolio {
        ISite site; // ISite instance
        bytes32 conditionId; // Polymarket condition ID
        uint256 yesCollateral; // YES collateral balance
        uint256 noCollateral; // NO collateral balance
        uint256 usdcDebt; // USDC debt balance
        uint256 healthFactor; // Health factor (1e18 = 100%)
        uint256 ltv; // Current LTV in basis points
    }

    /**
     * @notice Gets user's positions across all Sites
     * @dev Aggregates portfolio for UI display
     * @param user User address
     * @return Array of user positions
     */
    function getUserPositionAcrossSites(
        address user
    ) external view returns (UserPortfolio[] memory);

    /**
     * @notice Gets user's overall health
     * @dev Aggregates health across all Sites
     * @param user User address
     * @return healthFactor Weighted average health factor
     * @return isSolvent True if user is solvent everywhere
     */
    function getUserHealth(
        address user
    ) external view returns (uint256 healthFactor, bool isSolvent);

    /**
     * @notice Gets maximum withdrawable amount
     * @param site ISite instance
     * @param asset Asset to withdraw
     * @param user User address
     * @return Maximum amount user can withdraw while staying solvent
     */
    function getMaxWithdrawable(
        ISite site,
        address asset,
        address user
    ) external view returns (uint256);

    /**
     * @notice Gets maximum borrowable amount
     * @param site ISite instance
     * @param user User address
     * @return Maximum USDC user can borrow while staying solvent
     */
    function getMaxBorrowable(
        ISite site,
        address user
    ) external view returns (uint256);

    /**
     * @notice Gets all APYs for a Site
     * @param site ISite instance
     * @return yesSupplyAPY YES collateral supply APY in basis points
     * @return noSupplyAPY NO collateral supply APY in basis points
     * @return usdcSupplyAPY USDC supply APY in basis points
     * @return usdcBorrowAPY USDC borrow APY in basis points
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
     * @notice Gets total value locked in Site
     * @param site ISite instance
     * @return TVL in USD
     */
    function getTotalValueLocked(ISite site) external view returns (uint256);

    /**
     * @notice Gets total protocol TVL
     * @return Total TVL across all Sites in USD
     */
    function getProtocolTVL() external view returns (uint256);

    /**
     * @notice Previews liquidation amounts
     * @param site ISite instance
     * @param user User to liquidate
     * @param repayAmount Amount of debt to repay
     * @return seizedCollateral Amount of collateral liquidator receives
     * @return liquidationBonus Bonus amount (penalty from user)
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
     * @param site ISite instance
     * @param user User address
     * @return True if user can be liquidated
     */
    function isLiquidatable(
        ISite site,
        address user
    ) external view returns (bool);
}
