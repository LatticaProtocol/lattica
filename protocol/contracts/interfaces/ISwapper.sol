// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface ISwapper {
    /// @notice Emitted when swap executes
    /// @param tokenIn Input token address
    /// @param tokenOut Output token address
    /// @param amountIn Amount of input tokens
    /// @param amountOut Amount of output tokens
    event Swap(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    /**
     * @notice Swaps exact input amount
     * @dev Specify input amount, receive at least minAmountOut
     * @param tokenIn Input token address
     * @param tokenOut Output token address (typically USDC)
     * @param amountIn Exact amount of input tokens
     * @param minAmountOut Minimum output tokens (slippage protection)
     * @param data DEX-specific swap data (path, pool fees, etc.)
     * @return amountOut Actual amount of output tokens received
     */
    function swapAmountIn(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        bytes calldata data
    ) external returns (uint256 amountOut);

    /**
     * @notice Swaps for exact output amount
     * @dev Specify output amount, spend at most maxAmountIn
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountOut Exact amount of output tokens desired
     * @param maxAmountIn Maximum input tokens to spend
     * @param data DEX-specific swap data
     * @return amountIn Actual amount of input tokens spent
     */
    function swapAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountOut,
        uint256 maxAmountIn,
        bytes calldata data
    ) external returns (uint256 amountIn);

    /**
     * @notice Gets the address to approve for swaps
     * @dev Liquidators must approve this address to spend tokens
     * @return Address to approve (DEX router address)
     */
    function spenderToApprove() external view returns (address);

    /**
     * @notice Quotes output amount for given input
     * @dev Off-chain query for expected swap output
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountIn Amount of input tokens
     * @return Expected amount of output tokens
     */
    function getAmountOut(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256);

    /**
     * @notice Quotes input amount for given output
     * @dev Off-chain query for expected swap input
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountOut Desired amount of output tokens
     * @return Expected amount of input tokens needed
     */
    function getAmountIn(address tokenIn, address tokenOut, uint256 amountOut) external view returns (uint256);
}
