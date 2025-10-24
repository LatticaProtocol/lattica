// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

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
