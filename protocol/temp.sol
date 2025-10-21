// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

/**
 * @title PolyLend Protocol Interfaces v1.0
 * @notice Complete interface suite for a prediction market lending protocol
 * @dev Production-ready interfaces for Polymarket YES/NO share lending with USDC borrowing
 *
 * Architecture Philosophy:
 * - Sites are isolated (each market is independent)
 * - Hot path optimized (user operations use cached values)
 * - Clear separation of concerns by actor and frequency
 * - Push-based config updates (Configuration pushes to Sites for caching)
 * - Extensible hooks system (before/after action hooks for liquidations, gauges, etc.)
 *
 * Silo V2 Integration:
 * - Hook system for extensibility (IHookReceiver)
 * - Liquidations implemented as hooks (not in core Site)
 * - Share token transfer hooks for gauge/incentive systems
 * - callOnBehalfOfSite for powerful hook receiver capabilities
 * - Liquidation target LTV to prevent dust positions
 *
 * Total Interfaces: 26
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

// ============================================
// CORE PROTOCOL INTERFACES (6)
// ============================================
/**
 * @title ISiteRepository
 * @notice Central registry and factory coordinator for all Sites
 * @dev Acts as the protocol's source of truth for deployed Sites and global configuration.
 *      Does NOT store per-Site configs (that's ISiteConfiguration's job) to keep this lightweight.
 */
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
     * @return ISiteConfiguration instance
     */
    function configuration() external view returns (ISiteConfiguration);

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

/**
 * @title IBaseSite
 * @notice Base interface defining common structs, events, and view functions for Sites
 * @dev Inherited by ISite. Contains the shared data structures and read-only functions.
 */
interface IBaseSite {
    // ============ Enums ============

    /// @notice Status of an asset within a Site
    enum AssetStatus {
        Undefined, // Asset has not been initialized
        Active, // Asset is active and can be used
        Removed // Asset has been removed and cannot be used
    }

    // ============ Structs ============

    /**
     * @notice Storage for asset-specific data
     * @dev Tracks all token addresses and total amounts for an asset
     */
    struct AssetStorage {
        address collateralToken; // Share token for borrowable collateral
        address collateralOnlyToken; // Share token for protected collateral
        address debtToken; // Debt token (uses IERC20R)
        uint256 totalDeposits; // Total deposits (borrowable collateral)
        uint256 collateralOnlyDeposits; // Total protected collateral deposits
        uint256 totalBorrowAmount; // Total amount borrowed
    }

    /**
     * @notice Interest accrual data for an asset
     * @dev Tracks fees and timestamps for interest calculations
     */
    struct AssetInterestData {
        uint256 harvestedProtocolFees; // Protocol fees already collected
        uint256 protocolFees; // Protocol fees pending collection
        uint64 interestRateTimestamp; // Last time interest was accrued
        AssetStatus status; // Current status of the asset
    }

    /**
     * @notice User's position in a specific asset
     * @dev All amounts are in underlying token units (not shares)
     */
    struct UserPosition {
        uint256 collateralAmount; // User's borrowable collateral
        uint256 collateralOnlyAmount; // User's protected collateral
        uint256 debtAmount; // User's debt amount
    }

    /**
     * @notice Utilization data for interest rate calculations
     * @dev Used by interest rate models to determine current rates
     */
    struct UtilizationData {
        uint256 totalDeposits; // Total deposits available
        uint256 totalBorrowAmount; // Total amount borrowed
        uint64 interestRateTimestamp; // Last interest accrual timestamp
    }

    // ============ Events ============

    /// @notice Emitted when a user deposits collateral
    /// @param asset Address of the asset deposited
    /// @param depositor Address of the user depositing
    /// @param amount Amount of underlying tokens deposited
    /// @param collateralOnly True if deposit is protected collateral, false if borrowable
    event Deposit(
        address indexed asset,
        address indexed depositor,
        uint256 amount,
        bool collateralOnly
    );

    /// @notice Emitted when a user withdraws collateral
    /// @param asset Address of the asset withdrawn
    /// @param depositor Address of the user withdrawing
    /// @param amount Amount of underlying tokens withdrawn
    /// @param collateralOnly True if withdrawing protected collateral, false if borrowable
    event Withdraw(
        address indexed asset,
        address indexed depositor,
        uint256 amount,
        bool collateralOnly
    );

    /// @notice Emitted when a user borrows
    /// @param asset Address of the asset borrowed (always USDC for PolyLend)
    /// @param borrower Address of the user borrowing
    /// @param amount Amount of underlying tokens borrowed
    event Borrow(
        address indexed asset,
        address indexed borrower,
        uint256 amount
    );

    /// @notice Emitted when a user repays debt
    /// @param asset Address of the asset repaid
    /// @param borrower Address of the user repaying
    /// @param amount Amount of underlying tokens repaid
    event Repay(
        address indexed asset,
        address indexed borrower,
        uint256 amount
    );

    /// @notice Emitted when a user is liquidated
    /// @param asset Address of the debt asset being repaid
    /// @param user Address of the user being liquidated
    /// @param shareAmountRepaid Amount of debt shares repaid by liquidator
    /// @param seizedCollateral Amount of collateral seized
    event Liquidate(
        address indexed asset,
        address indexed user,
        uint256 shareAmountRepaid,
        uint256 seizedCollateral
    );

    // ============ View Functions - Asset State ============

    /**
     * @notice Gets storage data for an asset
     * @param asset Address of the asset to query
     * @return AssetStorage struct containing token addresses and totals
     */
    function assetStorage(
        address asset
    ) external view returns (AssetStorage memory);

    /**
     * @notice Gets interest data for an asset
     * @param asset Address of the asset to query
     * @return AssetInterestData struct containing fee and timestamp data
     */
    function interestData(
        address asset
    ) external view returns (AssetInterestData memory);

    /**
     * @notice Gets utilization data for an asset
     * @dev Used by interest rate models and UI
     * @param asset Address of the asset to query
     * @return UtilizationData struct for interest calculations
     */
    function utilizationData(
        address asset
    ) external view returns (UtilizationData memory);

    // ============ View Functions - User Positions ============

    /**
     * @notice Gets a user's complete position for an asset
     * @param asset Address of the asset to query
     * @param user Address of the user
     * @return UserPosition struct containing all position data
     */
    function getUserPosition(
        address asset,
        address user
    ) external view returns (UserPosition memory);

    /**
     * @notice Gets user's borrowable collateral balance in underlying tokens
     * @param asset Address of the collateral asset
     * @param user Address of the user
     * @return Balance in underlying token units
     */
    function collateralBalanceOfUnderlying(
        address asset,
        address user
    ) external view returns (uint256);

    /**
     * @notice Gets user's protected collateral balance in underlying tokens
     * @param asset Address of the collateral asset
     * @param user Address of the user
     * @return Balance in underlying token units
     */
    function collateralOnlyBalanceOfUnderlying(
        address asset,
        address user
    ) external view returns (uint256);

