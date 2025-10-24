// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IHookReceiver.sol";

interface IHookReceiverChain is IHookReceiver {
    /// @notice Emitted when hook receiver added to chain
    /// @param hookReceiver IHookReceiver instance added
    /// @param index Index in chain
    event HookReceiverAdded(IHookReceiver indexed hookReceiver, uint256 index);

    /// @notice Emitted when hook receiver removed from chain
    /// @param hookReceiver IHookReceiver instance removed
    /// @param index Index that was removed
    event HookReceiverRemoved(
        IHookReceiver indexed hookReceiver,
        uint256 index
    );

    /**
     * @notice Adds hook receiver to end of chain
     * @dev Only callable by owner
     * @param hookReceiver IHookReceiver to add
     */
    function addHookReceiver(IHookReceiver hookReceiver) external;

    /**
     * @notice Removes hook receiver from chain
     * @dev Only callable by owner
     * @param index Index to remove
     */
    function removeHookReceiver(uint256 index) external;

    /**
     * @notice Gets all hook receivers in chain
     * @return Array of IHookReceiver instances
     */
    function getHookReceivers() external view returns (IHookReceiver[] memory);

    /**
     * @notice Gets hook receiver at specific index
     * @param index Index to query
     * @return IHookReceiver at index
     */
    function getHookReceiver(
        uint256 index
    ) external view returns (IHookReceiver);

    /**
     * @notice Gets number of hook receivers in chain
     * @return Count of hook receivers
     */
    function getHookReceiverCount() external view returns (uint256);
}
