// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IBaseSite.sol";
import "./IFlashLiquidationReceiver.sol";
import "./IHookReceiver.sol";
import "./IInterestRateModel.sol";

interface ISite {
    function ctf() external returns (address);
    function yesId() external view returns (uint256);
    function noId() external view returns (uint256);
    function borrowToken() external view returns (address);

    function maxLtvBps() external view returns (uint256);
    function liqThresholdBps() external view returns (uint256);
    function liqBonusBps() external view returns (uint256);

    function deposit(uint256 tokenId, uint256 amount, bool collateralOnly) external returns (uint256 sharesMinted);
    function withdraw(uint256 tokenId, uint256 amount, bool collateralOnly) external returns (uint256 amountOut);

    function borrow(uint256 usdcAmount) external returns (uint256 debtSharesMinted);
    function repay(uint256 usdcAmount) external returns (uint256 debtSharesBurned);

    // liqquidator pays for
    function repayFor(address user, uint256 usdcAmount) external returns (uint256 debtSharesBurned);

    function liquidate(address user, uint256 prepayUsdcAmount) external returns (uint256 yesSeized, uint256 noSeized);

    // views
    function isResolved() external view returns (bool);
    function prices() external view returns (uint256 yesPriceUsdc1e18, uint256 noPricesUsdc1e18);
    function collateralValueUsd(address user) external view returns (uint256); // USD1e18
    function debtValueUsd(address user) external view returns (uint256);

    function getUserLTVBps(address user) external view returns (uint256);
    function isSolvent(address user) external view returns (bool);

    function maxWithdraw(address user, uint256 tokenId) external view returns (uint256);
    function maxBorrow(address user) external view returns (uint256);

    // for IRM
    function totalColltaeralUsd() external view returns (uint256);
    function totalBorrowedUsd() external view returns (uint256);
    function borrowIndexRay() external view returns (uint256);
}