    /**
     * @notice Gets user's debt balance in underlying tokens
     * @param asset Address of the debt asset
     * @param user Address of the user
     * @return Debt balance in underlying token units
     */
    function debtBalanceOfUnderlying(
        address asset,
        address user
    ) external view returns (uint256);

    // ============ View Functions - Solvency ============

    /**
     * @notice Checks if a user is solvent (not liquidatable)
     * @dev Returns true if user's LTV is below liquidation threshold
     * @param user Address of the user to check
     * @return True if solvent, false if liquidatable
     */
    function isSolvent(address user) external view returns (bool);

    /**
     * @notice Gets user's current loan-to-value ratio
     * @dev Returns LTV in basis points (e.g., 7500 = 75%)
     * @param user Address of the user
     * @return Current LTV in basis points
     */
    function getUserLTV(address user) external view returns (uint256);

    /**
     * @notice Gets user's liquidation threshold
     * @dev Weighted average of liquidation thresholds across user's collateral
     * @param user Address of the user
     * @return Liquidation threshold in basis points
     */
    function getUserLiquidationThreshold(
        address user
    ) external view returns (uint256);

    /**
     * @notice Calculates maximum amount a user can withdraw while staying solvent
     * @param asset Address of the asset to withdraw
     * @param user Address of the user
     * @return Maximum withdrawable amount in underlying tokens
     */
    function getMaxWithdraw(
        address asset,
        address user
    ) external view returns (uint256);

    /**
     * @notice Calculates maximum amount a user can borrow while staying solvent
     * @param asset Address of the asset to borrow (USDC for PolyLend)
     * @param user Address of the user
     * @return Maximum borrowable amount in underlying tokens
     */
    function getMaxBorrow(
        address asset,
        address user
    ) external view returns (uint256);

    // ============ View Functions - Site Info ============

    /**
     * @notice Gets the Polymarket condition ID for this Site
     * @return Condition ID bytes32
     */
    function conditionId() external view returns (bytes32);

    /**
     * @notice Gets the YES token address for this market
     * @return Address of the YES share token in Polymarket CTF
     */
    function yesToken() external view returns (address);

    /**
     * @notice Gets the NO token address for this market
     * @return Address of the NO share token in Polymarket CTF
     */
    function noToken() external view returns (address);

    /**
     * @notice Gets the borrowable asset address (always USDC)
     * @return Address of USDC token
     */
    function borrowToken() external view returns (address);

    /**
     * @notice Gets the repository
     * @return ISiteRepository instance
     */
    function repository() external view returns (ISiteRepository);

    /**
     * @notice Gets the interest rate model
     * @return IInterestRateModel instance for this Site
     */
    function interestRateModel() external view returns (IInterestRateModel);
}

/**
 * @title ISite
 * @notice Main lending interface for user-facing operations
 * @dev Extends IBaseSite with state-changing functions. Each Site is an isolated lending market.
 *
 * Key Design Points:
 * - Sites cache risk parameters locally for gas efficiency
 * - Only USDC is borrowable (YES/NO are collateral only)
 * - Each Site is completely isolated from other Sites
 */
interface ISite is IBaseSite {
    // ============ State-Changing Functions ============

    /**
     * @notice Deposits collateral into the Site
     * @dev User must approve Site to transfer tokens first
     * @param asset Address of asset to deposit (YES, NO, or USDC)
     * @param amount Amount of underlying tokens to deposit
     * @param collateralOnly True to deposit as protected collateral (cannot be borrowed)
     * @return shares Amount of share tokens minted to user
     */
    function deposit(
        address asset,
        uint256 amount,
        bool collateralOnly
    ) external returns (uint256 shares);

    /**
     * @notice Withdraws collateral from the Site
     * @dev Fails if withdrawal would make user insolvent
     * @param asset Address of asset to withdraw
     * @param shares Amount of share tokens to burn
     * @param collateralOnly True if withdrawing protected collateral
     * @return amount Amount of underlying tokens withdrawn
     */
    function withdraw(
        address asset,
        uint256 shares,
        bool collateralOnly
    ) external returns (uint256 amount);

    /**
     * @notice Borrows USDC against collateral
     * @dev Only USDC can be borrowed. Fails if borrow would make user insolvent.
     * @param asset Address of asset to borrow (must be USDC)
     * @param amount Amount of underlying tokens to borrow
     * @return shares Amount of debt shares minted to user
     */
    function borrow(
        address asset,
        uint256 amount
    ) external returns (uint256 shares);

    /**
     * @notice Repays borrowed USDC
     * @dev User must approve Site to transfer USDC first
     * @param asset Address of asset to repay (USDC)
     * @param amount Amount of underlying tokens to repay
     * @return shares Amount of debt shares burned
     */
    function repay(
        address asset,
        uint256 amount
    ) external returns (uint256 shares);

    /**
     * @notice Liquidates an insolvent user's position
     * @dev Liquidator repays user's debt and receives collateral + bonus
     * @param user Address of the user to liquidate
     * @param asset Address of the debt asset (USDC)
     * @param shareAmountToRepay Amount of debt shares to repay
     * @return seizedCollateral Amount of collateral seized
     */
    function liquidate(
        address user,
        address asset,
        uint256 shareAmountToRepay
    ) external returns (uint256 seizedCollateral);

    /**
     * @notice Accrues interest for an asset
     * @dev Updates interest calculations to current block. Can be called by anyone.
     * @param asset Address of the asset to accrue interest for
     */
    function accrueInterest(address asset) external;

    /**
     * @notice Flash liquidation with callback
     * @dev Liquidator receives collateral first, callback executes, must repay in same tx
     * @param user Address of the user to liquidate
     * @param asset Address of the debt asset
     * @param shareAmountToRepay Amount of debt shares to repay
     * @param receiverAddress Address of IFlashLiquidationReceiver implementation
     * @param data Arbitrary data to pass to callback
     * @return seizedCollateral Amount of collateral seized
     */
    function flashLiquidate(
        address user,
        address asset,
        uint256 shareAmountToRepay,
        address receiverAddress,
        bytes calldata data
    ) external returns (uint256 seizedCollateral);

    // ============ Configuration Updates (Push Model) ============

    /**
     * @notice Updates cached risk parameters
     * @dev Only callable by ISiteConfiguration. This is the PUSH mechanism for cache updates.
     * @param asset Address of the asset to update config for
     * @param maxLtv New maximum loan-to-value in basis points
     * @param liquidationThreshold New liquidation threshold in basis points
     * @param liquidationTargetLtv New target LTV after liquidation in basis points
     * @param liquidationPenalty New liquidation penalty in basis points
     */
    function updateCachedConfig(
        address asset,
        uint256 maxLtv,
        uint256 liquidationThreshold,
        uint256 liquidationTargetLtv,
        uint256 liquidationPenalty
    ) external;

