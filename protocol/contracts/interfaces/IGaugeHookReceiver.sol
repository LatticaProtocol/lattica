// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IGauge.sol";
import "./IHookReceiver.sol";

interface IGaugeHookReceiver is IHookReceiver {
    /// @notice Emitted when gauge is set for a Site
    /// @param site ISite instance
    /// @param oldGauge Previous gauge (address(0) if none)
    /// @param newGauge New gauge instance
    event GaugeUpdated(ISite indexed site, IGauge indexed oldGauge, IGauge indexed newGauge);

    /// @notice Emitted when user balance updated in gauge
    /// @param site ISite where balance changed
    /// @param user User whose balance changed
    /// @param oldBalance Previous balance
    /// @param newBalance New balance
    event GaugeBalanceUpdated(ISite indexed site, address indexed user, uint256 oldBalance, uint256 newBalance);

    /**
     * @notice Sets gauge for a Site
     * @dev Only callable by GAUGE_MANAGER_ROLE
     * @param site ISite to set gauge for
     * @param gauge IGauge instance (or address(0) to disable)
     */
    function setGauge(ISite site, IGauge gauge) external;

    /**
     * @notice Gets gauge for a Site
     * @param site ISite to query
     * @return IGauge instance, or IGauge(address(0)) if none
     */
    function getGauge(ISite site) external view returns (IGauge);

    /**
     * @notice Checks if Site has gauge enabled
     * @param site ISite to check
     * @return True if gauge is set and active
     */
    function hasGauge(ISite site) external view returns (bool);
}
