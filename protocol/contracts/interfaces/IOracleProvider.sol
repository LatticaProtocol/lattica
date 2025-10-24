// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IOracleProvider {
    /**
     * @notice Gets price for an asset
     * @param asset Asset address
     * @return price Price in quote token terms
     */
    function getPrice(address asset) external view returns (uint256 price);

    /**
     * @notice Checks if asset is supported by this oracle
     * @param asset Asset address
     * @return True if supported
     */
    function assetSupported(address asset) external view returns (bool);

    /**
     * @notice Gets the quote token for prices
     * @dev All prices are denominated in this token (typically USDC)
     * @return Address of quote token
     */
    function quoteToken() external view returns (address);

    /**
     * @notice Ping function to verify interface
     * @return Function selector for interface detection
     */
    function oracleProviderPing() external pure returns (bytes4);
}
