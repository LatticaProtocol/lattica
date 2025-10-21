// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IInterestRateModel.sol";

interface IInterestRateModelFactory {
    /// @notice Emitted when new model is created
    event InterestRateModelCreated(
        IInterestRateModel indexed model,
        address indexed creator
    );

    /**
     * @notice Interest rate model parameters
     * @dev Standard jump rate model parameters
     */
    struct ModelParameters {
        uint256 baseRatePerYear; // Base interest rate (at 0% utilization)
        uint256 multiplierPerYear; // Rate of increase before kink
        uint256 jumpMultiplierPerYear; // Rate of increase after kink
        uint256 kink; // Utilization point where rate jumps
    }

    /**
     * @notice Creates interest rate model with custom parameters
     * @param baseRatePerYear Base rate in ray
     * @param multiplierPerYear Multiplier in ray
     * @param jumpMultiplierPerYear Jump multiplier in ray
     * @param kink Kink utilization in ray (e.g., 0.8e27 = 80%)
     * @return Deployed IInterestRateModel instance
     */
    function createInterestRateModel(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink
    ) external returns (IInterestRateModel);

    /**
     * @notice Creates model with default parameters
     * @return Deployed IInterestRateModel instance
     */
    function createDefaultInterestRateModel()
        external
        returns (IInterestRateModel);

    /**
     * @notice Gets default parameter values
     * @return Default parameters struct
     */
    function getDefaultParameters()
        external
        pure
        returns (ModelParameters memory);
}