    /**
     * @notice Updates the interest rate model
     * @dev Only callable by ISiteConfiguration
     * @param newModel New IInterestRateModel instance
     */
    function updateInterestRateModel(IInterestRateModel newModel) external;

    // ============ Hook System Integration ============

    /**
     * @notice Gets the hook receiver for this Site
     * @dev Hook receiver handles liquidations, gauges, and other extensions
     * @return IHookReceiver instance, or IHookReceiver(address(0)) if none set
     */
    function hookReceiver() external view returns (IHookReceiver);

    /**
     * @notice Updates hook configuration
     * @dev Must be called after hook receiver changes its configuration.
     *      Syncs the Site's cached hook config with the hook receiver.
     */
    function updateHooks() external;

    /**
     * @notice Allows hook receiver to call functions on behalf of Site
     * @dev ONLY callable by the hook receiver. Enables powerful liquidation mechanics.
     * @param target Target contract address
     * @param value ETH value to send
     * @param data Calldata to execute
     * @return success True if call succeeded
     * @return result Return data from the call
     */
    function callOnBehalfOfSite(
        address target,
        uint256 value,
        bytes calldata data
    ) external payable returns (bool success, bytes memory result);

    /**
     * @notice Emitted when hook configuration is updated
     * @param hooksBefore Bitmask of actions with beforeAction hooks
     * @param hooksAfter Bitmask of actions with afterAction hooks
     */
    event HooksUpdated(uint24 hooksBefore, uint24 hooksAfter);
}

/**
 * @title ISiteFactory
 * @notice Factory for deploying new Site contracts
 * @dev Implements deterministic deployment for predictable addresses
 */
interface ISiteFactory {
    /// @notice Emitted when a new Site is deployed
    /// @param site ISite instance of deployed contract
    /// @param conditionId Polymarket condition ID
    /// @param version Factory version used
    event SiteDeployed(
        ISite indexed site,
        bytes32 indexed conditionId,
        uint256 version
    );

    /**
     * @notice Deploys a new Site contract
     * @dev Only callable by ISiteRepository
     * @param conditionId Polymarket condition ID
     * @param repository ISiteRepository instance
     * @param yesToken Address of YES share token (from Polymarket CTF)
     * @param noToken Address of NO share token (from Polymarket CTF)
     * @param borrowToken Address of USDC
     * @param interestRateModel IInterestRateModel instance
     * @param hookReceiver IHookReceiver for liquidations and extensions (can be address(0))
     * @return site Deployed ISite instance
     */
    function createSite(
        bytes32 conditionId,
        ISiteRepository repository,
        address yesToken,
        address noToken,
        address borrowToken,
        IInterestRateModel interestRateModel,
        IHookReceiver hookReceiver
    ) external returns (ISite site);

    /**
     * @notice Gets the factory version
     * @return Version number
     */
    function version() external view returns (uint256);
}

/**
 * @title ITokensFactory
 * @notice Factory for deploying share tokens (collateral, protected collateral, debt)
 * @dev Creates ERC20 tokens that represent shares in Site pools
 */
interface ITokensFactory {
    /// @notice Type of share token being deployed
    enum TokenType {
        Collateral, // Borrowable collateral token
        CollateralOnly, // Protected collateral token
        Debt // Debt token (implements IERC20R)
    }

    /// @notice Emitted when a share token is deployed
    /// @param token Address of deployed token
    /// @param site ISite instance this token belongs to
    /// @param asset Address of underlying asset
    /// @param tokenType Type of token deployed
    event ShareTokenDeployed(
        address indexed token,
        ISite indexed site,
        address indexed asset,
        TokenType tokenType
    );

    /**
     * @notice Creates a borrowable collateral share token
     * @param site ISite instance
     * @param asset Address of the underlying asset
     * @param name Token name
     * @param symbol Token symbol
     * @return Deployed IShareToken instance
     */
    function createShareCollateralToken(
        ISite site,
        address asset,
        string calldata name,
        string calldata symbol
    ) external returns (IShareToken);

    /**
     * @notice Creates a protected collateral share token
     * @param site ISite instance
     * @param asset Address of the underlying asset
     * @param name Token name
     * @param symbol Token symbol
     * @return Deployed IShareToken instance
     */
    function createShareProtectedToken(
        ISite site,
        address asset,
        string calldata name,
        string calldata symbol
    ) external returns (IShareToken);

    /**
     * @notice Creates a debt share token (implements IERC20R)
     * @param site ISite instance
     * @param asset Address of the underlying asset
     * @param name Token name
     * @param symbol Token symbol
     * @return Deployed IERC20R instance
     */
    function createShareDebtToken(
        ISite site,
        address asset,
        string calldata name,
        string calldata symbol
    ) external returns (IERC20R);

    /**
     * @notice Validates if address is a Site
     * @param site Address to check
     * @return True if valid Site
     */
    function isSite(address site) external view returns (bool);
}

/**
 * @title IShareToken
 * @notice Base interface for all share tokens (collateral and protected collateral)
 * @dev Extends IERC20 with Site-specific minting/burning. Only the Site can mint/burn.
 *      Includes hook system for notifying external contracts on transfers.
 */
interface IShareToken is IERC20 {
    /**
     * @notice Mints new share tokens
     * @dev Only callable by the Site contract
     * @param to Address to mint to
     * @param amount Amount to mint
     */
    function mint(address to, uint256 amount) external;

    /**
     * @notice Burns share tokens
     * @dev Only callable by the Site contract
     * @param from Address to burn from
     * @param amount Amount to burn
     */
    function burn(address from, uint256 amount) external;

    /**
     * @notice Gets the Site contract that controls this token
     * @return ISite instance that can mint/burn
     */
    function site() external view returns (ISite);

    /**
     * @notice Gets the underlying asset address
     * @return Address of the asset this token represents shares of
     */
    function asset() external view returns (address);

    // ============ Hook System ============

    /**
     * @notice Synchronizes hook configuration with Site
     * @dev Only callable by Site. Updates which actions trigger hooks.
     * @param hooksBefore Bitmask of actions with beforeAction hooks
     * @param hooksAfter Bitmask of actions with afterAction hooks
     */
    function synchronizeHooks(uint24 hooksBefore, uint24 hooksAfter) external;

    /**
     * @notice Transfers tokens without standard checks (for hook receiver use)
     * @dev Only callable by hook receiver. Used during liquidations to bypass solvency checks.
     * @param from Source address
     * @param to Destination address
     * @param amount Amount to transfer
     */
    function forwardTransferFromNoChecks(
        address from,
        address to,
        uint256 amount
    ) external;
}

// ============================================
// ORACLE INTERFACES (4)
// ============================================

/**
 * @title IOracleRegistry
 * @notice Central registry mapping Polymarket conditions to oracle implementations
 * @dev Provides unified price interface for all Sites
 */
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

/**
 * @title IPolymarketOracle
 * @notice Oracle implementation for individual Polymarket markets
 * @dev Tracks prices and resolution status for a single prediction market
 */
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

