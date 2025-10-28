// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface IFeeCollector {
    /// @notice Emitted when protocol fee updated
    event ProtocolFeeUpdated(uint256 newFeeBps);

    /// @notice Emitted when liquidation incentive updated
    event LiquidationIncentiveUpdated(uint256 liquidatorBps, uint256 protocolBps);

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
    function setLiquidationIncentiveBps(uint256 liquidatorBps, uint256 protocolBps) external;

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
    function collectFeesForAsset(ISite site, address asset) external returns (uint256 collected);

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
    function claimableFeesForAsset(ISite site, address asset) external view returns (uint256);

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
    function liquidationIncentive() external view returns (uint256 liquidatorBps, uint256 protocolBps);

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
