// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IOracleProvider {
    /**
     * @notice Gets price for an asset
     * @param asset Address of asset
     * @return price Price in quote token units
     */
    function getPrice(address asset) external view returns (uint256 price);

    /**
     * @notice Checks if oracle supports an asset
     * @param asset Address of asset
     * @return True if supported
     */
    function assetSupported(address asset) external view returns (bool);

    /**
     * @notice Gets the quote token (e.g., USDC)
     * @return Address of quote token
     */
    function quoteToken() external view returns (address);

    /**
     * @notice Ping function to verify interface
     * @return Function selector
     */
    function oracleProviderPing() external pure returns (bytes4);
}
