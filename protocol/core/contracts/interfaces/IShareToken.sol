// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IShareToken {
    /**
     * @notice Mints new share tokens
     * @dev Only callable by the Site contract
     * @param to Address to mint to
     * @param amount Amount to mint
     */
    function mint(address to, uint256 amount) external;

    /**
     * @notice Burns share tokens
     * @dev Only callable by the Site contract
     * @param from Address to burn from
     * @param amount Amount to burn
     */
    function burn(address from, uint256 amount) external;

    /**
     * @notice Gets the Site contract address
     * @return Address of the Site that controls this token
     */
    function site() external view returns (address);

    /**
     * @notice Gets the underlying asset address
     * @return Address of the asset this token represents shares of
     */
    function asset() external view returns (address);

    // Standard ERC20 functions
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
