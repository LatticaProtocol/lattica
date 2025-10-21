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
     * @param repository ISiteRepository instance
     * @param yesToken Address of YES share token (from Polymarket CTF)
     * @param noToken Address of NO share token (from Polymarket CTF)
     * @param borrowToken Address of USDC
     * @param interestRateModel IInterestRateModel instance
     * @return site Deployed ISite instance
     */
    function createSite(
        bytes32 conditionId,
        ISiteRepository repository,
        address yesToken,
        address noToken,
        address borrowToken,
        IInterestRateModel interestRateModel
    ) external returns (ISite site);

    /**
     * @notice Gets the factory version
     * @return Version number
     */
    function version() external view returns (uint256);

    /**
     * @notice Ping function to verify interface
     * @return Function selector
     */
    function siloFactoryPing() external pure returns (bytes4);
}
