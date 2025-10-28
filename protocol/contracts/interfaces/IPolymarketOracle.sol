// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IPolymarketOracle {
    /**
     * @notice Market data for a condition
     * @dev All data needed to price collateral and check resolution
     */
    struct MarketData {
        uint256 yesPrice; // YES token price in USDC (6 decimals)
        uint256 noPrice; // NO token price in USDC (6 decimals)
        uint64 lastUpdateTimestamp; // Last price update timestamp
        bool isResolved; // True if market resolved
        bool yesWon; // True if YES won (only valid if isResolved)
    }

    /// @notice Emitted when price is updated
    /// @param conditionId Polymarket condition ID
    /// @param yesPrice New YES price
    /// @param noPrice New NO price
    /// @param timestamp Update timestamp
    event PriceUpdate(bytes32 indexed conditionId, uint256 yesPrice, uint256 noPrice, uint64 timestamp);

    /// @notice Emitted when market resolves
    /// @param conditionId Polymarket condition ID
    /// @param yesWon True if YES won, false if NO won
    event MarketResolved(bytes32 indexed conditionId, bool yesWon);

    /**
     * @notice Updates price for a condition
     * @dev Only callable by ORACLE_UPDATER_ROLE. Can be automated by Chainlink, API3, etc.
     * @param conditionId Polymarket condition ID
     * @param yesPrice New YES price in USDC (6 decimals)
     * @param noPrice New NO price in USDC (6 decimals)
     */
    function updatePrice(bytes32 conditionId, uint256 yesPrice, uint256 noPrice) external;

    /**
     * @notice Resolves market
     * @dev Only callable by ORACLE_RESOLVER_ROLE. Typically called after Polymarket CTF resolves.
     * @param conditionId Polymarket condition ID
     * @param yesWon True if YES won, false if NO won
     */
    function resolveMarket(bytes32 conditionId, bool yesWon) external;

    /**
     * @notice Gets complete market data
     * @param conditionId Polymarket condition ID
     * @return MarketData struct with all current data
     */
    function getMarketData(bytes32 conditionId) external view returns (MarketData memory);

    /**
     * @notice Gets YES token price
     * @param conditionId Polymarket condition ID
     * @return YES price in USDC (6 decimals)
     */
    function getYesPrice(bytes32 conditionId) external view returns (uint256);

    /**
     * @notice Gets NO token price
     * @param conditionId Polymarket condition ID
     * @return NO price in USDC (6 decimals)
     */
    function getNoPrice(bytes32 conditionId) external view returns (uint256);

    /**
     * @notice Checks if market is resolved
     * @param conditionId Polymarket condition ID
     * @return True if resolved
     */
    function isResolved(bytes32 conditionId) external view returns (bool);

    /**
     * @notice Gets resolution outcome
     * @dev Reverts if market not resolved
     * @param conditionId Polymarket condition ID
     * @return yesWon True if YES won, false if NO won
     */
    function getResolution(bytes32 conditionId) external view returns (bool yesWon);

    /**
     * @notice Gets estimated time to resolution
     * @dev Returns 0 if already resolved
     * @param conditionId Polymarket condition ID
     * @return Seconds until expected resolution
     */
    function getTimeToResolution(bytes32 conditionId) external view returns (uint256);

    /**
     * @notice Checks if price is fresh (not stale)
     * @param conditionId Polymarket condition ID
     * @return True if price was updated within maxPriceAge
     */
    function isPriceFresh(bytes32 conditionId) external view returns (bool);

    /**
     * @notice Gets maximum price age before considered stale
     * @return Age in seconds
     */
    function maxPriceAge() external view returns (uint256);

    /**
     * @notice Sets maximum price age
     * @dev Only callable by owner
     * @param age New max age in seconds
     */
    function setMaxPriceAge(uint256 age) external;
}
