// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/IAccessControl.sol";
import "./IFeeCollector.sol";
import "./IGuardedLaunch.sol";
import "./IHookReceiver.sol";
import "./IInterestRateModel.sol";
import "./IInterestRateModelFactory.sol";
import "./IOracleRegistry.sol";
import "./IPolymarketOracle.sol";
import "./ISite.sol";
import "./ISiteConfig.sol";
import "./ISiteFactory.sol";
import "./ITokensFactory.sol";

interface ISiteRepository {
    /// @notice Emitted when a new Site is deployed
    /// @param site ISite instance of the newly deployed contract
    /// @param conditionId Polymarket condition ID for this market
    /// @param creator Address that triggered Site creation
    event SiteCreated(
        ISite indexed site,
        bytes32 indexed conditionId,
        address indexed creator
    );

    /// @notice Emitted when a market is approved for Site creation
    /// @param conditionId Polymarket condition ID that was approved
    event MarketApproved(bytes32 indexed conditionId);

    /// @notice Emitted when a market proposal is rejected
    /// @param conditionId Polymarket condition ID that was rejected
    event MarketRejected(bytes32 indexed conditionId);

    /// @notice Emitted when a new factory is registered
    /// @param factory ISiteFactory instance that was registered
    /// @param version Version number of this factory
    event FactoryRegistered(ISiteFactory indexed factory, uint256 version);

    /// @notice Emitted when global default LTV is updated
    /// @param newDefaultLTV New default maximum loan-to-value in basis points
    event DefaultMaxLTVUpdated(uint256 newDefaultLTV);

    /// @notice Emitted when global default liquidation threshold is updated
    /// @param newDefaultThreshold New default liquidation threshold in basis points
    event DefaultLiquidationThresholdUpdated(uint256 newDefaultThreshold);

    /**
     * @notice Creates a new isolated lending Site for a Polymarket market
     * @dev Only callable by MARKET_CURATOR_ROLE. Market must be pre-approved via approveMarket().
     * @param conditionId Polymarket condition ID (unique identifier for the prediction market)
     * @param oracle Oracle contract for this market
     * @param interestRateModel Interest rate model to use
     * @param maxLtv Maximum loan-to-value ratio in basis points (e.g., 7500 = 75%)
     * @param liquidationThreshold Liquidation threshold in basis points (e.g., 8000 = 80%)
     * @param hookReceiver Hook receiver for liquidations and extensions (can be address(0))
     * @return site Newly created Site instance
     */
    function createSite(
        bytes32 conditionId,
        IPolymarketOracle oracle,
        IInterestRateModel interestRateModel,
        uint256 maxLtv,
        uint256 liquidationThreshold,
        IHookReceiver hookReceiver
    ) external returns (ISite site);

    /**
     * @notice Gets the Site for a given Polymarket condition
     * @param conditionId Polymarket condition ID
     * @return ISite instance, or ISite(address(0)) if no Site exists for this condition
     */
    function getSite(bytes32 conditionId) external view returns (ISite);

    /**
     * @notice Returns all deployed Sites
     * @dev May be gas-intensive for large numbers of Sites. Use carefully in view functions.
     * @return Array of all ISite instances
     */
    function getSites() external view returns (ISite[] memory);

    /**
     * @notice Checks if an address is a valid deployed Site
     * @param site Address to check
     * @return True if address is a deployed Site, false otherwise
     */
    function isSite(address site) external view returns (bool);

    /**
     * @notice Proposes a new Polymarket market for Site creation
     * @dev Anyone can propose, but only approved markets can have Sites created
     * @param conditionId Polymarket condition ID to propose
     * @param oracle Proposed oracle for this market
     */
    function proposeMarket(
        bytes32 conditionId,
        IPolymarketOracle oracle
    ) external;

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
     * @return True if approved, false otherwise
     */
    function isMarketApproved(bytes32 conditionId) external view returns (bool);

    /**
     * @notice Registers a new Site factory for protocol upgrades
     * @dev Only callable by owner. Allows multiple factory versions to coexist.
     * @param factory ISiteFactory instance to register
     * @param version Version number for this factory (must be unique)
     */
    function registerFactory(ISiteFactory factory, uint256 version) external;

    /**
     * @notice Gets the current Site factory
     * @return ISiteFactory instance
     */
    function siteFactory() external view returns (ISiteFactory);

    /**
     * @notice Gets the tokens factory
     * @return ITokensFactory instance
     */
    function tokensFactory() external view returns (ITokensFactory);

    /**
     * @notice Gets the interest rate model factory
     * @return IInterestRateModelFactory instance
     */
    function interestRateModelFactory()
        external
        view
        returns (IInterestRateModelFactory);

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
     * @notice Gets the configuration contract
     * @return ISiteConfig instance
     */
    function config() external view returns (ISiteConfig);

    /**
     * @notice Gets the oracle registry
     * @return IOracleRegistry instance
     */
    function oracleRegistry() external view returns (IOracleRegistry);

    /**
     * @notice Gets the fee collector
     * @return IFeeCollector instance
     */
    function feeCollector() external view returns (IFeeCollector);

    /**
     * @notice Gets the access control
     * @return IAccessControl instance
     */
    function accessControl() external view returns (IAccessControl);

    /**
     * @notice Gets the guarded launch
     * @return IGuardedLaunch instance
     */
    function guardedLaunch() external view returns (IGuardedLaunch);

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