/**
 * @title IPolymarketCTF
 * @notice Interface for Polymarket's Conditional Token Framework (ERC1155)
 * @dev This is Polymarket's core contract that holds YES/NO shares
 */
interface IPolymarketCTF {
    /**
     * @notice Gets token balance for a single token ID
     * @param account Address to query
     * @param tokenId Token ID (position ID in CTF)
     * @return Balance
     */
    function balanceOf(
        address account,
        uint256 tokenId
    ) external view returns (uint256);

    /**
     * @notice Gets balances for multiple token IDs
     * @param accounts Array of addresses
     * @param tokenIds Array of token IDs
     * @return Array of balances
     */
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata tokenIds
    ) external view returns (uint256[] memory);

    /**
     * @notice Transfers tokens (ERC1155)
     * @param from Source address
     * @param to Destination address
     * @param id Token ID
     * @param amount Amount to transfer
     * @param data Additional data
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @notice Batch transfers tokens
     * @param from Source address
     * @param to Destination address
     * @param ids Array of token IDs
     * @param amounts Array of amounts
     * @param data Additional data
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

    /**
     * @notice Gets payout numerator for outcome index
     * @dev Used to determine resolution (which outcome won)
     * @param conditionId Polymarket condition ID
     * @param index Outcome index (0 for NO, 1 for YES typically)
     * @return Payout numerator
     */
    function payoutNumerators(
        bytes32 conditionId,
        uint256 index
    ) external view returns (uint256);

    /**
     * @notice Checks if condition is resolved in CTF
     * @param conditionId Polymarket condition ID
     * @return True if resolved
     */
    function isResolved(bytes32 conditionId) external view returns (bool);
}

/**
 * @title IOracleProvider
 * @notice Base oracle interface for extensibility
 * @dev Allows plugging in different oracle implementations (Chainlink, Pyth, custom)
 */
interface IOracleProvider {
    /**
     * @notice Gets price for an asset
     * @param asset Address of asset
     * @return price Price in quote token units
     */
    function getPrice(address asset) external view returns (uint256 price);

    /**
     * @notice Checks if oracle supports an asset
     * @param asset Address of asset
     * @return True if supported
     */
    function assetSupported(address asset) external view returns (bool);

    /**
     * @notice Gets the quote token (e.g., USDC)
     * @return Address of quote token
     */
    function quoteToken() external view returns (address);

    /**
     * @notice Ping function to verify interface
     * @return Function selector
     */
    function oracleProviderPing() external pure returns (bytes4);
}

// ============================================
// INTEREST RATE INTERFACES (2)
// ============================================

/**
 * @title IInterestRateModel
 * @notice Calculates borrow and supply interest rates based on utilization
 * @dev Uses jump rate model (kinked interest rate curve)
 */
interface IInterestRateModel {
    /**
     * @notice Pool state for rate calculations
     * @dev Extended to support pool balance incentives
     */
    struct PoolState {
        uint256 totalDeposits; // Total deposits in pool
        uint256 totalBorrows; // Total borrowed amount
        uint256 yesPoolBalance; // YES collateral balance
        uint256 noPoolBalance; // NO collateral balance
    }

    /**
     * @notice Rate breakdown for transparency
     * @dev Shows components of final rate calculation
     */
    struct RateBreakdown {
        uint256 baseRate; // Base rate component
        uint256 utilizationRate; // Utilization-based component
        uint256 poolBalanceAdjustment; // Adjustment for imbalanced pools
        uint256 finalRate; // Combined final rate
    }

    /**
     * @notice Calculates current borrow rate
     * @dev Rate increases with utilization, jumps at kink point
     * @param totalDeposits Total deposited in pool
     * @param totalBorrows Total borrowed from pool
     * @return Borrow rate per year in ray (1e27 = 100%)
     */
    function getBorrowRate(
        uint256 totalDeposits,
        uint256 totalBorrows
    ) external view returns (uint256);

    /**
     * @notice Calculates current supply rate
     * @dev Supply rate = borrow rate * utilization * (1 - protocolFee)
     * @param totalDeposits Total deposited in pool
     * @param totalBorrows Total borrowed from pool
     * @param protocolFeeBps Protocol fee in basis points
     * @return Supply rate per year in ray (1e27 = 100%)
     */
    function getSupplyRate(
        uint256 totalDeposits,
        uint256 totalBorrows,
        uint256 protocolFeeBps
    ) external view returns (uint256);

    /**
     * @notice Gets detailed rate breakdown
     * @param state Current pool state
     * @return Breakdown of rate components
     */
    function getRateBreakdown(
        PoolState calldata state
    ) external view returns (RateBreakdown memory);

    /**
     * @notice Calculates compound interest
     * @dev Interest = principal * (1 + rate)^time
     * @param principal Starting principal
     * @param rate Interest rate per second
     * @param timeElapsed Seconds elapsed
     * @return Total amount with interest
     */
    function calculateCompoundInterest(
        uint256 principal,
        uint256 rate,
        uint256 timeElapsed
    ) external pure returns (uint256);

    /**
     * @notice Constructs pool state from parameters
     * @dev Helper for rate calculations
     * @param totalDeposits Total deposits
     * @param totalBorrows Total borrows
     * @param yesPoolBalance YES collateral balance
     * @param noPoolBalance NO collateral balance
     * @return Constructed pool state
     */
    function calculatePoolState(
        uint256 totalDeposits,
        uint256 totalBorrows,
        uint256 yesPoolBalance,
        uint256 noPoolBalance
    ) external view returns (PoolState memory);

    // Model parameters
    function baseRatePerYear() external view returns (uint256);
    function multiplierPerYear() external view returns (uint256);
    function jumpMultiplierPerYear() external view returns (uint256);
    function kink() external view returns (uint256);
}

/**
 * @title IInterestRateModelFactory
 * @notice Factory for deploying interest rate model instances
 * @dev Allows creating models with custom parameters per Site
 */
interface IInterestRateModelFactory {
    /// @notice Emitted when new model is created
    event InterestRateModelCreated(
        IInterestRateModel indexed model,
        address indexed creator
    );

    /**
     * @notice Interest rate model parameters
     * @dev Standard jump rate model parameters
     */
    struct ModelParameters {
        uint256 baseRatePerYear; // Base interest rate (at 0% utilization)
        uint256 multiplierPerYear; // Rate of increase before kink
        uint256 jumpMultiplierPerYear; // Rate of increase after kink
        uint256 kink; // Utilization point where rate jumps
    }

    /**
     * @notice Creates interest rate model with custom parameters
     * @param baseRatePerYear Base rate in ray
     * @param multiplierPerYear Multiplier in ray
     * @param jumpMultiplierPerYear Jump multiplier in ray
     * @param kink Kink utilization in ray (e.g., 0.8e27 = 80%)
     * @return Deployed IInterestRateModel instance
     */
    function createInterestRateModel(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink
    ) external returns (IInterestRateModel);

