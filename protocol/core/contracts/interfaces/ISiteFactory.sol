// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface ISiteFactory {
    /// @notice Emitted when a new Site is deployed
    /// @param site Address of deployed Site
    /// @param conditionId Polymarket condition ID
    /// @param version Factory version used
    event SiteDeployed(
        address indexed site,
        bytes32 indexed conditionId,
        uint256 version
    );

    /**
     * @notice Deploys a new Site contract
     * @dev Only callable by ISiteRepository
     * @param conditionId Polymarket condition ID
     * @param repository Address of the repository
     * @param yesToken Address of YES share token
     * @param noToken Address of NO share token
     * @param borrowToken Address of USDC
     * @param interestRateModel Address of interest rate model
     * @return site Address of deployed Site
     */
    function createSite(
        bytes32 conditionId,
        address repository,
        address yesToken,
        address noToken,
        address borrowToken,
        address interestRateModel
    ) external returns (address site);

    /**
     * @notice Gets the factory version
     * @return Version number
     */
    function version() external view returns (uint256);
}
