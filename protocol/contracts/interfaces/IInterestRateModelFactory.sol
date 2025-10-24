// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IInterestRateModel.sol";

interface IInterestRateModelFactory {
    /**
     * @notice Interest rate model parameters
     * @dev All parameters for kinked rate curve
     */
    struct ModelParameters {
        uint256 baseRatePerYear; // Base rate at 0% utilization
        uint256 multiplierPerYear; // Rate increase per utilization before kink
        uint256 jumpMultiplierPerYear; // Rate increase per utilization after kink
        uint256 kink; // Utilization point where slope changes (basis points)
    }

    /// @notice Emitted when new model created
    /// @param model IInterestRateModel instance
    /// @param creator Address that created the model
    event InterestRateModelCreated(
        IInterestRateModel indexed model,
        address indexed creator
    );

    /**
     * @notice Creates custom interest rate model
     * @dev Anyone can create models with custom parameters
     * @param baseRatePerYear Base rate (ray format, 1e27 = 100%)
     * @param multiplierPerYear Multiplier before kink (ray)
     * @param jumpMultiplierPerYear Multiplier after kink (ray)
     * @param kink Kink point in basis points (8000 = 80%)
     * @return Deployed IInterestRateModel instance
     */
    function createInterestRateModel(
        uint256 baseRatePerYear,
        uint256 multiplierPerYear,
        uint256 jumpMultiplierPerYear,
        uint256 kink
    ) external returns (IInterestRateModel);

    /**
     * @notice Creates interest rate model with default parameters
     * @dev Convenience function for standard curve
     * @return Deployed IInterestRateModel instance
     */
    function createDefaultInterestRateModel()
        external
        returns (IInterestRateModel);

    /**
     * @notice Gets default model parameters
     * @dev Returns recommended parameters for most Sites
     * @return ModelParameters struct with defaults
     */
    function getDefaultParameters()
        external
        pure
        returns (ModelParameters memory);
}
