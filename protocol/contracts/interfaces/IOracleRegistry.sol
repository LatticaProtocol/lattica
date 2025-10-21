// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IPolymarketOracle.sol";

interface IOracleRegistry {
    /// @notice Emitted when an oracle is assigned to a condition
    /// @param conditionId Polymarket condition ID
    /// @param oracle IPolymarketOracle implementation
    event OracleSet(
        bytes32 indexed conditionId,
        IPolymarketOracle indexed oracle
    );

    /// @notice Emitted when prices are updated
    /// @param conditionId Polymarket condition ID
    /// @param yesPrice YES token price in basis points
    /// @param noPrice NO token price in basis points
    event OraclePriceUpdate(
        bytes32 indexed conditionId,
        uint256 yesPrice,
        uint256 noPrice
    );

    /**
     * @notice Assigns an oracle to a condition
     * @dev Only callable by ORACLE_MANAGER_ROLE
     * @param conditionId Polymarket condition ID
     * @param oracle IPolymarketOracle implementation
     */
    function setOracle(bytes32 conditionId, IPolymarketOracle oracle) external;

    /**
     * @notice Gets the oracle for a condition
     * @param conditionId Polymarket condition ID
     * @return IPolymarketOracle instance, or IPolymarketOracle(address(0)) if none set
     */
    function getOracle(
        bytes32 conditionId
    ) external view returns (IPolymarketOracle);

    /**
     * @notice Gets YES token price
     * @param conditionId Polymarket condition ID
     * @return Price in basis points (10000 = $1.00)
     */
    function getYesPrice(bytes32 conditionId) external view returns (uint256);

    /**
     * @notice Gets NO token price
     * @param conditionId Polymarket condition ID
     * @return Price in basis points (10000 = $1.00)
     */
    function getNoPrice(bytes32 conditionId) external view returns (uint256);

    /**
     * @notice Gets both prices at once
     * @param conditionId Polymarket condition ID
     * @return yesPrice YES price in basis points
     * @return noPrice NO price in basis points
     */
    function getPrices(
        bytes32 conditionId
    ) external view returns (uint256 yesPrice, uint256 noPrice);

    /**
     * @notice Checks if market has been resolved
     * @param conditionId Polymarket condition ID
     * @return True if resolved
     */
    function isResolved(bytes32 conditionId) external view returns (bool);

    /**
     * @notice Gets resolution result
     * @param conditionId Polymarket condition ID
     * @return yesWon True if YES won, false if NO won
     */
    function getResolution(
        bytes32 conditionId
    ) external view returns (bool yesWon);

    /**
     * @notice Checks if prices are fresh (not stale)
     * @param conditionId Polymarket condition ID
     * @return True if prices are recent enough
     */
    function isPriceFresh(bytes32 conditionId) external view returns (bool);
}
