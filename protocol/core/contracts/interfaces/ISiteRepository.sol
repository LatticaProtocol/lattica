// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface ISiteRepository {
    /**
     * @notice Emitted on Site deployment
     * @param site Address of deployed Site contract
     * @param conditionId Polymarket condition ID
     * @param creator Address that triggered Site deployment
     **/
    event SiteCreated(
        address indexed site,
        byte32 indexedConditionId,
        address indexed creator
    );

    /**
     * @notice Emitted when a market is approved for Site creation
     * @param conditionId Polymarket condition ID
     **/
    event MarketApproved(byte32 indexed conditionId);

    /**
     * @notice Emitted when a market proposal is rejected
     * @param conditionId Polymarket condition ID
     **/
    event MarketRejected(byte32 indexed conditionId);

    /**
     * @notice Emitted when a new facotry is registered
     * @param factory Address of the registered facotry
     * @param version Version number
     **/
    event FactoryRegistered(address indexed factory, uint256 version);

    /**
     * @notice Emitted when a new global default LTV is updated
     * @param newDefaultLTV New default max loan-to-value in basis points
     **/
    event DefaultMaxLTVUpdated(uitn256 newDefaultLTV);

    /**
     * @notice Emitted when global default liquidation threshold is updated
     * @param newDefaultThreshold New default liquidation threshold in basis points
     **/
    event DefaultLiquidationThresholdUpdated(uint256 newDefaultThreshold);

    /**
     * @notice Creates a new isolated lending Site for a Polymarket market
     * @dev Only callable by MARKET_CURATOR_ROLE. Market must be pre-approved via approveMarket().
     * @param conditionId Polymarket condition ID (unique identifier for the prediction market)
     * @param oracle Address of the oracle contract
     * @param interestRateModel Address of the interest rate model
     * @param maxLtv Maximum LTV in basis points (e.g., 7500 = 75%)
     * @param liquidationThreshold Liquidation threshold in basis points (e.g., 8000 = 80%)
     * @return site Address of the created Site contract
     */
    function createSite(
        bytes32 conditionId,
        address oracle,
        address interestRateModel,
        uint256 maxLTV,
        uint256 liquidationThreshold
    ) external returns (address site);

    /**
     * @notice Gets the Site address for a given Polymarket condition
     * @param conditionId Polymarket condition ID
     * @return Address of the Site, or address(0) if no Site exists for this condition
     */
    function getSite(bytes32 conditionId) external view returns (address);

    /**
     * @notice Returns all deployed Site addresses
     * @dev May be gas-intensive for large numbers of Sites. Use carefully in view functions.
     * @return Array of all Site addresses
     */
    function getSites() external view returns (address[] memory);

    /**
     * @notice Checks if an address is a valid deployed Site
     * @param site Address to check
     * @return True if address is a deployed Site
     */
    function isSite(address site) external view returns (bool);

    /**
     * @notice Proposes a new Polymarket market for Site creation
     * @dev Anyone can propose, but only approved markets can have Sites created
     * @param conditionId Polymarket condition ID to propose
     * @param oracle Proposed oracle address for this market
     */
    function purposeMarket(bytes32 conditionId, address oracle) external;

    /**
     * @notice Approves a proposed market for Site creation
     * @dev Only callable by MARKET_CURATOR_ROLE. This is how we maintain curated markets.
     * @param conditionId Polymarket condition ID to approve
     */
    function approveMarket(bytes32 conditionId) external;

    /**
     * @notice Rejects a proposed market
     * @dev Only callable by MARKET_CURATOR_ROLE
     * @param conditionId Polymarket condition ID to reject
     */
    function rejectMarket(bytes32 conditionId) external;

    /**
     * @notice Checks if a market has been approved for Site creation
     * @param conditionId Polymarket condition ID
     * @return True if approved
     */
    function isMarketApproved(bytes32 conditionId) external view returns (bool);

    /**
     * @notice Registers a new Site factory for protocol upgrades
     * @dev Only callable by owner. Allows multiple factory versions to coexist.
     * @param factory Address of the factory contract
     * @param version Version number for this factory (must be unique)
     */
    function registerFactory(address factory, uint256 version) external;

    /**
     * @notice Gets the current Site factory address
     * @return Address of the active Site factory
     */
    function siteFactory() external view returns (address);

    /**
     * @notice Gets the tokens factory address
     * @return Address of the factory that deploys share tokens
     */
    function tokensFactory() external view returns (address);

    /**
     * @notice Gets the interest rate model factory address
     * @return Address of the factory that deploys interest rate models
     */
    function interestRateModelFactory() external view returns (address);

    /**
     * @notice Sets the default maximum loan-to-value ratio
     * @dev Only callable by owner. Used when Sites are created without explicit LTV.
     * @param ltv Maximum loan-to-value in basis points (10000 = 100%)
     */
    function setDefaultMaxLtv(uint256 ltv) external;

    /**
     * @notice Sets the default liquidation threshold
     * @dev Only callable by owner. Used when Sites are created without explicit threshold.
     * @param threshold Liquidation threshold in basis points (10000 = 100%)
     */
    function setDefaultLiquidationThreshold(uint256 threshold) external;

    /**
     * @notice Gets the default maximum loan-to-value ratio
     * @return Default LTV in basis points
     */
    function defaultMaxLtv() external view returns (uint256);

    /**
     * @notice Gets the default liquidation threshold
     * @return Default threshold in basis points
     */
    function defaultLiquidationThreshold() external view returns (uint256);

    /**
     * @notice Gets the configuration contract address
     * @return Address of ISiteConfiguration implementation
     */
    function configuration() external view returns (address);

    /**
     * @notice Gets the oracle registry address
     * @return Address of IOracleRegistry implementation
     */
    function oracleRegistry() external view returns (address);

    /**
     * @notice Gets the fee collector address
     * @return Address of IFeeCollector implementation
     */
    function feeCollector() external view returns (address);

    /**
     * @notice Gets the access control address
     * @return Address of IAccessControl implementation
     */
    function accessControl() external view returns (address);

    /**
     * @notice Gets the guarded launch address
     * @return Address of IGuardedLaunch implementation
     */
    function guardedLaunch() external view returns (address);

    /**
     * @notice Gets the repository owner address
     * @return Address of the owner
     */
    function owner() external view returns (address);

    /**
     * @notice Transfers repository ownership
     * @dev Only callable by current owner
     * @param newOwner Address of the new owner
     */
    function transferOwnership(address newOwner) external;
}
