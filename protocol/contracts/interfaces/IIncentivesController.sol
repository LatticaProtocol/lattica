// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./ISite.sol";

interface IIncentivesController {
    /**
     * @notice Incentive program configuration
     * @dev All data for a reward distribution program
     */
    struct IncentiveProgram {
        address rewardToken; // Token being distributed
        uint256 rewardPerSecond; // Emission rate
        uint256 startTime; // Program start timestamp
        uint256 endTime; // Program end timestamp
        uint256 totalRewards; // Total rewards allocated
        uint256 distributedRewards; // Rewards already distributed
    }

    /// @notice Emitted when incentive program created
    /// @param programId Unique program identifier
    /// @param site ISite this program applies to
    /// @param rewardToken Token being distributed
    event IncentiveProgramCreated(uint256 indexed programId, ISite indexed site, address rewardToken);

    /// @notice Emitted when rewards accrue to user
    /// @param user User accruing rewards
    /// @param programId Program identifier
    /// @param amount Amount accrued
    event RewardsAccrued(address indexed user, uint256 indexed programId, uint256 amount);

    /// @notice Emitted when user claims rewards
    /// @param user User claiming
    /// @param programId Program identifier
    /// @param amount Amount claimed
    event RewardsClaimed(address indexed user, uint256 indexed programId, uint256 amount);

    /**
     * @notice Creates new incentive program
     * @dev Only callable by INCENTIVE_MANAGER_ROLE
     * @param site ISite to incentivize
     * @param rewardToken Token to distribute
     * @param rewardPerSecond Emission rate
     * @param duration Program duration in seconds
     * @return programId Unique identifier for this program
     */
    function createIncentiveProgram(ISite site, address rewardToken, uint256 rewardPerSecond, uint256 duration)
        external
        returns (uint256 programId);

    /**
     * @notice Accrues rewards for a user
     * @dev Called by gauge or can be called directly
     * @param site ISite to accrue for
     * @param user User to accrue rewards to
     */
    function accrueRewards(ISite site, address user) external;

    /**
     * @notice Claims rewards from a program
     * @param programId Program to claim from
     * @return amount Amount claimed
     */
    function claimRewards(uint256 programId) external returns (uint256 amount);

    /**
     * @notice Gets accrued but unclaimed rewards
     * @param programId Program identifier
     * @param user User to check
     * @return Accrued reward amount
     */
    function getAccruedRewards(uint256 programId, address user) external view returns (uint256);

    /**
     * @notice Gets incentive program details
     * @param programId Program identifier
     * @return IncentiveProgram struct with all details
     */
    function getIncentiveProgram(uint256 programId) external view returns (IncentiveProgram memory);
}