    /**
     * @notice Creates model with default parameters
     * @return Deployed IInterestRateModel instance
     */
    function createDefaultInterestRateModel()
        external
        returns (IInterestRateModel);

    /**
     * @notice Gets default parameter values
     * @return Default parameters struct
     */
    function getDefaultParameters()
        external
        pure
        returns (ModelParameters memory);
}

// ============================================
// DEBT TOKEN INTERFACE (1)
// ============================================

/**
 * @title IERC20R
 * @notice "ERC20 Reversed" - Recipient must approve receiving debt
 * @dev Prevents accidental debt transfers. Recipient approves sender, not vice versa.
 *      Extends IERC20 with reverse approval mechanism.
 *
 * Why: Normal ERC20 approval lets sender push tokens to anyone. For debt, we want
 * recipients to explicitly approve receiving debt to prevent griefing.
 */
interface IERC20R is IERC20 {
    /// @notice Emitted when receive approval is set
    /// @param owner Address that can receive tokens
    /// @param spender Address that can send tokens to owner
    /// @param value Amount approved
    event ReceiveApproval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @notice Sets approval to receive tokens from spender
     * @dev Opposite of normal ERC20 approve - this lets someone send TO you
     * @param spender Address that can send tokens to msg.sender
     * @param amount Amount they can send
     */
    function setReceiveApproval(address spender, uint256 amount) external;

    /**
     * @notice Increases receive allowance
     * @param spender Address that can send tokens
     * @param addedValue Amount to add to allowance
     */
    function increaseReceiveAllowance(
        address spender,
        uint256 addedValue
    ) external;

    /**
     * @notice Decreases receive allowance
     * @param spender Address that can send tokens
     * @param subtractedValue Amount to subtract from allowance
     */
    function decreaseReceiveAllowance(
        address spender,
        uint256 subtractedValue
    ) external;

    /**
     * @notice Gets receive allowance
     * @dev How much can spender send to owner?
     * @param owner Address that would receive tokens
     * @param spender Address that would send tokens
     * @return Allowance amount
     */
    function receiveAllowance(
        address owner,
        address spender
    ) external view returns (uint256);
}

// ============================================
// HOOKS SYSTEM INTERFACES (1)
// ============================================

/**
 * @title IHookReceiver
 * @notice Hook system for extensible protocol actions
 * @dev Allows external contracts to execute custom logic before/after protocol actions.
 *      This is how Silo V2 implements liquidations, gauges, and other extensions.
 *
 * Key Design:
 * - beforeAction: Called BEFORE core logic (validation, checks)
 * - afterAction: Called AFTER core logic (notifications, integrations)
 * - Hook receivers can call functions on behalf of Sites via callOnBehalfOfSite
 * - Liquidation logic lives in a hook receiver, not in core Site contract
 */
interface IHookReceiver {
    /**
     * @notice Called before a protocol action executes
     * @dev Can revert to prevent the action. Used for validation and eligibility checks.
     * @param silo ISite where action is happening
     * @param action Encoded action type (see Hook library)
     * @param inputData ABI-encoded action-specific data
     */
    function beforeAction(
        ISite silo,
        uint256 action,
        bytes calldata inputData
    ) external;

    /**
     * @notice Called after a protocol action completes
     * @dev Cannot revert core action (already completed). Used for notifications and follow-up logic.
     * @param silo ISite where action happened
     * @param action Encoded action type (see Hook library)
     * @param inputData ABI-encoded action-specific data
     */
    function afterAction(
        ISite silo,
        uint256 action,
        bytes calldata inputData
    ) external;

    /**
     * @notice Gets hook configuration
     * @dev Returns bitmask of which actions have before/after hooks enabled
     * @return hooksBefore Bitmask of actions with beforeAction hooks
     * @return hooksAfter Bitmask of actions with afterAction hooks
     */
    function hookReceiverConfig(
        ISite silo
    ) external view returns (uint24 hooksBefore, uint24 hooksAfter);
}

// ============================================
// SAFETY & LIQUIDATION INTERFACES (4)
// ============================================

/**
 * @title IGuardedLaunch
 * @notice Emergency controls and circuit breakers for protocol safety
 * @dev Critical for launch phase and black swan events
 */
interface IGuardedLaunch {
    /// @notice Emitted when global pause is triggered
    event GlobalPaused(address indexed caller);

    /// @notice Emitted when global pause is lifted
    event GlobalUnpaused(address indexed caller);

    /// @notice Emitted when specific Site/asset is paused
    event SitePaused(ISite indexed site, address indexed asset);

    /// @notice Emitted when specific Site/asset is unpaused
    event SiteUnpaused(ISite indexed site, address indexed asset);

    /// @notice Emitted when deposit limits are toggled
    event MaxLiquidityLimitEnabled(bool enabled);

    /// @notice Emitted when Site deposit limit is set
    event SiteMaxDepositsSet(ISite indexed site, uint256 maxDeposits);

    /**
     * @notice Pauses/unpauses all Sites
     * @dev Only callable by EMERGENCY_ADMIN_ROLE. Nuclear option.
     * @param paused True to pause, false to unpause
     */
    function setGlobalPause(bool paused) external;

    /**
     * @notice Checks if protocol is globally paused
     * @return True if paused
     */
    function isGlobalPaused() external view returns (bool);

    /**
     * @notice Pauses specific Site and asset
     * @dev Only callable by EMERGENCY_ADMIN_ROLE
     * @param site ISite instance to pause
     * @param asset Asset address to pause
     * @param paused True to pause, false to unpause
     */
    function setSitePause(ISite site, address asset, bool paused) external;

    /**
     * @notice Checks if Site/asset is paused
     * @param site ISite instance
     * @param asset Asset address
     * @return True if paused
     */
    function isSitePaused(
        ISite site,
        address asset
    ) external view returns (bool);

    /**
     * @notice Enables/disables deposit limits
     * @dev Only callable by owner. Used during guarded launch.
     * @param enabled True to enable limits
     */
    function setLimitedMaxLiquidity(bool enabled) external;

    /**
     * @notice Sets default deposit limit for new Sites
     * @param limit Maximum total deposits in USD value
     */
    function setDefaultSiteMaxDepositsLimit(uint256 limit) external;

    /**
     * @notice Sets deposit limit for specific Site
     * @param site ISite instance
     * @param limit Maximum total deposits in USD value
     */
    function setSiteMaxDepositsLimit(ISite site, uint256 limit) external;

    /**
     * @notice Gets current deposit limit for Site
     * @param site ISite instance
     * @return Maximum deposits in USD value
     */
    function getMaxSiteDepositsValue(
        ISite site
    ) external view returns (uint256);

    /**
     * @notice Checks if deposit would exceed limit
     * @param site ISite instance
     * @param asset Asset being deposited
     * @param amount Amount being deposited
     * @return True if would exceed limit
     */
    function isDepositLimitReached(
        ISite site,
        address asset,
        uint256 amount
    ) external view returns (bool);
}

