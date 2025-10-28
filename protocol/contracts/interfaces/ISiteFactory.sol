// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IHookReceiver.sol";
import "./IInterestRateModel.sol";
import "./ISite.sol";
import "./ISiteRepository.sol";

interface ISiteFactory {
    /// @notice Emitted when a new Site is deployed
    /// @param site ISite instance of deployed contract
    /// @param conditionId Polymarket condition ID
    /// @param version Factory version used
    event SiteDeployed(ISite indexed site, bytes32 indexed conditionId, uint256 version);

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
