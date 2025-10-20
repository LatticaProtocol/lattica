// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IWrappedNativeToken is IERC20 {
    /**
     * @notice Wraps native ETH to WETH
     * @dev Payable function, msg.value determines wrap amount
     */
    function deposit() external payable;

    /**
     * @notice Unwraps WETH to native ETH
     * @param amount Amount to unwrap
     */
    function withdraw(uint256 amount) external;
}
