// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20R is IERC20 {
    /// @notice Emitted when receive approval is set
    /// @param owner Address that can receive tokens
    /// @param spender Address that can send tokens to owner
    /// @param value Amount approved
    event ReceiveApproval(address indexed owner, address indexed spender, uint256 value);

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
    function increaseReceiveAllowance(address spender, uint256 addedValue) external;

    /**
     * @notice Decreases receive allowance
     * @param spender Address that can send tokens
     * @param subtractedValue Amount to subtract from allowance
     */
    function decreaseReceiveAllowance(address spender, uint256 subtractedValue) external;

    /**
     * @notice Gets receive allowance
     * @dev How much can spender send to owner?
     * @param owner Address that would receive tokens
     * @param spender Address that would send tokens
     * @return Allowance amount
     */
    function receiveAllowance(address owner, address spender) external view returns (uint256);
}