/**
 * @title IFlashLiquidationReceiver
 * @notice Callback interface for flash liquidations
 * @dev Liquidator receives collateral first, callback fires, must repay debt in same tx.
 *      Enables capital-efficient liquidations without upfront USDC.
 */
interface IFlashLiquidationReceiver {
    /**
     * @notice Callback executed during flash liquidation
     * @dev Must repay debt by end of this function or tx reverts
     * @param user Address being liquidated
     * @param assets Array of assets involved (debt + collateral)
     * @param receivedCollaterals Array of collateral amounts received
     * @param shareAmountsToRepaid Array of debt shares that must be repaid
     * @param flashReceiverData Arbitrary data passed by liquidator
     */
    function siteLiquidationCallback(
        address user,
        address[] calldata assets,
        uint256[] calldata receivedCollaterals,
        uint256[] calldata shareAmountsToRepaid,
        bytes calldata flashReceiverData
    ) external;
}

/**
 * @title ISwapper
 * @notice DEX integration for swapping collateral to USDC during liquidations
 * @dev Supports multiple DEX aggregators (Uniswap, 1inch, Paraswap, etc.)
 */
interface ISwapper {
    /// @notice Emitted when swap executes
    event Swap(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    /**
     * @notice Swaps exact amount in for minimum amount out
     * @dev Used when liquidator has exact collateral amount to sell
     * @param tokenIn Address of input token (YES/NO shares)
     * @param tokenOut Address of output token (USDC)
     * @param amountIn Exact amount of input tokens
     * @param minAmountOut Minimum acceptable output (slippage protection)
     * @param data DEX-specific calldata
     * @return amountOut Actual output amount received
     */
    function swapAmountIn(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        bytes calldata data
    ) external returns (uint256 amountOut);

    /**
     * @notice Swaps maximum amount in for exact amount out
     * @dev Used when liquidator needs exact USDC amount to repay debt
     * @param tokenIn Address of input token
     * @param tokenOut Address of output token
     * @param amountOut Exact amount of output tokens needed
     * @param maxAmountIn Maximum input tokens willing to spend
     * @param data DEX-specific calldata
     * @return amountIn Actual input amount used
     */
    function swapAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountOut,
        uint256 maxAmountIn,
        bytes calldata data
    ) external returns (uint256 amountIn);

    /**
     * @notice Gets the address to approve for token spending
     * @dev Different DEXs have different router addresses
     * @return Address to approve tokens to
     */
    function spenderToApprove() external view returns (address);

    /**
     * @notice Quotes output amount for input amount
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountIn Input amount
     * @return Expected output amount
     */
    function getAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256);

    /**
     * @notice Quotes input amount for output amount
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountOut Desired output amount
     * @return Required input amount
     */
    function getAmountIn(
        address tokenIn,
        address tokenOut,
        uint256 amountOut
    ) external view returns (uint256);
}

// ============================================
// RESOLUTION INTERFACE (1)
// ============================================

/**
 * @title IResolutionHandler
 * @notice Handles Polymarket market resolution and post-resolution liquidations
 * @dev Critical for prediction market-specific logic. Manages state transitions around resolution.
 */
interface IResolutionHandler {
    /**
     * @notice States of resolution process
     * @dev State machine: ACTIVE -> RESOLVING -> RESOLVED (or DISPUTED)
     */
    enum ResolutionState {
        ACTIVE, // Market trading normally
        RESOLVING, // Resolution triggered, grace period active
        RESOLVED, // Final resolution, can liquidate losing positions
        DISPUTED // Resolution challenged (rare)
    }

    /// @notice Emitted when resolution begins
    event ResolutionTriggered(
        bytes32 indexed conditionId,
        bool yesWon,
        uint256 gracePeriodEnd
    );

    /// @notice Emitted when resolution finalizes
    event ResolutionFinalized(bytes32 indexed conditionId, bool yesWon);

    /// @notice Emitted when resolution is disputed
    event ResolutionDisputed(bytes32 indexed conditionId);

    /// @notice Emitted when losing position is liquidated
    event LosingPositionLiquidated(
        address indexed user,
        address indexed losingAsset,
        uint256 amount
    );

    /// @notice Emitted when winnings are distributed
    event WinningsDistributed(address indexed user, uint256 amount);

    /**
     * @notice Triggers resolution process for a Site
     * @dev Begins grace period. Only callable when oracle reports resolution.
     * @param site ISite instance to resolve
     */
    function handleResolution(ISite site) external;

    /**
     * @notice Finalizes resolution after grace period
     * @dev Transitions to RESOLVED state. Enables liquidation of losing positions.
     * @param site ISite instance to finalize
     */
    function finalizeResolution(ISite site) external;

    /**
     * @notice Disputes a resolution (rare)
     * @dev Only callable by EMERGENCY_ADMIN_ROLE if resolution is incorrect
     * @param site ISite instance to dispute
     */
    function disputeResolution(ISite site) external;

    /**
     * @notice Liquidates positions backed by losing outcome
     * @dev After resolution, losing collateral is worth $0. Auto-liquidate these users.
     * @param site ISite instance
     * @param users Array of users to liquidate
     */
    function liquidateLosingPositions(
        ISite site,
        address[] calldata users
    ) external;

    /**
     * @notice Distributes $1 payout to winning collateral holders
     * @dev Users with winning shares can redeem for $1 each via CTF
     * @param site ISite instance
     * @param user User to distribute winnings to
     * @return amount Amount distributed
     */
    function distributeWinnings(
        ISite site,
        address user
    ) external returns (uint256 amount);

    /**
     * @notice Gets current resolution state
     * @param site ISite instance
     * @return Current state enum
     */
    function getResolutionState(
        ISite site
    ) external view returns (ResolutionState);

    /**
     * @notice Checks if resolution is complete
     * @param site ISite instance
     * @return True if fully resolved
     */
    function isResolutionComplete(ISite site) external view returns (bool);

    /**
     * @notice Gets when grace period ends
     * @param site ISite instance
     * @return Timestamp when grace period ends
     */
    function getGracePeriodEnd(ISite site) external view returns (uint256);

    /**
     * @notice Checks if user can withdraw asset
     * @dev During grace period, may restrict withdrawals
     * @param site ISite instance
     * @param user User address
     * @param asset Asset address
     * @return True if withdrawal allowed
     */
    function canWithdraw(
        ISite site,
        address user,
        address asset
    ) external view returns (bool);

    /**
     * @notice Checks if user can be liquidated
     * @dev Considers both solvency and resolution state
     * @param site ISite instance
     * @param user User address
     * @return True if liquidatable
     */
    function canLiquidate(
        ISite site,
        address user
    ) external view returns (bool);
}

// ============================================
// UX & HELPER INTERFACES (4)
// ============================================

/**
 * @title ISiteRouter
 * @notice Batch operations and multi-step transactions for improved UX
 * @dev Reduces transaction count and gas costs for common multi-step operations
 */
