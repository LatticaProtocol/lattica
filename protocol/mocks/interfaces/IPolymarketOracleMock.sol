// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IPolymarketOracleMock {
    function priceYes() external view returns (uint256); // 1e18 = $1
    function priceNo() external view returns (uint256);
    function isResolved() external view returns (bool);
    function yesWins() external view returns (bool);
}
