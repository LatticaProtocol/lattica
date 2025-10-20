// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IPolymarketOracle {
    /**
     * @notice Complete market data struct
     * @dev All price data for a market in one struct
     */
    struct MarketData {
        uint256 yesPrice; // YES price in basis points
        uint256 noPrice; // NO price in basis points
        uint64 lastUpdateTimestamp; // Last price update time
        bool isResolved; // True if market resolved
        bool yesWon; // True if YES won (only valid if isResolved)
    }

    /// @notice Emitted when prices are updated
    event PriceUpdate(
        bytes32 indexed conditionId,
        uint256 yesPrice,
        uint256 noPrice,
        uint64 timestamp
    );

    /// @notice Emitted when market resolves
    event MarketResolved(bytes32 indexed conditionId, bool yesWon);

    /**
     * @notice Updates market prices
     * @dev Only callable by ORACLE_MANAGER_ROLE or authorized updater
     * @param conditionId Polymarket condition ID
     * @param yesPrice YES price in basis points
     * @param noPrice NO price in basis points
     */
    function updatePrice(
        bytes32 conditionId,
        uint256 yesPrice,
        uint256 noPrice
    ) external;

    /**
     * @notice Resolves the market
     * @dev Only callable by ORACLE_MANAGER_ROLE. Irreversible.
     * @param conditionId Polymarket condition ID
     * @param yesWon True if YES won, false if NO won
     */
    function resolveMarket(bytes32 conditionId, bool yesWon) external;

    /**
     * @notice Gets complete market data
     * @param conditionId Polymarket condition ID
     * @return Market data struct
     */
    function getMarketData(
        bytes32 conditionId
    ) external view returns (MarketData memory);

    /**
     * @notice Gets YES token price
     * @param conditionId Polymarket condition ID
     * @return Price in basis points
     */
    function getYesPrice(bytes32 conditionId) external view returns (uint256);

    /**
     * @notice Gets NO token price
     * @param conditionId Polymarket condition ID
     * @return Price in basis points
     */
    function getNoPrice(bytes32 conditionId) external view returns (uint256);

    /**
     * @notice Checks if market is resolved
     * @param conditionId Polymarket condition ID
     * @return True if resolved
     */
    function isResolved(bytes32 conditionId) external view returns (bool);

    /**
     * @notice Gets resolution winner
     * @param conditionId Polymarket condition ID
     * @return yesWon True if YES won
     */
    function getResolution(
        bytes32 conditionId
    ) external view returns (bool yesWon);

    /**
     * @notice Gets time until expected resolution
     * @param conditionId Polymarket condition ID
     * @return Seconds until resolution (0 if passed)
     */
    function getTimeToResolution(
        bytes32 conditionId
    ) external view returns (uint256);

    /**
     * @notice Checks if prices are fresh
     * @param conditionId Polymarket condition ID
     * @return True if last update was within maxPriceAge
     */
    function isPriceFresh(bytes32 conditionId) external view returns (bool);

    /**
     * @notice Gets maximum allowed price age
     * @return Age in seconds
     */
    function maxPriceAge() external view returns (uint256);

    /**
     * @notice Sets maximum allowed price age
     * @dev Only callable by ORACLE_MANAGER_ROLE
     * @param age New max age in seconds
     */
    function setMaxPriceAge(uint256 age) external;
}