interface ISiteRouter {
    /**
     * @notice Deposits collateral and borrows in single transaction
     * @dev Saves gas vs two separate transactions
     * @param site ISite instance
     * @param collateralAsset Asset to deposit (YES/NO)
     * @param collateralAmount Amount to deposit
     * @param borrowAsset Asset to borrow (USDC)
     * @param borrowAmount Amount to borrow
     */
    function depositAndBorrow(
        ISite site,
        address collateralAsset,
        uint256 collateralAmount,
        address borrowAsset,
        uint256 borrowAmount
    ) external;

    /**
     * @notice Repays debt and withdraws collateral in single transaction
     * @param site ISite instance
     * @param debtAsset Asset to repay (USDC)
     * @param repayAmount Amount to repay
     * @param collateralAsset Asset to withdraw
     * @param withdrawAmount Amount to withdraw
     */
    function repayAndWithdraw(
        ISite site,
        address debtAsset,
        uint256 repayAmount,
        address collateralAsset,
        uint256 withdrawAmount
    ) external;
}

/**
 * @title ISiteLens
 * @notice View helper contract for aggregating data across Sites
 * @dev Read-only functions for UI/frontend. No state changes.
 */
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

/**
 * @title INotificationReceiver
 * @notice Hook system for external integrations on token transfers
 * @dev Enables staking rewards, analytics, external incentive systems
 */
interface INotificationReceiver {
    /**
     * @notice Called after token transfers
     * @dev Can be used for reward distribution, tracking, etc.
     * @param token Token address that was transferred
     * @param from Source address
     * @param to Destination address
     * @param amount Amount transferred
     */
    function onAfterTransfer(
        address token,
        address from,
        address to,
        uint256 amount
    ) external;

    /**
     * @notice Ping function to verify interface
     * @return Function selector
     */
    function notificationReceiverPing() external pure returns (bytes4);
}

/**
 * @title IWrappedNativeToken
 * @notice Standard WETH interface
 * @dev Only needed if supporting native ETH as collateral. Optional for USDC-only.
 *      Extends IERC20.
 */
interface IWrappedNativeToken is IERC20 {
    /**
     * @notice Wraps native ETH to WETH
     * @dev Payable function, msg.value determines wrap amount
     */
    function deposit() external payable;

    /**
     * @notice Unwraps WETH to native ETH
     * @param amount Amount to unwrap
     */
    function withdraw(uint256 amount) external;
}

// ============================================
// FUTURE PROOFING (1)
// ============================================

/**
 * @title ISiteFactoryV2
 * @notice Future factory version for protocol evolution
 * @dev Allows new Site implementations without breaking existing deployments
 */
interface ISiteFactoryV2 {
    /**
     * @notice Creates Site with additional parameters for future features
     * @dev Extends V1 createSite with additionalParams for forward compatibility
     * @param conditionId Polymarket condition ID
     * @param repository ISiteRepository instance
     * @param yesToken Address of YES share token (from Polymarket CTF)
     * @param noToken Address of NO share token (from Polymarket CTF)
     * @param borrowToken Address of USDC
     * @param interestRateModel IInterestRateModel instance
     * @param hookReceiver IHookReceiver for liquidations and extensions (can be address(0))
     * @param additionalParams ABI-encoded future parameters
     * @return site Deployed ISite instance
     */
    function createSite(
        bytes32 conditionId,
        ISiteRepository repository,
        address yesToken,
        address noToken,
        address borrowToken,
        IInterestRateModel interestRateModel,
        IHookReceiver hookReceiver,
        bytes calldata additionalParams
    ) external returns (ISite site);

    /**
     * @notice Gets factory version
     * @return Version number
     */
    function version() external view returns (uint256);

    /**
     * @notice Ping function to verify interface
     * @return Function selector
     */
    function siloFactoryPing() external pure returns (bytes4);
}

// ============================================
// GOVERNANCE INTERFACES (3)
// ============================================

// NOTE: IAccessControl imported from OpenZeppelin at top of file

/**
 * @title ISiteConfiguration
 * @notice Dynamic risk parameter management for Sites
 * @dev Implements PUSH model: updates are pushed to Sites for local caching.
 *      This gives us the best of both worlds - centralized config management
 *      with gas-efficient cached reads in Sites.
 */
interface ISiteConfiguration {
    /**
     * @notice Complete asset configuration
     * @dev All risk parameters for an asset in one struct
     */
    struct AssetConfig {
        uint256 maxLoanToValue; // Max LTV in basis points (7500 = 75%)
        uint256 liquidationThreshold; // Liquidation threshold in basis points (8000 = 80%)
        uint256 liquidationTargetLtv; // Target LTV after liquidation in basis points (7000 = 70%)
        uint256 liquidationPenalty; // Liquidation penalty in basis points (500 = 5%)
        bool borrowingEnabled; // Can this asset be borrowed?
        bool depositsEnabled; // Can deposits be made?
    }

    /// @notice Emitted when LTV is updated
    event MaxLoanToValueUpdated(
        address indexed site,
        address indexed asset,
        uint256 newLTV
    );

    /// @notice Emitted when liquidation threshold updated
    event LiquidationThresholdUpdated(
        address indexed site,
        address indexed asset,
        uint256 newThreshold
    );

    /// @notice Emitted when liquidation penalty updated
    event LiquidationPenaltyUpdated(
        address indexed site,
        address indexed asset,
        uint256 newPenalty
    );

    /// @notice Emitted when interest rate model updated
    event InterestRateModelUpdated(
        address indexed site,
        IInterestRateModel indexed newModel
    );

    /// @notice Emitted when asset status updated
    event AssetStatusUpdated(
        address indexed site,
        address indexed asset,
        bool borrowingEnabled,
        bool depositsEnabled
    );

    /// @notice Emitted when resolution grace period updated
    event ResolutionGracePeriodUpdated(address indexed site, uint256 newPeriod);

    /**
     * @notice Sets maximum loan-to-value for asset
     * @dev Only callable by RISK_MANAGER_ROLE. Pushes update to Site for caching.
     * @param site ISite instance
     * @param asset Asset address
     * @param ltv New LTV in basis points
     */
    function setMaxLoanToValue(ISite site, address asset, uint256 ltv) external;

    /**
     * @notice Sets liquidation threshold for asset
     * @dev Only callable by RISK_MANAGER_ROLE. Must be >= maxLTV.
     * @param site ISite instance
     * @param asset Asset address
     * @param threshold New threshold in basis points
     */
    function setLiquidationThreshold(
        ISite site,
        address asset,
        uint256 threshold
    ) external;

    /**
     * @notice Sets liquidation target LTV for asset
     * @dev Only callable by RISK_MANAGER_ROLE. Target LTV after liquidation (prevents dust).
     *      Must be < maxLTV. Ensures position is healthy after liquidation.
     * @param site ISite instance
     * @param asset Asset address
     * @param targetLtv New target LTV in basis points (e.g., 7000 = 70%)
     */
    function setLiquidationTargetLtv(
        ISite site,
        address asset,
        uint256 targetLtv
    ) external;

