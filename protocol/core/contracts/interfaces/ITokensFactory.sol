// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface ITokensFactory {
    /// @notice Type of share token being deployed
    enum TokenType {
        Collateral, // Borrowable collateral token
        CollateralOnly, // Protected collateral token
        Debt // Debt token (implements IERC20R)
    }

    /// @notice Emitted when a share token is deployed
    /// @param token Address of deployed token
    /// @param site Address of Site this token belongs to
    /// @param asset Address of underlying asset
    /// @param tokenType Type of token deployed
    event ShareTokenDeployed(
        address indexed token,
        address indexed site,
        address indexed asset,
        TokenType tokenType
    );

    /**
     * @notice Creates a borrowable collateral share token
     * @param site Address of the Site
     * @param asset Address of the underlying asset
     * @param name Token name
     * @param symbol Token symbol
     * @return Address of deployed token
     */
    function createShareCollateralToken(
        address site,
        address asset,
        string calldata name,
        string calldata symbol
    ) external returns (address);

    /**
     * @notice Creates a protected collateral share token
     * @param site Address of the Site
     * @param asset Address of the underlying asset
     * @param name Token name
     * @param symbol Token symbol
     * @return Address of deployed token
     */
    function createShareProtectedToken(
        address site,
        address asset,
        string calldata name,
        string calldata symbol
    ) external returns (address);

    /**
     * @notice Creates a debt share token (implements IERC20R)
     * @param site Address of the Site
     * @param asset Address of the underlying asset
     * @param name Token name
     * @param symbol Token symbol
     * @return Address of deployed token
     */
    function createShareDebtToken(
        address site,
        address asset,
        string calldata name,
        string calldata symbol
    ) external returns (address);

    /**
     * @notice Validates if address is a Site
     * @param site Address to check
     * @return True if valid Site
     */
    function isSite(address site) external view returns (bool);
}
