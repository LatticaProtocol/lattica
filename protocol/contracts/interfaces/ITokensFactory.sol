// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./IERC20R.sol";
import "./IShareToken.sol";
import "./ISite.sol";

interface ITokensFactory {
    /// @notice Type of share token being deployed
    enum TokenType {
        Collateral, // Borrowable collateral token
        CollateralOnly, // Protected collateral token
        Debt // Debt token (implements IERC20R)

    }

    /// @notice Emitted when a share token is deployed
    /// @param token Address of deployed token
    /// @param site ISite instance this token belongs to
    /// @param asset Address of underlying asset
    /// @param tokenType Type of token deployed
    event ShareTokenDeployed(address indexed token, ISite indexed site, address indexed asset, TokenType tokenType);

    /**
     * @notice Creates a borrowable collateral share token
     * @param site ISite instance
     * @param asset Address of the underlying asset
     * @param name Token name
     * @param symbol Token symbol
     * @return Deployed IShareToken instance
     */
    function createShareCollateralToken(ISite site, address asset, string calldata name, string calldata symbol)
        external
        returns (IShareToken);

    /**
     * @notice Creates a protected collateral share token
     * @param site ISite instance
     * @param asset Address of the underlying asset
     * @param name Token name
     * @param symbol Token symbol
     * @return Deployed IShareToken instance
     */
    function createShareProtectedToken(ISite site, address asset, string calldata name, string calldata symbol)
        external
        returns (IShareToken);

    /**
     * @notice Creates a debt share token (implements IERC20R)
     * @param site ISite instance
     * @param asset Address of the underlying asset
     * @param name Token name
     * @param symbol Token symbol
     * @return Deployed IERC20R instance
     */
    function createShareDebtToken(ISite site, address asset, string calldata name, string calldata symbol)
        external
        returns (IERC20R);

    /**
     * @notice Validates if address is a Site
     * @param site Address to check
     * @return True if valid Site
     */
    function isSite(address site) external view returns (bool);
}