    /**
     * @notice Sets liquidation penalty for asset
     * @dev Only callable by RISK_MANAGER_ROLE. Penalty paid by liquidated user.
     * @param site ISite instance
     * @param asset Asset address
     * @param penalty New penalty in basis points
     */
    function setLiquidationPenalty(
        ISite site,
        address asset,
        uint256 penalty
    ) external;

    /**
     * @notice Sets complete asset config at once
     * @dev Batch update to save gas when changing multiple parameters
     * @param site ISite instance
     * @param asset Asset address
     * @param config New configuration struct
     */
    function setAssetConfig(
        ISite site,
        address asset,
        AssetConfig calldata config
    ) external;

    /**
     * @notice Updates interest rate model for Site
     * @dev Only callable by RISK_MANAGER_ROLE. Pushes to Site.
     * @param site ISite instance
     * @param newModel New IInterestRateModel instance
     */
    function setInterestRateModel(
        ISite site,
        IInterestRateModel newModel
    ) external;

    /**
     * @notice Sets resolution grace period
     * @dev Time window after resolution trigger before finalization
     * @param site ISite instance
     * @param period Grace period in seconds
     */
    function setResolutionGracePeriod(ISite site, uint256 period) external;

    /**
     * @notice Sets delay before liquidating after resolution
     * @dev Gives users time to manually unwind positions
     * @param site ISite instance
     * @param delay Delay in seconds
     */
    function setPostResolutionLiquidationDelay(
        ISite site,
        uint256 delay
    ) external;

    /**
     * @notice Enables/disables borrowing for asset
     * @dev Emergency function to pause borrowing without full pause
     * @param site ISite instance
     * @param asset Asset address
     * @param enabled True to enable, false to disable
     */
    function setBorrowingEnabled(
        ISite site,
        address asset,
        bool enabled
    ) external;

    /**
     * @notice Enables/disables deposits for asset
     * @dev Emergency function to pause deposits without full pause
     * @param site ISite instance
     * @param asset Asset address
     * @param enabled True to enable, false to disable
     */
    function setDepositsEnabled(
        ISite site,
        address asset,
        bool enabled
    ) external;

    /**
     * @notice Gets current asset configuration
     * @dev For UI/off-chain queries. Sites use cached values.
     * @param site ISite instance
     * @param asset Asset address
     * @return Current configuration struct
     */
    function getAssetConfig(
        ISite site,
        address asset
    ) external view returns (AssetConfig memory);

    /**
     * @notice Gets resolution grace period
     * @param site ISite instance
     * @return Grace period in seconds
     */
    function getResolutionGracePeriod(
        ISite site
    ) external view returns (uint256);

    /**
     * @notice Gets post-resolution liquidation delay
     * @param site ISite instance
     * @return Delay in seconds
     */
    function getPostResolutionLiquidationDelay(
        ISite site
    ) external view returns (uint256);
}

/**
 * @title IFeeCollector
 * @notice Fee management and collection for protocol revenue
 * @dev Fees start at 0% but infrastructure must exist from day 1
 */
interface IFeeCollector {
    /// @notice Emitted when protocol fee updated
    event ProtocolFeeUpdated(uint256 newFeeBps);

    /// @notice Emitted when liquidation incentive updated
    event LiquidationIncentiveUpdated(
        uint256 liquidatorBps,
        uint256 protocolBps
    );

    /// @notice Emitted when resolution fee updated
    event ResolutionFeeUpdated(uint256 newFeeBps);

    /// @notice Emitted when fees collected
    event FeesCollected(ISite indexed site, uint256 amount);

    /// @notice Emitted when fee recipient updated
    event FeeRecipientUpdated(address indexed newRecipient);

    /// @notice Emitted when fees paused
    event FeesPaused();

    /// @notice Emitted when fees unpaused
    event FeesUnpaused();

    /**
     * @notice Sets protocol fee on interest
     * @dev Only callable by FEE_MANAGER_ROLE. Can start at 0%.
     * @param bps Fee in basis points (100 = 1%)
     */
    function setProtocolFeeBps(uint256 bps) external;

    /**
     * @notice Sets liquidation incentive split
     * @dev Liquidator gets liquidatorBps, protocol gets protocolBps
     * @param liquidatorBps Liquidator's share in basis points
     * @param protocolBps Protocol's share in basis points
     */
    function setLiquidationIncentiveBps(
        uint256 liquidatorBps,
        uint256 protocolBps
    ) external;

    /**
     * @notice Sets resolution handling fee
     * @dev Optional fee for handling resolution complexity
     * @param bps Fee in basis points
     */
    function setResolutionFeeBps(uint256 bps) external;

    /**
     * @notice Collects accumulated fees from Site
     * @dev Anyone can trigger collection (fees go to feeRecipient)
     * @param site ISite instance to collect from
     * @return collected Amount collected
     */
    function collectFees(ISite site) external returns (uint256 collected);

    /**
     * @notice Collects fees for specific asset in Site
     * @param site ISite instance
     * @param asset Asset address
     * @return collected Amount collected
     */
    function collectFeesForAsset(
        ISite site,
        address asset
    ) external returns (uint256 collected);

    /**
     * @notice Gets claimable fees for Site
     * @param site ISite instance
     * @return Claimable fee amount
     */
    function claimableFees(ISite site) external view returns (uint256);

    /**
     * @notice Gets claimable fees for specific asset
     * @param site ISite instance
     * @param asset Asset address
     * @return Claimable fee amount
     */
    function claimableFeesForAsset(
        ISite site,
        address asset
    ) external view returns (uint256);

    /**
     * @notice Sets address that receives collected fees
     * @dev Only callable by owner. Typically DAO treasury.
     * @param recipient New fee recipient address
     */
    function setFeeRecipient(address recipient) external;

    /**
     * @notice Gets current fee recipient
     * @return Fee recipient address
     */
    function feeRecipient() external view returns (address);

    /**
     * @notice Gets current protocol fee
     * @return Fee in basis points
     */
    function protocolFeeBps() external view returns (uint256);

    /**
     * @notice Gets liquidation incentive split
     * @return liquidatorBps Liquidator's share
     * @return protocolBps Protocol's share
     */
    function liquidationIncentive()
        external
        view
        returns (uint256 liquidatorBps, uint256 protocolBps);

    /**
     * @notice Gets resolution fee
     * @return Fee in basis points
     */
    function resolutionFeeBps() external view returns (uint256);

    /**
     * @notice Emergency pause for fee collection
     * @dev Only callable by EMERGENCY_ADMIN_ROLE
     */
    function pauseFees() external;

    /**
     * @notice Unpause fee collection
     * @dev Only callable by EMERGENCY_ADMIN_ROLE
     */
    function unpauseFees() external;

    /**
     * @notice Checks if fees are active
     * @return True if fees are being collected
     */
    function areFeesActive() external view returns (bool);
}
