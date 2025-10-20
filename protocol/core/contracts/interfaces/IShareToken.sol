// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IShareToken is IERC20 {
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
     * @notice Gets the Site contract that controls this token
     * @return ISite instance that can mint/burn
     */
    function site() external view returns (ISite);

    /**
     * @notice Gets the underlying asset address
     * @return Address of the asset this token represents shares of
     */
    function asset() external view returns (address);
}
