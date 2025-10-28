// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {IInterestRateModel} from "../interfaces/IInterestRateModel.sol";
import {IBaseSite} from "../interfaces/IBaseSite.sol";

/// @notice y = base + slope * utilization
contract LinearIRM is IInterestRateModel {
    uint256 public immutable base;
    uint256 public immutable slope;

    constructor(uint256 base_, uint256 slope_) {
        base = base_;
        slope = slope_;
    }
    /// @inheritdoc IInterestRateModel

    function getSupplyRate(uint256 totalDeposits, uint256 totalBorrows, uint256 protocolFeeBps)
        external
        view
        override
        returns (uint256)
    {}

    /// @inheritdoc IInterestRateModel
    function getBorrowRate(uint256 totalDeposits, uint256 totalBorrows) external view returns (uint256) {}

    function getRates(IBaseSite.UtilizationData memory u)
        external
        view
        returns (uint256 borrowApr, uint256 supplyApr)
    {
        uint256 util = (u.totalDeposits == 0) ? 0 : (u.totalBorrowAmount * 1e18 / u.totalDeposits);
        borrowApr = base + (slope * util / 1e18);
        // supply APR (ignoring protocol fee in MVP): borrowApr * util
        supplyApr = borrowApr * util / 1e18;
    }
}
