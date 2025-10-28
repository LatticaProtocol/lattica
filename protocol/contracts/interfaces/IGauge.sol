// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface IGauge {
    /// @notice Emitted when user balance updated
    /// @param site ISite where balance changed
    /// @param user User whose balance changed
    /// @param oldBalance Previous balance
    /// @param newBalance New balance
    /// @param timestamp Update timestamp
    event UserBalanceUpdated(
        ISite indexed site, address indexed user, uint256 oldBalance, uint256 newBalance, uint256 timestamp
    );

    /// @notice Emitted when user claims rewards
    /// @param user User claiming rewards
    /// @param rewardToken Token being claimed
    /// @param amount Amount claimed
    event RewardClaimed(address indexed user, address indexed rewardToken, uint256 amount);

    /**
     * @notice Updates user balance in gauge
     * @dev Only callable by authorized GaugeHookReceiver
     * @param site ISite where balance changed
     * @param user User whose balance changed
     * @param newBalance New balance of share tokens
     */
    function updateUserBalance(ISite site, address user, uint256 newBalance) external;

    /**
     * @notice Handles transfer notification
     * @dev Handles mint (from=0), burn (to=0), and transfers
     * @param site ISite where transfer occurred
     * @param from Sender (0 for mint)
     * @param to Recipient (0 for burn)
     * @param amount Amount transferred
     */
    function notifyTransfer(ISite site, address from, address to, uint256 amount) external;

    /**
     * @notice Gets user's voting power
     * @dev Typically equals share token balance
     * @param user User address
     * @return Voting power
     */
    function getVotingPower(address user) external view returns (uint256);

    /**
     * @notice Gets user's balance in a Site
     * @param site ISite to query
     * @param user User address
     * @return User's share token balance tracked by gauge
     */
    function getUserBalance(ISite site, address user) external view returns (uint256);

    /**
     * @notice Claims pending rewards for caller
     * @return rewardTokens Array of reward token addresses
     * @return amounts Array of amounts claimed
     */
    function claimRewards() external returns (address[] memory rewardTokens, uint256[] memory amounts);

    /**
     * @notice Gets pending rewards for a user
     * @param user User to check
     * @return rewardTokens Array of reward token addresses
     * @return amounts Array of pending amounts
     */
    function getPendingRewards(address user)
        external
        view
        returns (address[] memory rewardTokens, uint256[] memory amounts);
}
