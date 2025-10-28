// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IPolymarketOracle.sol";

interface IOracleRegistry {
    /// @notice Emitted when oracle is set for a condition
    /// @param conditionId Polymarket condition ID
    /// @param oracle Oracle contract address
    event OracleSet(bytes32 indexed conditionId, IPolymarketOracle indexed oracle);

    /// @notice Emitted when oracle updates price
    /// @param conditionId Polymarket condition ID
    /// @param yesPrice YES token price
    /// @param noPrice NO token price
    event OraclePriceUpdate(bytes32 indexed conditionId, uint256 yesPrice, uint256 noPrice);

    /**
     * @notice Sets oracle for a condition
     * @dev Only callable by ORACLE_MANAGER_ROLE
     * @param conditionId Polymarket condition ID
     * @param oracle IPolymarketOracle instance
     */
    function setOracle(bytes32 conditionId, IPolymarketOracle oracle) external;

    /**
     * @notice Gets oracle for a condition
     * @param conditionId Polymarket condition ID
     * @return IPolymarketOracle instance, or IPolymarketOracle(address(0)) if none
     */
    function getOracle(bytes32 conditionId) external view returns (IPolymarketOracle);

    /**
     * @notice Gets YES token price
     * @dev Price in USDC terms (6 decimals). E.g., 0.75 YES = 750000
     * @param conditionId Polymarket condition ID
     * @return YES token price
     */
    function getYesPrice(bytes32 conditionId) external view returns (uint256);

    /**
     * @notice Gets NO token price
     * @dev Price in USDC terms (6 decimals)
     * @param conditionId Polymarket condition ID
     * @return NO token price
     */
    function getNoPrice(bytes32 conditionId) external view returns (uint256);

    /**
     * @notice Gets both YES and NO prices
     * @param conditionId Polymarket condition ID
     * @return yesPrice YES token price
     * @return noPrice NO token price
     */
    function getPrices(bytes32 conditionId) external view returns (uint256 yesPrice, uint256 noPrice);

    /**
     * @notice Checks if market is resolved
     * @param conditionId Polymarket condition ID
     * @return True if resolved, false if still trading
     */
    function isResolved(bytes32 conditionId) external view returns (bool);

    /**
     * @notice Gets resolution outcome
     * @dev Only valid if isResolved() == true
     * @param conditionId Polymarket condition ID
     * @return yesWon True if YES won, false if NO won
     */
    function getResolution(bytes32 conditionId) external view returns (bool yesWon);

    /**
     * @notice Checks if price data is fresh
     * @dev Returns false if price is stale (older than maxPriceAge)
     * @param conditionId Polymarket condition ID
     * @return True if price is fresh
     */
    function isPriceFresh(bytes32 conditionId) external view returns (bool);
}
